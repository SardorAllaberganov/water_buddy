//
//  MeasureContrast.swift
//  WaterBuddy — tooling, NOT a build input (spec docs/superpowers/specs/2026-11-22-set-c-design.md §3.9)
//
//  Run:  swift Tools/MeasureContrast.swift build/themes/<theme>-<runtime> Tools/theme-pairs.json [--boxes]
//  Faster, for a whole theme:  swiftc -O Tools/MeasureContrast.swift -o build/themes/measure && build/themes/measure …
//
//  WCAG 2 relative luminance, sRGB, at the capture's 3× pixels — the method `docs/DESIGN.md` records, kept in one
//  place this time (its probes lived in a scratch copy and were thrown away, L1730). For each pair, on each frame
//  `Tools/CaptureThemeCensus.sh` captured of its screen:
//  - the ink's box is found once per screen, on its first frame, by the pair's `find`:
//    - `frame` (the default): an element's own frame, from the census's `<theme>-<screen>-frames.json`;
//      `frameIndex` picks among elements sharing the label, in the walk's order;
//    - `text`: the drawn string, found by Vision's text recognition — `within` an element's frame where the pair
//      names one, `nth` in reading order where it is drawn more than once;
//    - `accent`: a shape in the theme's accent (the palette below) `within` an element — the `nth` in reading
//      order, or every one there as one box;
//    - `white`: a bright, unsaturated shape `within` an element, recognised text masked out — `nth`, or all;
//    - `holder`: the `within` element's own frame, for ink drawn at a fixed place inside it, its ground by hand;
//  - the ground is a ring around the box — 2–6 pt out for the `beside` yardstick, 10–14 pt for `clean` (four bands,
//    or the `bands` the pair names) — with other ink masked, grown by 1 pt: every line Vision reads (its band, so the
//    words beside a string drawn mid-line), and every element's frame that neither holds the box nor covers a quarter
//    of the screen (a container, or a pane, is ground, not ink); or, where the pair carries `rects`, rectangles
//    placed by hand beside the box and checked by eye on `--annotate`'s frame, as the doc's own probes placed theirs;
//  - the ground's figure is its lightest pixel: the worst place a white ink can stand;
//  - white ink is that pixel with white composited over it at the ink's opacity, in encoded sRGB, as the screen
//    composites; a rendered mark's ink is its own pixels, the 98th percentile.
//  A pair's figure is its worst frame. Out: one Markdown row per pair, the tightest margin first, beside the figure
//  `docs/DESIGN.md` recorded for this runtime where the pair carries one — the control a census is proved by.
//  `--boxes` adds each pair's located box, in points, to check a locator against a frame by eye.
//
//  Lives in `Tools/` because that directory belongs to no build target (rule `15-project`); run with `swift`, as
//  `GenerateAppIcon.swift` is.
//

import CoreGraphics
import Foundation
import ImageIO
import Vision

struct Pair: Decodable {
    let screen: String
    let element: String
    let kind: String
    let floor: Double
    let ink: String
    let inkOpacity: Double?
    let yardstick: String
    /// The figure `docs/DESIGN.md` recorded, by runtime ("27.0", "18.6").
    let recorded: [String: Double]?
    let note: String?
    let find: String?
    let frameIndex: Int?
    let text: String?
    let within: String?
    let withinIndex: Int?
    let nth: Int?
    /// The ground's sides, where the pair names them: a subset of `above`, `below`, `left`, `right` — the clean
    /// yardstick's bands, or the four sides of the beside yardstick's ring. A side that lies on a neighbour drawn
    /// without an element of its own — a bar above a weekday's letter, a figure above its label — is left out by
    /// hand, as the doc's probes moved a rectangle; the peak test cannot see a neighbour that is uniform.
    let bands: [String]?
    /// Rectangles of ground placed by hand, in points from the located box's top-left corner — `[dx, dy, w, h]` —
    /// checked by eye on an annotated frame (`--annotate`). Their lightest pixel is the ground, nothing masked: what
    /// they cover was chosen. They replace the yardstick's ring or bands, as the doc's own rectangles did.
    let rects: [[Double]]?
    /// `centre` measures `rects` from the box's centre instead — for a number inside a day's ring, whose box is as
    /// wide as the day's number.
    let rectsFrom: String?
    /// `[dx, dy, w, h]` from the `within` element's corner: the area to look in, where the ink has no element of its
    /// own and its holder is elsewhere — the month card's weekday row, under its heading.
    let withinOffset: [Double]?
    /// The ground is clipped to the `within` element's inside, as a pane (`Pane`): the doc's "clipped to its pane".
    let clip: Bool?
    /// A `white` shape may be a letter text recognition also read: the month's weekday row, read on one runtime and
    /// not the other. Recognised text is otherwise masked out of a white shape — a glyph beside a word is not the word.
    let textToo: Bool?
    /// The runtimes the pair exists on, where not every one: the app's own tab bar is drawn below iOS 26 only, and on
    /// 26 and later the same label is Apple's bar.
    let runtimes: [String]?
    /// Of the shapes `accent` or `white` finds, the one with the most pixels — a check beside a capsule's rim, which a
    /// lighter theme's glass lights white enough to pass for a mark.
    let largest: Bool?
}

/// Each theme's accent, transcribed from `WaterBuddy/WaterSurface.swift`'s palettes, as `GenerateAppIcon.swift`'s are:
/// a palette's change changes this table in the same change.
let accents: [String: (Double, Double, Double)] = [
    "aurora": (0.00, 0.85, 0.85), "lagoon": (0.25, 0.88, 0.75), "dusk": (1.00, 0.74, 0.30),
    "midnight": (0.40, 0.82, 1.00), "bloom": (1.00, 0.66, 0.78), "test": (0.00, 0.85, 0.85),
]

