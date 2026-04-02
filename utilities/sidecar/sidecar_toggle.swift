// sidecar_toggle: expects Screen Mirroring panel to already be open.
// - If iPad already connected as extended: disconnect
// - If iPad connected as mirror: switch to extended
// - If iPad not connected: connect and set extended
import Cocoa
import ApplicationServices

func getAttr(_ elem: AXUIElement, _ attr: String) -> AnyObject? {
    var val: AnyObject?
    AXUIElementCopyAttributeValue(elem, attr as CFString, &val)
    return val
}

func getDesc(_ elem: AXUIElement) -> String {
    getAttr(elem, kAXDescriptionAttribute as String) as? String ?? ""
}

func getRole(_ elem: AXUIElement) -> String {
    getAttr(elem, kAXRoleAttribute as String) as? String ?? ""
}

func getID(_ elem: AXUIElement) -> String {
    getAttr(elem, "AXIdentifier" as String) as? String ?? ""
}

func getIntValue(_ elem: AXUIElement) -> Int {
    (getAttr(elem, kAXValueAttribute as String) as? Int) ?? 0
}

func children(_ elem: AXUIElement) -> [AXUIElement] {
    (getAttr(elem, kAXChildrenAttribute as String) as? [AXUIElement]) ?? []
}

func press(_ elem: AXUIElement) {
    AXUIElementPerformAction(elem, kAXPressAction as CFString)
}

func sendEsc() {
    let down = CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: true)
    let up   = CGEvent(keyboardEventSource: nil, virtualKey: 53, keyDown: false)
    down?.post(tap: .cghidEventTap)
    up?.post(tap: .cghidEventTap)
}

func findAll(_ elem: AXUIElement, role: String, idContains: String = "", descContains: String = "") -> [AXUIElement] {
    var results: [AXUIElement] = []
    if getRole(elem) == role {
        let matchID   = idContains.isEmpty   || getID(elem).contains(idContains)
        let matchDesc = descContains.isEmpty || getDesc(elem).contains(descContains)
        if matchID && matchDesc { results.append(elem) }
    }
    for child in children(elem) {
        results += findAll(child, role: role, idContains: idContains, descContains: descContains)
    }
    return results
}

func getCCWindow() -> AXUIElement? {
    for app in NSWorkspace.shared.runningApplications where app.localizedName == "Control Center" {
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        return (getAttr(axApp, kAXWindowsAttribute as String) as? [AXUIElement])?.first
    }
    return nil
}

// Poll for a condition, up to maxSeconds
func waitFor(maxSeconds: Double, interval: Double = 0.5, condition: () -> Bool) -> Bool {
    let steps = Int(maxSeconds / interval)
    for _ in 0..<steps {
        if condition() { return true }
        Thread.sleep(forTimeInterval: interval)
    }
    return condition()
}

guard let w = getCCWindow() else {
    print("Control Center window not found — is Screen Mirroring panel open?"); exit(1)
}

let triangles = findAll(w, role: "AXDisclosureTriangle", idContains: "Sidecar")

if !triangles.isEmpty {
    // iPad is connected — check if extended display is already set
    let extBoxes = findAll(w, role: "AXCheckBox", descContains: "Use As Extended Display")
    if !extBoxes.isEmpty && getIntValue(extBoxes[0]) == 1 {
        // Already extended — disconnect
        press(triangles[0])
        Thread.sleep(forTimeInterval: 0.5)
        sendEsc()
        print("Disconnected from iPad")
    } else if !extBoxes.isEmpty {
        // Connected but not extended — switch to extended
        press(extBoxes[0])
        Thread.sleep(forTimeInterval: 0.5)
        sendEsc()
        print("Switched iPad to extended display")
    } else {
        sendEsc()
        print("Connected but display options not found")
        exit(1)
    }
} else {
    // Not connected — find the iPad checkbox and connect
    let boxes = findAll(w, role: "AXCheckBox", idContains: "Sidecar")
    guard !boxes.isEmpty else {
        sendEsc()
        print("iPad (Sidecar) not found in Screen Mirroring menu"); exit(1)
    }

    press(boxes[0]) // initiate connection

    // Poll for "Use As Extended Display" — re-fetch window each time in case panel reopens
    var extBox: AXUIElement? = nil
    for _ in 0..<16 { // up to 8 seconds
        Thread.sleep(forTimeInterval: 0.5)
        if let freshW = getCCWindow() {
            let found = findAll(freshW, role: "AXCheckBox", descContains: "Use As Extended Display")
            if !found.isEmpty {
                extBox = found[0]
                break
            }
        }
    }

    if let extBox = extBox {
        press(extBox)
        Thread.sleep(forTimeInterval: 0.5)
        sendEsc()
        print("Connected to iPad as extended display")
    } else {
        // Print what IS visible for debugging
        if let freshW = getCCWindow() {
            let opts = findAll(freshW, role: "AXCheckBox", idContains: "Sidecar")
            for o in opts { print("  visible option: '\(getDesc(o))'") }
        }
        sendEsc()
        print("Timed out waiting for 'Use As Extended Display'"); exit(1)
    }
}
