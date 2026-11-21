// Encodes a folder of PNG frames, in name order, into one H.264 video: the
// product page header's loop (1.4.1), drawn by ProductPageHeader.html `?t=`
// and rendered by RenderHeaderVideo.py. App Store Connect takes a .mov, .m4v
// or .mp4 in the header's slot, 3840 x 1646, 30 or 60 frames a second, 5 to 30
// seconds ("Creative assets specifications", as Glazzy read it on 2026-11-20).
// No audio: the header plays muted.
//
//     swift Tools/EncodeHeaderVideo.swift <frames folder> <fps> <out.mp4 | out.mov> [megabits a second]
//
// Glazzy's encoder (docs/appstore/encode.swift, 2026-11-20), copied, not shared:
// each app's tools stay in its own repository. The bit rate is 9 megabits a
// second unless given, so 8 seconds come to about 9 MB, under the 10 MB a file
// the browser upload takes. A key frame every 2 seconds. Plain AVFoundation, on
// macOS 27's pixel buffer receiver, so it needs nothing Xcode doesn't bring.
// The frames are Chrome's, sRGB: each buffer says so, and the video is tagged
// BT.709, what a player expects, so AVFoundation converts between the two
// rather than pass sRGB's values off as BT.709's.
//
// It lives in Tools/, outside every synchronized root group, and belongs to no
// build target (rule 15-project).
import AVFoundation
import CoreGraphics
import CoreVideo
import ImageIO

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

let arguments = CommandLine.arguments
guard arguments.count == 4 || arguments.count == 5, let fps = Int32(arguments[2]), fps > 0,
      let megabits = arguments.count == 5 ? Double(arguments[4]) : 9, megabits > 0 else {
    fail("usage: swift EncodeHeaderVideo.swift <frames folder> <fps> <out.mp4 | out.mov> [megabits a second]")
}
let folder = URL(fileURLWithPath: arguments[1])
let output = URL(fileURLWithPath: arguments[3])
let frames = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil))?
    .filter { $0.pathExtension == "png" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent } ?? []
guard !frames.isEmpty else { fail("\(folder.path): no PNG frames") }

func picture(_ url: URL) -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { fail("\(url.path): not a picture") }
    return image
}
let first = picture(frames[0])
let width = first.width, height = first.height
guard width % 2 == 0, height % 2 == 0 else { fail("\(width) x \(height): H.264 takes even sides only") }

try? FileManager.default.removeItem(at: output)
let writer: AVAssetWriter
do {
    writer = try AVAssetWriter(outputURL: output, fileType: output.pathExtension == "mov" ? .mov : .mp4)
} catch {
    fail("\(output.path): \(error)")
}
let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoColorPropertiesKey: [
        AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
        AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
        AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2,
    ],
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: Int(megabits * 1_000_000),
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
        AVVideoMaxKeyFrameIntervalKey: Int(fps) * 2,
        AVVideoExpectedSourceFrameRateKey: Int(fps),
    ],
])
let receiver = writer.inputPixelBufferReceiver(for: input, pixelBufferAttributes: CVPixelBufferCreationAttributes(
    pixelFormatType: CVPixelFormatType(rawValue: kCVPixelFormatType_32BGRA), size: CVImageSize(width: width, height: height)))
do {
    try writer.start()
} catch {
    fail("can't start writing: \(error)")
}
writer.startSession(atSourceTime: .zero)

let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
for (index, url) in frames.enumerated() {
    let image = index == 0 ? first : picture(url)
    guard image.width == width, image.height == height else {
        fail("\(url.lastPathComponent): \(image.width) x \(image.height), not \(width) x \(height)")
    }
    guard let pool = receiver.pixelBufferPool else { fail("no pixel buffer pool: \(String(describing: writer.error))") }
    var buffer: CVMutablePixelBuffer
    do {
        buffer = try pool.makeMutablePixelBuffer()
    } catch {
        fail("no pixel buffer for \(url.lastPathComponent): \(error)")
    }
    let drawn = buffer.withUnsafeBuffer { pixels -> Bool in
        CVPixelBufferLockBaseAddress(pixels, [])
        defer { CVPixelBufferUnlockBaseAddress(pixels, []) }
        guard let context = CGContext(data: CVPixelBufferGetBaseAddress(pixels), width: width, height: height,
                                      bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixels), space: sRGB,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        else { return false }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return true
    }
    guard drawn else { fail("no context for \(url.lastPathComponent)") }
    buffer.attachments.colorPrimaries = .itu_R_709_2
    buffer.attachments.transferFunction = .sRGB
    do {
        try await receiver.append(CVReadOnlyPixelBuffer(buffer), with: CMTime(value: CMTimeValue(index), timescale: fps))
    } catch {
        fail("\(url.lastPathComponent): \(error)")
    }
}
receiver.finish()
await writer.finishWriting()
guard writer.status == .completed else { fail("not written: \(String(describing: writer.error))") }
let seconds = Double(frames.count) / Double(fps)
print("\(output.lastPathComponent): \(frames.count) frames, \(width) x \(height), \(fps) fps, \(String(format: "%.2f", seconds)) s")