/// A frame in points.
struct Box {
    let x: Double, y: Double, w: Double, h: Double

    init(x: Double, y: Double, w: Double, h: Double) { (self.x, self.y, self.w, self.h) = (x, y, w, h) }
    init?(_ v: [Double]) {
        guard v.count == 4 else { return nil }
        self.init(x: v[0], y: v[1], w: v[2], h: v[3])
    }

    var area: Double { w * h }
    var described: String { String(format: "%.0f,%.0f %.0f×%.0f", x, y, w, h) }
    func grown(_ d: Double) -> Box { Box(x: x - d, y: y - d, w: w + 2 * d, h: h + 2 * d) }
    func holds(_ b: Box) -> Bool { x <= b.x && y <= b.y && x + w >= b.x + b.w && y + h >= b.y + b.h }
    func meets(_ b: Box) -> Bool { x < b.x + b.w && b.x < x + w && y < b.y + b.h && b.y < y + h }
    func holdsCentre(of b: Box) -> Bool {
        let (cx, cy) = (b.x + b.w / 2, b.y + b.h / 2)
        return cx >= x && cx <= x + w && cy >= y && cy <= y + h
    }
    /// Whether the centre of pixel (px, py), at `scale` pixels a point, lies inside.
    func covers(_ px: Int, _ py: Int, _ scale: Double) -> Bool {
        let (u, v) = ((Double(px) + 0.5) / scale, (Double(py) + 0.5) / scale)
        return u >= x && u < x + w && v >= y && v < y + h
    }
}

/// Reading order: top to bottom in 4-pt rows, then left to right.
func reading(_ a: Box, _ b: Box) -> Bool {
    let (ra, rb) = ((a.y / 4).rounded(.down), (b.y / 4).rounded(.down))
    return ra != rb ? ra < rb : a.x < b.x
}

/// WCAG 2 relative luminance of an encoded sRGB colour.
func luminance(_ c: (Double, Double, Double)) -> Double {
    func lin(_ v: Double) -> Double { v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4) }
    return 0.2126 * lin(c.0) + 0.7152 * lin(c.1) + 0.0722 * lin(c.2)
}

func ratio(_ a: Double, _ b: Double) -> Double { (max(a, b) + 0.05) / (min(a, b) + 0.05) }

/// A capture's pixels, decoded once into sRGB RGBA8, top row first.
struct Pixels {
    let width: Int, height: Int
    let image: CGImage
    private let data: [UInt8]

    init?(_ url: URL) {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
              let space = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        let (w, h) = (image.width, image.height)
        var bytes = [UInt8](repeating: 0, count: w * h * 4)
        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(data: buffer.baseAddress, width: w, height: h, bitsPerComponent: 8,
                                          bytesPerRow: w * 4, space: space,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
            return true
        }
        guard drawn else { return nil }
        (width, height, self.image, data) = (w, h, image, bytes)
    }

    func rgb(_ x: Int, _ y: Int) -> (Double, Double, Double) {
        let i = (y * width + x) * 4
        return (Double(data[i]) / 255, Double(data[i + 1]) / 255, Double(data[i + 2]) / 255)
    }
}

/// One line Vision read, with the means to box any run of it.
struct Line {
    let string: String
    let candidate: VNRecognizedText
    let box: Box
}

/// Straight quotes and plain spaces, lower case: one character for one, so an offset in one is an offset in the other.
func folded(_ s: String) -> [Character] {
    Array(s.map { c -> Character in
        switch c {
        case "\u{2019}", "\u{2018}": return "'"
        case "\u{201C}", "\u{201D}": return "\""
        case "\u{202F}", "\u{00A0}": return " "
        default: return Character(c.lowercased().count == 1 ? c.lowercased() : String(c))
        }
    })
}

func pointBox(_ r: CGRect, _ size: (Double, Double)) -> Box {
    Box(x: r.minX * size.0, y: (1 - r.maxY) * size.1, w: r.width * size.0, h: r.height * size.1)
}

func recognise(_ px: Pixels, scale: Double) -> [Line] {
    let request = VNRecognizeTextRequest()
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
    request.recognitionLanguages = ["en-US", "ru-RU"]
    try? VNImageRequestHandler(cgImage: px.image, options: [:]).perform([request])
    let size = (Double(px.width) / scale, Double(px.height) / scale)
    return (request.results ?? []).compactMap { observation in
        guard let candidate = observation.topCandidates(1).first else { return nil }
        return Line(string: candidate.string, candidate: candidate, box: pointBox(observation.boundingBox, size))
    }
}

