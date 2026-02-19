import AppKit

if let html = NSPasteboard.general.string(forType: .html) {
    print(html, terminator: "")
} else {
    exit(1)
}
