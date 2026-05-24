import Foundation

struct AIResponseSettings: Codable, Equatable {
    var userSystemPrompt: String

    static let defaultPrompt = """
    Help answer the user's current question from the available screen context. Be concise, infer multiple-choice options when present, and prefer the smallest correct menu bar answer.
    """

    static let `default` = AIResponseSettings(userSystemPrompt: defaultPrompt)
}

struct MenuBarToolOutput: Codable, Equatable {
    var shouldRespond: Bool
    var menuBarText: String
    var fullResponse: String
}

enum AIResponseSystem {
    static let menuBarToolInstruction = """
    You have one display tool named menu_bar.
    Use it to choose exactly what dot should show in the macOS menu bar.
    The menu_bar text must be as short as possible.
    Prefer MCQ letters when applicable: A, B, C, D, E, A/B, B/E, or A/C/E.
    Screenshots may not explicitly show A-E labels; infer the question and options from the visible content.
    Return natural text if needed, but keep menu_bar under 12 characters whenever possible.
    Do not expose JSON to the user.
    """

    static func prompt(settings: AIResponseSettings, screenContext: String, userQuestion: String) -> String {
        """
        \(settings.userSystemPrompt)

        \(menuBarToolInstruction)

        Screen context:
        \(screenContext)

        User question:
        \(userQuestion)
        """
    }

    static func normalize(rawModelResponse: String) -> MenuBarToolOutput {
        if let decoded = decodeToolOutput(rawModelResponse) {
            return sanitized(decoded)
        }

        let stripped = stripJSONLikeEnvelope(from: rawModelResponse)
        let menuBarText = shortestMenuBarCandidate(in: stripped)

        return sanitized(MenuBarToolOutput(
            shouldRespond: !menuBarText.isEmpty,
            menuBarText: menuBarText,
            fullResponse: stripped
        ))
    }

    private static func decodeToolOutput(_ raw: String) -> MenuBarToolOutput? {
        let decoder = JSONDecoder()
        let candidates = [
            raw,
            extractJSONObject(from: raw)
        ].compactMap { $0?.data(using: .utf8) }

        for data in candidates {
            if let output = try? decoder.decode(MenuBarToolOutput.self, from: data) {
                return output
            }
        }

        return nil
    }

    private static func sanitized(_ output: MenuBarToolOutput) -> MenuBarToolOutput {
        let menuText = sanitizeMenuBarText(output.menuBarText.isEmpty ? output.fullResponse : output.menuBarText)
        return MenuBarToolOutput(
            shouldRespond: output.shouldRespond && !menuText.isEmpty,
            menuBarText: menuText,
            fullResponse: stripJSONLikeEnvelope(from: output.fullResponse)
        )
    }

    private static func shortestMenuBarCandidate(in response: String) -> String {
        let range = NSRange(response.startIndex..<response.endIndex, in: response)
        let pattern = #"\b[A-E](?:\s*/\s*[A-E]){0,4}\b"#

        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: response, range: range),
           let swiftRange = Range(match.range, in: response) {
            return String(response[swiftRange]).replacingOccurrences(of: " ", with: "")
        }

        return sanitizeMenuBarText(response)
    }

    private static func sanitizeMenuBarText(_ text: String) -> String {
        let cleaned = stripJSONLikeEnvelope(from: text)
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty else { return "" }
        guard cleaned.count > 12 else { return cleaned }
        return String(cleaned.prefix(11)) + "..."
    }

    private static func stripJSONLikeEnvelope(from text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.hasPrefix("```") {
            cleaned = cleaned
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let noisyKeys = [
            "\"shouldRespond\":true",
            "\"shouldRespond\":false",
            "\"choice\":",
            "\"menuBarText\":",
            "\"fullResponse\":"
        ]

        for key in noisyKeys {
            cleaned = cleaned.replacingOccurrences(of: key, with: "")
        }

        return cleaned
            .trimmingCharacters(in: CharacterSet(charactersIn: "{}[]\", "))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractJSONObject(from text: String) -> String? {
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}"),
              start <= end else {
            return nil
        }

        return String(text[start...end])
    }
}