/// A pattern for `text`: its words as written, each `<…>` a run of any characters — the page's own words, which a
/// pair cannot spell ahead of the census (an insight's sentence, a month's figures). A text that is all placeholder
/// is a whole line.
func pattern(_ text: String) -> NSRegularExpression? {
    var body = ""
    var rest = Substring(text)
    while !rest.isEmpty {
        if rest.hasPrefix("⟦"), let close = rest.firstIndex(of: "⟧") {
            // A region's two spellings of one value — a date's order, a clock's 12 or 24 hours.
            let options = rest[rest.index(after: rest.startIndex)..<close].split(separator: "|", omittingEmptySubsequences: false)
            body += "(?:" + options.map { NSRegularExpression.escapedPattern(for: String(folded(String($0)))) }.joined(separator: "|") + ")"
            rest = rest[rest.index(after: close)...]
        } else if rest.hasPrefix("<"), let close = rest.firstIndex(of: ">") {
            body += ".+?"
            rest = rest[rest.index(after: close)...]
        } else {
            let next = rest.firstIndex(where: { $0 == "⟦" || $0 == "<" }) ?? rest.endIndex
            let stop = next == rest.startIndex ? rest.index(after: next) : next
            body += NSRegularExpression.escapedPattern(for: String(folded(String(rest[..<stop]))))
            rest = rest[stop...]
        }
    }
    // A thousands separator as any region draws it — a comma, a point, a space, or none: "1,300" reads "1 300".
    body = body.replacingOccurrences(of: #"(?<=\d),(?=\d{3})"#, with: "[,. ]?", options: .regularExpression)
    if body == ".+?" { body = "^.+$" }
    // A run that ends the text runs to the end of the line: "12/23", never "12/2".
    if body.hasSuffix(".+?") { body = String(body.dropLast()) }
    return try? NSRegularExpression(pattern: body)
}

/// Every place `text` is drawn, as boxes in reading order.
func occurrences(of text: String, in lines: [Line], size: (Double, Double)) -> [Box] {
    guard !text.isEmpty, let regex = pattern(text) else { return [] }
    var found: [Box] = []
    for line in lines {
        // One character for one: an offset in the folded line is an offset in the line Vision read.
        let hay = String(folded(line.string))
        for match in regex.matches(in: hay, range: NSRange(hay.startIndex..., in: hay)) where match.range.length > 0 {
            guard let range = Range(match.range, in: hay) else { continue }
            let (start, count) = (hay.distance(from: hay.startIndex, to: range.lowerBound), hay.distance(from: range.lowerBound, to: range.upperBound))
            if count == hay.count {
                found.append(line.box)
                continue
            }
            let from = line.string.index(line.string.startIndex, offsetBy: start)
            let to = line.string.index(from, offsetBy: count)
            if let sub = try? line.candidate.boundingBox(for: from..<to) {
                found.append(pointBox(sub.boundingBox, size))
            } else {
                found.append(line.box)
            }
        }
    }
    return found.sorted(by: reading)
}

/// The census's dates, spelled as the app spells them in English (`<Weekday, Month D>`, `<Month YYYY>`, `<D T>`,
/// and for k days back `<Weekday T-k>`, `<Letter T-k>`, `<Date T-k>`, `<D T-k>`), from the day the screen was taken.
func dated(_ s: String, on day: Date) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current
    let format = { (pattern: String, date: Date) -> String in
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.calendar = calendar
        f.timeZone = .current
        f.dateFormat = pattern
        return f.string(from: date)
    }
    // The census's region decides the order — "Monday, November 23" or "Monday, 23 November" — so both stand.
    let either = { (date: Date) in "⟦\(format("EEEE, MMMM d", date))|\(format("EEEE, d MMMM", date))⟧" }
    var out = s
        .replacingOccurrences(of: "<Weekday, Month D>", with: either(day))
        .replacingOccurrences(of: "<Month YYYY>", with: format("MMMM yyyy", day))
        .replacingOccurrences(of: "<D T>", with: format("d", day))
    for k in 1...6 {
        guard let back = calendar.date(byAdding: .day, value: -k, to: day) else { continue }
        let weekday = format("EEEE", back)
        out = out
            .replacingOccurrences(of: "<Weekday T-\(k)>", with: weekday)
            .replacingOccurrences(of: "<Letter T-\(k)>", with: String(weekday.prefix(1)))
            .replacingOccurrences(of: "<Date T-\(k)>", with: either(back))
            .replacingOccurrences(of: "<D T-\(k)>", with: format("d", back))
    }
    // A time as a 12-hour clock writes it, or as a 24-hour one: "1:30 PM" or "13:30", "6 AM" or "06".
    let clock = try! NSRegularExpression(pattern: #"\b(\d{1,2})(?::(\d{2}))?[ \x{202F}\x{00A0}](AM|PM)\b"#)
    let whole = NSRange(out.startIndex..., in: out)
    for match in clock.matches(in: out, range: whole).reversed() {
        guard let all = Range(match.range, in: out), let h = Range(match.range(at: 1), in: out),
              let half = Range(match.range(at: 3), in: out), var hour = Int(out[h]) else { continue }
        let minutes = Range(match.range(at: 2), in: out).map { String(out[$0]) }
        if out[half] == "PM", hour < 12 { hour += 12 }
        if out[half] == "AM", hour == 12 { hour = 0 }
        let twentyFour = String(format: "%02d", hour) + (minutes.map { ":\($0)" } ?? "")
        out.replaceSubrange(all, with: "⟦\(out[all])|\(twentyFour)⟧")
    }
    return out
}

/// The shapes in `region` whose pixels pass `test`, 4-connected, in reading order; specks under 6 px dropped.
func shapes(in region: Box, of px: Pixels, scale: Double, where test: (Int, Int) -> Bool) -> [(box: Box, pixels: Int)] {
    let x0 = max(0, Int(region.x * scale)), x1 = min(px.width - 1, Int((region.x + region.w) * scale))
    let y0 = max(0, Int(region.y * scale)), y1 = min(px.height - 1, Int((region.y + region.h) * scale))
    guard x0 <= x1, y0 <= y1 else { return [] }
    let (w, h) = (x1 - x0 + 1, y1 - y0 + 1)
    var on = [Bool](repeating: false, count: w * h)
    for y in 0..<h { for x in 0..<w where test(x0 + x, y0 + y) { on[y * w + x] = true } }
    var seen = [Bool](repeating: false, count: w * h)
    var found: [(box: Box, pixels: Int)] = []
    for start in 0..<(w * h) where on[start] && !seen[start] {
        var stack = [start], count = 0
        var (minX, minY, maxX, maxY) = (Int.max, Int.max, Int.min, Int.min)
        seen[start] = true
        while let i = stack.popLast() {
            count += 1
            let (x, y) = (i % w, i / w)
            (minX, minY, maxX, maxY) = (min(minX, x), min(minY, y), max(maxX, x), max(maxY, y))
            for (nx, ny) in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)] where nx >= 0 && ny >= 0 && nx < w && ny < h {
                let j = ny * w + nx
                if on[j] && !seen[j] { seen[j] = true; stack.append(j) }
            }
        }
        guard count >= 6 else { continue }
        found.append((Box(x: Double(x0 + minX) / scale, y: Double(y0 + minY) / scale,
                          w: Double(maxX - minX + 1) / scale, h: Double(maxY - minY + 1) / scale), count))
    }
    return found.sorted { reading($0.box, $1.box) }
}

