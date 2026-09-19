import Foundation

/// Extracts a numeric quantity from a Croatian voice transcript.
///
/// Strategy:
/// 1. Prefer a digit token already present in the text (iOS dictation for
///    hr-HR frequently converts spoken numbers to digits automatically).
/// 2. Fall back to parsing common spelled-out Croatian number words, which
///    covers the most frequent cases used when counting stock
///    ("dvadeset četiri", "pola", "dvanaest i pol"...).
///
/// This is a pragmatic MVP parser, not a full NLP number grammar — see
/// README "Known limitations" for edge cases it does not cover.
enum CroatianNumberParser {
    private static let units: [String: Double] = [
        "nula": 0, "jedan": 1, "jedna": 1, "dva": 2, "dvije": 2, "tri": 3,
        "cetiri": 4, "četiri": 4, "pet": 5, "sest": 6, "šest": 6,
        "sedam": 7, "osam": 8, "devet": 9, "deset": 10,
        "jedanaest": 11, "dvanaest": 12, "trinaest": 13,
        "cetrnaest": 14, "četrnaest": 14, "petnaest": 15,
        "sesnaest": 16, "šesnaest": 16, "sedamnaest": 17,
        "osamnaest": 18, "devetnaest": 19
    ]

    private static let tens: [String: Double] = [
        "dvadeset": 20, "trideset": 30, "cetrdeset": 40, "četrdeset": 40,
        "pedeset": 50, "sezdeset": 60, "šezdeset": 60,
        "sedamdeset": 70, "osamdeset": 80, "devedeset": 90
    ]

    private static let hundreds: [String: Double] = [
        "sto": 100, "sta": 100, "dvjesto": 200, "tristo": 300,
        "cetiristo": 400, "četiristo": 400, "petsto": 500
    ]

    private static let fractions: [String: Double] = [
        "pola": 0.5, "pol": 0.5, "polovica": 0.5,
        "cetvrt": 0.25, "četvrt": 0.25
    ]

    /// Words that are meaningful for number parsing but should also be
    /// stripped out when isolating the article reference from the transcript.
    private static let unitNoiseWords: Set<String> = [
        "i", "komad", "komada", "kom", "kilograma", "kilogram", "kg",
        "litara", "litra", "litre", "l", "puta", "grama", "gram"
    ]

    static func extractQuantity(from text: String) -> Double? {
        let lowered = text.lowercased()

        if let digitValue = firstDigitToken(in: lowered) {
            return digitValue
        }

        return parseWordNumber(lowered)
    }

    /// Returns the transcript with recognized number tokens/words removed,
    /// leaving (ideally) just the spoken article name.
    static func stripQuantity(from text: String) -> String {
        var result = text.lowercased()

        let pattern = #"\d+([.,]\d+)?"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: " ")
        }

        let numberWords = Set(units.keys)
            .union(tens.keys)
            .union(hundreds.keys)
            .union(fractions.keys)
            .union(unitNoiseWords)

        let remainingWords = result
            .split(separator: " ")
            .map(String.init)
            .filter { !numberWords.contains($0) }

        return remainingWords.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func firstDigitToken(in text: String) -> Double? {
        let pattern = #"\d+([.,]\d+)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let matchRange = Range(match.range, in: text) else { return nil }

        let raw = String(text[matchRange]).replacingOccurrences(of: ",", with: ".")
        return Double(raw)
    }

    private static func parseWordNumber(_ text: String) -> Double? {
        let words = text.split(separator: " ").map(String.init)
        var total: Double = 0
        var found = false
        var i = 0

        while i < words.count {
            let word = words[i]

            if let fraction = fractions[word] {
                total += fraction
                found = true
            } else if let hundred = hundreds[word] {
                total += hundred
                found = true
            } else if let ten = tens[word] {
                total += ten
                found = true
                if i + 1 < words.count, words[i + 1] == "i", i + 2 < words.count, let unit = units[words[i + 2]] {
                    total += unit
                    i += 2
                } else if i + 1 < words.count, let unit = units[words[i + 1]] {
                    total += unit
                    i += 1
                }
            } else if let unit = units[word] {
                total += unit
                found = true
            }

            i += 1
        }

        return found ? total : nil
    }
}
