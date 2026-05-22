import Carbon
import Foundation

final class GlobalHotKey: ObservableObject {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var action: (() -> Void)?
    private let hotKeyID = EventHotKeyID(signature: FourCharCode("DOT1"), id: 1)

    func register(action: @escaping () -> Void) {
        self.action = action

        guard hotKeyRef == nil, eventHandlerRef == nil else {
            return
        }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else {
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

                let owner = Unmanaged<GlobalHotKey>.fromOpaque(userData).takeUnretainedValue()
                guard incomingHotKeyID.id == owner.hotKeyID.id,
                      incomingHotKeyID.signature == owner.hotKeyID.signature else {
                    return OSStatus(eventNotHandledErr)
                }

                DispatchQueue.main.async {
                    owner.action?()
                }

                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )

        var registeredHotKey: EventHotKeyRef?
        let registrationStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_Grave),
            UInt32(optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &registeredHotKey
        )

        if registrationStatus == noErr {
            hotKeyRef = registeredHotKey
        }
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    deinit {
        unregister()
    }
}

private func FourCharCode(_ string: String) -> OSType {
    precondition(string.utf8.count == 4)
    return string.utf8.reduce(0) { result, character in
        (result << 8) + OSType(character)
    }
}