func union(_ boxes: [Box]) -> Box? {
    guard let first = boxes.first else { return nil }
    let x0 = boxes.map(\.x).min()!, y0 = boxes.map(\.y).min()!
    let x1 = boxes.map { $0.x + $0.w }.max()!, y1 = boxes.map { $0.y + $0.h }.max()!
    return boxes.count == 1 ? first : Box(x: x0, y: y0, w: x1 - x0, h: y1 - y0)
}

/// An element's frame by its label — the `index`th of the frames sharing it, in the walk's order. A label with the
/// page's own words in it matches every label of that shape, the first by name.
func element(_ label: String?, _ index: Int?, in frames: [String: [Box]]) -> Box? {
    guard let label else { return nil }
    let all: [Box]
    if frames[label] == nil, let regex = pattern(label) {
        let key = frames.keys.sorted().first { key in
            let k = String(folded(key))
            return regex.firstMatch(in: k, range: NSRange(k.startIndex..., in: k)).map { $0.range.length == (k as NSString).length } ?? false
        }
        all = key.flatMap { frames[$0] } ?? []
    } else {
        all = frames[label] ?? []
    }
    let i = (index ?? 1) - 1
    return all.indices.contains(i) ? all[i] : nil
}

/// The area a pair's ink is looked for in: the `within` element's frame, moved by `withinOffset` where the pair
/// carries one — a row drawn under a heading with no element of its own — or the whole screen.
func searchArea(of pair: Pair, frames: [String: [Box]], size: (Double, Double)) -> Result<Box, LocateError> {
    guard let label = pair.within else { return .success(Box(x: 0, y: 0, w: size.0, h: size.1)) }
    guard let holder = element(label, pair.withinIndex, in: frames) else { return .failure(.init("within not found: \(label)")) }
    guard let o = pair.withinOffset, o.count == 4 else { return .success(holder) }
    return .success(Box(x: holder.x + o[0], y: holder.y + o[1], w: o[2], h: o[3]))
}

/// A pane's inside: its frame inset by 3 pt — its rim and the rim's glow — at `LiquidGlass.cornerRadius` (28) less
/// the inset, for a ground the doc's walks "clipped to its pane".
struct Pane {
    let frame: Box
    let radius: Double

    init(_ holder: Box) { (frame, radius) = (holder.grown(-3), max(0, 28 - 3)) }

    func covers(_ px: Int, _ py: Int, _ scale: Double) -> Bool {
        let (u, v) = ((Double(px) + 0.5) / scale, (Double(py) + 0.5) / scale)
        guard u >= frame.x, u < frame.x + frame.w, v >= frame.y, v < frame.y + frame.h else { return false }
        let r = min(radius, frame.w / 2, frame.h / 2)
        let cx = min(max(u, frame.x + r), frame.x + frame.w - r), cy = min(max(v, frame.y + r), frame.y + frame.h - r)
        return (u - cx) * (u - cx) + (v - cy) * (v - cy) <= r * r
    }
}

