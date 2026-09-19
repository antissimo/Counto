import Foundation

struct ParsedVoiceCommand {
    let articleText: String
    let quantity: Double?
}

/// First stage of the voice pipeline (spec section 12): turns a raw
/// transcript into an (article reference, quantity) pair. Never touches the
/// inventory directly — the result is only a proposal for confirmation.
enum VoiceCommandParser {
    static func parse(transcript: String) -> ParsedVoiceCommand {
        let quantity = CroatianNumberParser.extractQuantity(from: transcript)
        let articleText = CroatianNumberParser.stripQuantity(from: transcript)
        return ParsedVoiceCommand(articleText: articleText, quantity: quantity)
    }
}
