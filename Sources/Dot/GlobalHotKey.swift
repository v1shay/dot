import Carbon
import Foundation

final class GlobalHotKey: ObservableObject {
    private static var eventHandlerRef: EventHandlerRef?
    private static var actions: [UInt32: () -> Void] = [:]

    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID: EventHotKeyID
    private let keyCode: UInt32
    private let modifiers: UInt32

    static let graveKeyCode = UInt32(kVK_ANSI_Grave)
    static let hKeyCode = UInt32(kVK_ANSI_H)
    static let optionModifier = UInt32(optionKey)

    init(signature: String = "DOT1", id: UInt32 = 1, keyCode: UInt32 = GlobalHotKey.graveKeyCode, modifiers: UInt32 = GlobalHotKey.optionModifier) {
        hotKeyID = EventHotKeyID(signature: FourCharCode(signature), id: id)
        self.keyCode = keyCode
        self.modifiers = modifiers
    }

    func register(action: @escaping () -> Void) {
        guard hotKeyRef == nil else {
            Self.actions[hotKeyID.id] = action
            return
        }

        Self.installEventHandlerIfNeeded()

        var registeredHotKey: EventHotKeyRef?
        let registrationStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &registeredHotKey
        )

        if registrationStatus == noErr {
            hotKeyRef = registeredHotKey
            Self.actions[hotKeyID.id] = action
            NSLog("Dot registered hotkey id \(hotKeyID.id)")
        } else {
            NSLog("Dot failed to register hotkey id \(hotKeyID.id) with status \(registrationStatus)")
        }
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        Self.actions[hotKeyID.id] = nil
    }

    deinit {
        unregister()
    }

    private static func installEventHandlerIfNeeded() {
        guard eventHandlerRef == nil else {
            return
        }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, _ in
                guard let event else {
                    return OSStatus(eventNotHandledErr)
                }

                var incomingHotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &incomingHotKeyID
                )

                guard status == noErr else {
                    return status
                }

                guard let action = GlobalHotKey.actions[incomingHotKeyID.id] else {
                    return OSStatus(eventNotHandledErr)
                }

                DispatchQueue.main.async {
                    NSLog("Dot received hotkey id \(incomingHotKeyID.id)")
                    action()
                }

                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }
}

private func FourCharCode(_ string: String) -> OSType {
    precondition(string.utf8.count == 4)
    return string.utf8.reduce(0) { result, character in
        (result << 8) + OSType(character)
    }
}