/// Where a pair's ink is, or why it cannot be found.
func locate(_ pair: Pair, frames: [String: [Box]], lines: [Line], px: Pixels, scale: Double, theme: String)
    -> Result<Box, LocateError> {
    let size = (Double(px.width) / scale, Double(px.height) / scale)
    let area: Box
    switch searchArea(of: pair, frames: frames, size: size) {
    case .success(let box): area = box
    case .failure(let error): return .failure(error)
    }
    func pick(_ all: [Box]) -> Box? {
        if let n = pair.nth { return all.indices.contains(n - 1) ? all[n - 1] : nil }
        return pair.find == "text" ? all.first : union(all)
    }
    func pickShape(_ all: [(box: Box, pixels: Int)]) -> Box? {
        pair.largest == true ? all.max(by: { $0.pixels < $1.pixels })?.box : pick(all.map(\.box))
    }
    switch pair.find ?? "frame" {
    case "frame":
        return element(pair.element, pair.frameIndex, in: frames).map { .success($0) } ?? .failure(.init("element not found"))
    case "holder":
        // The holder's own frame, for ink drawn at a fixed place inside it — a day's letter, the goal line across
        // its column — whose ground is placed by hand from the holder's corner (`rects`).
        return pair.within == nil ? .failure(.init("a holder needs `within`")) : .success(area)
    case "text":
        let wanted = pair.text ?? pair.element
        let found = occurrences(of: wanted, in: lines, size: size).filter { area.holdsCentre(of: $0) }
        if let box = pick(found) { return .success(box) }
        // A sentence the layout wraps is read as several lines, each a piece of it: their boxes, as one.
        let whole = String(folded(wanted))
        let pieces = lines.filter { line in
            let piece = String(folded(line.string)).trimmingCharacters(in: .whitespaces)
            return piece.count >= 6 && whole.contains(piece) && area.holdsCentre(of: line.box)
        }
        if !wanted.contains("<"), pieces.map(\.string.count).reduce(0, +) * 10 >= whole.count * 6, let box = union(pieces.map(\.box)) {
            return .success(box)
        }
        return .failure(.init("text not read: \(wanted)"))
    case "accent":
        guard let accent = accents[theme] else { return .failure(.init("no accent for \(theme)")) }
        let found = shapes(in: area, of: px, scale: scale) { x, y in isAccent(px.rgb(x, y), accent) }
        return pickShape(found).map { .success($0) } ?? .failure(.init("no accent shape"))
    case "white":
        let text = pair.textToo == true ? [] : lines.map { $0.box.grown(1) }
        let found = shapes(in: area, of: px, scale: scale) { x, y in
            isWhite(px.rgb(x, y)) && !text.contains(where: { $0.covers(x, y, scale) })
        }
        return pickShape(found).map { .success($0) } ?? .failure(.init("no white shape"))
    default:
        return .failure(.init("find \(pair.find ?? "") is measured by hand"))
    }
}

/// A pixel in the theme's accent, and a bright, unsaturated one: what `find` looks for, and what a found shape's
/// rendered ink is read from — the white number inside a met day's ring is not the ring's ink.
func isAccent(_ c: (Double, Double, Double), _ accent: (Double, Double, Double)) -> Bool {
    abs(c.0 - accent.0) + abs(c.1 - accent.1) + abs(c.2 - accent.2) <= 0.36
}
func isWhite(_ c: (Double, Double, Double)) -> Bool {
    let (hi, lo) = (max(c.0, c.1, c.2), min(c.0, c.1, c.2))
    return lo >= 0.55 && hi - lo <= 0.15
}

struct LocateError: Error {
    let reason: String
    init(_ reason: String) { self.reason = reason }
}

/// The ring 2–6 pt around `box`, as four sides — above and below its full width, left and right between them — or
/// the sides the pair names.
func ringSides(around box: Box, sides: [String]?) -> [Box] {
    let all = [("above", Box(x: box.x - 6, y: box.y - 6, w: box.w + 12, h: 4)),
               ("below", Box(x: box.x - 6, y: box.y + box.h + 2, w: box.w + 12, h: 4)),
               ("left", Box(x: box.x - 6, y: box.y - 2, w: 4, h: box.h + 4)),
               ("right", Box(x: box.x + box.w + 2, y: box.y - 2, w: 4, h: box.h + 4))]
    return all.filter { sides?.contains($0.0) ?? true }.map(\.1)
}

/// The lightest pixel of the ring 2–6 pt around `box` (or of its named sides), other ink masked: the ground beside
/// the glyphs.
func ringGround(_ box: Box, sides: [String]?, masks: [Box], pane: Pane?, in px: Pixels, scale: Double)
    -> (Double, (Double, Double, Double))? {
    var ground = -1.0, lightest = (0.0, 0.0, 0.0)
    for side in ringSides(around: box, sides: sides) {
        let x0 = max(0, Int(side.x * scale)), x1 = min(px.width - 1, Int((side.x + side.w) * scale))
        let y0 = max(0, Int(side.y * scale)), y1 = min(px.height - 1, Int((side.y + side.h) * scale))
        guard x0 <= x1, y0 <= y1 else { continue }
        for y in y0...y1 {
            for x in x0...x1 where pane?.covers(x, y, scale) ?? true && !masks.contains(where: { $0.covers(x, y, scale) }) {
                let c = px.rgb(x, y)
                let l = luminance(c)
                if l > ground { (ground, lightest) = (l, c) }
            }
        }
    }
    return ground >= 0 ? (ground, lightest) : nil
}

/// The four clean bands around `box`, by side, 10–14 pt out and the text's own length.
func cleanBands(around box: Box, sides: [String]?) -> [Box] {
    let all = [("above", Box(x: box.x, y: box.y - 14, w: box.w, h: 4)),
               ("below", Box(x: box.x, y: box.y + box.h + 10, w: box.w, h: 4)),
               ("left", Box(x: box.x - 14, y: box.y, w: 4, h: box.h)),
               ("right", Box(x: box.x + box.w + 10, y: box.y, w: 4, h: box.h))]
    return all.filter { sides?.contains($0.0) ?? true }.map(\.1)
}

/// A pair's hand-placed rectangles, in points on the screen.
func handRects(_ rects: [[Double]], from box: Box, centre: Bool) -> [Box] {
    let (ox, oy) = centre ? (box.x + box.w / 2, box.y + box.h / 2) : (box.x, box.y)
    return rects.compactMap(Box.init).map { Box(x: ox + $0.x, y: oy + $0.y, w: $0.w, h: $0.h) }
}

/// The ground a pair is read on, as areas to draw on an annotated frame.
func groundAreas(of pair: Pair, box: Box) -> [Box] {
    if let rects = pair.rects { return handRects(rects, from: box, centre: pair.rectsFrom == "centre") }
    return pair.yardstick == "beside" ? ringSides(around: box, sides: pair.bands) : cleanBands(around: box, sides: pair.bands)
}

