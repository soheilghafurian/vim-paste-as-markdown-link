import AppKit

let pb = NSPasteboard.general

func getImageData() -> Data? {
    if let data = pb.data(forType: .png) { return data }
    if let data = pb.data(forType: .tiff),
       let rep = NSBitmapImageRep(data: data),
       let png = rep.representation(using: .png, properties: [:]) { return png }
    return nil
}

if CommandLine.arguments.count > 1 {
    guard let data = getImageData() else { exit(1) }
    do { try data.write(to: URL(fileURLWithPath: CommandLine.arguments[1])) }
    catch { exit(1) }
} else {
    guard getImageData() != nil else { exit(1) }
}