/// Clean ground: four bands 10–14 pt above, below, left and right of `box`, the text's own length, or the sides the
/// pair names. A band that meets other ink — an element's frame, a recognised line — or holds a sharp bright peak (a
/// rim, a glyph, a glow: its 99th percentile over twice its median) is dropped, as the doc's probes moved a rectangle
/// off a rim; the lightest pixel of the bands left is the ground.
func cleanGround(_ box: Box, sides: [String]?, masks: [Box], pane: Pane?, in px: Pixels, scale: Double)
    -> (Double, (Double, Double, Double))? {
    var ground = -1.0, lightest = (0.0, 0.0, 0.0)
    for band in cleanBands(around: box, sides: sides) where !masks.contains(where: { $0.meets(band) }) {
        let x0 = max(0, Int(band.x * scale)), x1 = min(px.width - 1, Int((band.x + band.w) * scale))
        let y0 = max(0, Int(band.y * scale)), y1 = min(px.height - 1, Int((band.y + band.h) * scale))
        guard x0 < x1, y0 < y1 else { continue }
        var pixels: [(Double, (Double, Double, Double))] = []
        for y in y0...y1 {
            for x in x0...x1 where pane?.covers(x, y, scale) ?? true { let c = px.rgb(x, y); pixels.append((luminance(c), c)) }
        }
        guard !pixels.isEmpty else { continue }
        let sorted = pixels.map(\.0).sorted()
        let (median, high) = (sorted[sorted.count / 2], sorted[Int(Double(sorted.count - 1) * 0.99)])
        guard high <= 2 * median + 0.04 else { continue }
        if let top = pixels.max(by: { $0.0 < $1.0 }), top.0 > ground { (ground, lightest) = top }
    }
    return ground >= 0 ? (ground, lightest) : nil
}

/// The lightest pixel of rectangles placed by hand, nothing masked.
func handGround(_ areas: [Box], pane: Pane?, in px: Pixels, scale: Double) -> (Double, (Double, Double, Double))? {
    var ground = -1.0, lightest = (0.0, 0.0, 0.0)
    for area in areas {
        let x0 = max(0, Int(area.x * scale)), x1 = min(px.width - 1, Int((area.x + area.w) * scale) - 1)
        let y0 = max(0, Int(area.y * scale)), y1 = min(px.height - 1, Int((area.y + area.h) * scale) - 1)
        guard x0 <= x1, y0 <= y1 else { continue }
        for y in y0...y1 {
            for x in x0...x1 where pane?.covers(x, y, scale) ?? true {
                let c = px.rgb(x, y)
                let l = luminance(c)
                if l > ground { (ground, lightest) = (l, c) }
            }
        }
    }
    return ground >= 0 ? (ground, lightest) : nil
}

/// One pair's figure on one frame, or nil when no ground is left to read. A rendered mark found by its colour —
/// `accent` or `white` — is read from its own pixels in its box, never from what else the box holds.
func figure(for pair: Pair, box: Box, masks: [Box], pane: Pane?, accent: (Double, Double, Double)?, in px: Pixels,
            scale: Double) -> Double? {
    let read = pair.rects.map { handGround(handRects($0, from: box, centre: pair.rectsFrom == "centre"), pane: pane, in: px, scale: scale) }
        ?? (pair.yardstick == "beside"
            ? ringGround(box, sides: pair.bands, masks: masks, pane: pane, in: px, scale: scale)
            : cleanGround(box, sides: pair.bands, masks: masks, pane: pane, in: px, scale: scale))
    guard let (ground, lightest) = read else { return nil }

    if pair.ink == "white" {
        let a = pair.inkOpacity ?? 1
        let ink = luminance((a + (1 - a) * lightest.0, a + (1 - a) * lightest.1, a + (1 - a) * lightest.2))
        return ratio(ink, ground)
    }
    var values: [Double] = []
    let bx0 = max(0, Int(box.x * scale)), bx1 = min(px.width - 1, Int((box.x + box.w) * scale))
    let by0 = max(0, Int(box.y * scale)), by1 = min(px.height - 1, Int((box.y + box.h) * scale))
    guard bx0 <= bx1, by0 <= by1 else { return nil }
    let own: ((Double, Double, Double)) -> Bool = {
        switch pair.find {
        case "accent": return { c in accent.map { isAccent(c, $0) } ?? true }
        case "white": return isWhite
        default: return { _ in true }
        }
    }()
    for y in by0...by1 { for x in bx0...bx1 { let c = px.rgb(x, y); if own(c) { values.append(luminance(c)) } } }
    guard !values.isEmpty else { return nil }
    values.sort()
    return ratio(values[Int(Double(values.count - 1) * 0.98)], ground)
}

/// The options that take a value: `--lines <screen>` (what Vision reads there, and every element's frame),
/// `--only <screen>` (that screen alone) and `--annotate <dir>` (each screen's first frame, with every pair's box
/// outlined in red and its ground in yellow, written to `<dir>/<theme>-<screen>-annotated.png`, to check a box or a
/// hand-placed rectangle by eye).
let valued = ["--lines", "--only", "--annotate"]
func option(_ name: String) -> String? {
    CommandLine.arguments.firstIndex(of: name).flatMap {
        CommandLine.arguments.indices.contains($0 + 1) ? CommandLine.arguments[$0 + 1] : nil
    }
}
let linesFor = option("--lines"), onlyScreen = option("--only"), annotateDir = option("--annotate")
let args = CommandLine.arguments.enumerated().filter { i, a in
    a != "--boxes" && !valued.contains(a) && (i == 0 || !valued.contains(CommandLine.arguments[i - 1]))
}.map(\.element)
let showBoxes = CommandLine.arguments.contains("--boxes")
guard args.count == 3 else {
    print("usage: swift Tools/MeasureContrast.swift <capture-dir> <pairs.json> [--boxes] [--only <screen>] "
          + "[--lines <screen>] [--annotate <dir>]")
    exit(2)
}

/// The first frame with every located box outlined in red and its ground in yellow (a ring's two edges, a clean
/// side's band, a hand-placed rectangle), as a PNG.
func annotate(_ px: Pixels, boxes: [(ink: Box, ground: [Box])], scale: Double, to url: URL) {
    guard let space = CGColorSpace(name: CGColorSpace.sRGB),
          let context = CGContext(data: nil, width: px.width, height: px.height, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return }
    context.draw(px.image, in: CGRect(x: 0, y: 0, width: px.width, height: px.height))
    func stroke(_ b: Box, _ r: CGFloat, _ g: CGFloat, _ bl: CGFloat) {
        context.setStrokeColor(red: r, green: g, blue: bl, alpha: 1)
        context.setLineWidth(1)
        context.stroke(CGRect(x: b.x * scale, y: Double(px.height) - (b.y + b.h) * scale, width: b.w * scale,
                              height: b.h * scale).insetBy(dx: 0.5, dy: 0.5))
    }
    for (ink, ground) in boxes {
        ground.forEach { stroke($0, 1, 0.9, 0) }
        stroke(ink, 1, 0, 0)
    }
    guard let image = context.makeImage(),
          let destination = CGImageDestinationCreateWithURL(url as CFURL, "public.png" as CFString, 1, nil) else { return }
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
}
let dir = URL(fileURLWithPath: args[1])
let pairs = try JSONDecoder().decode([Pair].self, from: Data(contentsOf: URL(fileURLWithPath: args[2])))
let parts = dir.lastPathComponent.split(separator: "-").map(String.init)
let (theme, runtime) = (parts.first ?? "", parts.last ?? "")
let files = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
let scale = 3.0

struct Row {
    let pair: Pair
    var box: Box?
    var worst = Double.infinity
    var frame = "—"
    var problem: String?
}
var rows: [Row] = []
var uncaptured: [String: Int] = [:]

/// A pair as measured on one capture: "T-n" spelled out for each of the six days before, and every date resolved.
func variants(of pair: Pair, on day: Date) -> [Pair] {
    let spread = [pair.text, pair.within, Optional(pair.element)].contains { $0?.contains("T-n") ?? false }
    return (spread ? Array(1...6) : [0]).map { k in
        let spell = { (s: String?) -> String? in
            s.map { dated(k == 0 ? $0 : $0.replacingOccurrences(of: "T-n", with: "T-\(k)"), on: day) }
        }
        return Pair(screen: pair.screen, element: spell(pair.element) ?? pair.element, kind: pair.kind, floor: pair.floor,
                    ink: pair.ink, inkOpacity: pair.inkOpacity, yardstick: pair.yardstick, recorded: pair.recorded,
                    note: pair.note, find: pair.find, frameIndex: pair.frameIndex, text: spell(pair.text),
                    within: spell(pair.within), withinIndex: pair.withinIndex, nth: pair.nth, bands: pair.bands,
                    rects: pair.rects, rectsFrom: pair.rectsFrom, withinOffset: pair.withinOffset, clip: pair.clip,
                    textToo: pair.textToo, runtimes: pair.runtimes, largest: pair.largest)
    }
}

for screen in Set(pairs.map(\.screen)).sorted() where onlyScreen.map({ $0 == screen }) ?? true {
    let wanted = pairs.filter { $0.screen == screen && ($0.runtimes?.contains(runtime) ?? true) }
    guard let framesFile = files.first(where: { $0.lastPathComponent.hasSuffix("-\(screen)-frames.json") }),
          let raw = (try? JSONSerialization.jsonObject(with: Data(contentsOf: framesFile))) as? [String: Any] else {
        uncaptured[screen] = wanted.count
        continue
    }
    // The day the screen was taken, for its dates: the census writes its frames as it captures.
    let day = (try? framesFile.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date()
    // Every element's frames by label, in the walk's order; a census from before the census kept them all has one.
    var frames: [String: [Box]] = [:]
    for (label, value) in raw {
        if let many = value as? [[Double]] { frames[label] = many.compactMap(Box.init) }
        else if let one = value as? [Double], let box = Box(one) { frames[label] = [box] }
    }
    // This screen's frames alone, `<theme>-<screen>-NN.png`: `settings` is a prefix of `settings-lower`.
    let shots = files.filter { file in
        let name = file.lastPathComponent
        guard file.pathExtension == "png", let mark = name.range(of: "-\(screen)-", options: .backwards) else { return false }
        let number = name[mark.upperBound...].dropLast(4)
        return !number.isEmpty && number.allSatisfy(\.isNumber) && name[..<mark.lowerBound] == Substring(theme)
    }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    guard let first = shots.first, let firstPixels = Pixels(first) else {
        rows += wanted.map { Row(pair: $0, problem: "no frames") }
        continue
    }
    let lines = recognise(firstPixels, scale: scale)
    if linesFor == screen {
        // `--lines <screen>`: what Vision reads there, and every element's frame, to write a locator against.
        for line in lines.sorted(by: { reading($0.box, $1.box) }) { print("line  \(line.box.described)  \(line.string)") }
        for (label, boxes) in frames.sorted(by: { $0.key < $1.key }) {
            print("frame \(boxes.map(\.described).joined(separator: " ; "))  \(label.prefix(90))")
        }
    }
    let screenArea = Double(firstPixels.width * firstPixels.height) / (scale * scale)
    let elementBoxes = frames.values.flatMap { $0 }.filter { $0.area <= screenArea / 4 }

    // Each variant of each pair, located once on the first frame, with its masks.
    struct Probe { let row: Int; let pair: Pair; let box: Box; let masks: [Box]; let pane: Pane? }
    var screenRows = wanted.map { Row(pair: $0) }
    var probes: [Probe] = []
    for (i, pair) in wanted.enumerated() {
        for variant in variants(of: pair, on: day) {
            switch locate(variant, frames: frames, lines: lines, px: firstPixels, scale: scale, theme: theme) {
            case .success(let box):
                let (_, outer) = variant.yardstick == "beside" ? (2.0, 6.0) : (10.0, 14.0)
                let ring = box.grown(outer)
                // Every recognised line is other ink, the pair's own included: a line's box is its own band, so
                // masking it removes only the words beside a string drawn mid-line, never the ground above and below.
                // A frame that holds the box, to within 4 pt — recognition overshoots a glyph's edge by up to 3 — is
                // its container.
                let others = elementBoxes.filter { !$0.grown(4).holds(box) } + lines.map(\.box)
                // A ground clipped to its pane: the `within` element's inside (`clip`).
                let pane = variant.clip == true ? element(variant.within, variant.withinIndex, in: frames).map(Pane.init) : nil
                probes.append(Probe(row: i, pair: variant, box: box, masks: others.map { $0.grown(1) }.filter { $0.meets(ring) },
                                    pane: pane))
            case .failure(let error):
                if screenRows[i].problem == nil { screenRows[i].problem = error.reason }
            }
        }
    }
    if let annotateDir {
        let marked = probes.map { (ink: $0.box, ground: groundAreas(of: $0.pair, box: $0.box)) }
        annotate(firstPixels, boxes: marked, scale: scale,
                 to: URL(fileURLWithPath: annotateDir).appendingPathComponent("\(theme)-\(screen)-annotated.png"))
    }
    for shot in shots {
        let decoded: Pixels? = shot == first ? firstPixels : Pixels(shot)
        guard let px = decoded else { continue }
        for probe in probes {
            guard let value = figure(for: probe.pair, box: probe.box, masks: probe.masks, pane: probe.pane,
                                     accent: accents[theme], in: px, scale: scale) else { continue }
            if value < screenRows[probe.row].worst {
                (screenRows[probe.row].worst, screenRows[probe.row].frame, screenRows[probe.row].box) =
                    (value, shot.lastPathComponent, probe.box)
            }
        }
    }
    for i in screenRows.indices {
        // A pair any of whose variants was measured stands on its worst; one none of whose was, on its reason.
        if screenRows[i].worst < .infinity { screenRows[i].problem = nil }
        else if screenRows[i].problem == nil { screenRows[i].problem = "no ground" }
    }
    rows += screenRows
}

func cell(_ v: Double) -> String { String(format: "%.2f", v) }
let ordered = rows.sorted { a, b in
    switch (a.problem, b.problem) {
    case (.some, .none): return true
    case (.none, .some): return false
    case (.some, .some): return a.pair.screen < b.pair.screen
    case (.none, .none): return a.worst - a.pair.floor < b.worst - b.pair.floor
    }
}
let boxHeader = showBoxes ? " Box (pt) |" : ""
let boxRule = showBoxes ? "---|" : ""
print("| Screen | Element | Kind | Yardstick | Floor | Worst | Frame | Margin | Recorded (\(runtime)) | Δ |\(boxHeader)")
print("|---|---|---|---|---|---|---|---|---|---|\(boxRule)")
var under = 0, unmeasured = 0, adrift = 0
for row in ordered {
    let p = row.pair
    let name = p.text.map { "\(p.element) — “\($0)”" } ?? p.element
    let boxCell = showBoxes ? " \(row.box?.described ?? "—") |" : ""
    if let problem = row.problem {
        unmeasured += 1
        print("| \(p.screen) | \(name) | \(p.kind) | \(p.yardstick) | \(p.floor) | **\(problem)** | — | — | — | — |\(boxCell)")
        continue
    }
    let margin = row.worst - p.floor
    if margin < 0 { under += 1 }
    let recorded = p.recorded?[runtime]
    let delta = recorded.map { row.worst - $0 }
    if let delta, abs(delta) > 0.06 { adrift += 1 }
    print("| \(p.screen) | \(name) | \(p.kind) | \(p.yardstick) | \(p.floor) | \(cell(row.worst)) | \(row.frame) | "
          + "\(String(format: "%+.2f", margin)) | \(recorded.map(cell) ?? "—") | \(delta.map { String(format: "%+.2f", $0) } ?? "—") |\(boxCell)")
}
print("")
print("\(rows.count) pairs on the screens captured: \(under) under their floor, \(unmeasured) not measured, "
      + "\(adrift) more than 0.06 from the recorded figure.")
if !uncaptured.isEmpty {
    let list = uncaptured.keys.sorted().map { "\($0) (\(uncaptured[$0]!))" }.joined(separator: ", ")
    print("\(uncaptured.values.reduce(0, +)) pairs on screens this capture does not hold: \(list).")
}
