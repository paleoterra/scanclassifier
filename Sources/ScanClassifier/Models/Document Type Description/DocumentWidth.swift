import Foundation

public enum DocumentWidth: String, Codable {
    case wide
    case narrow
    case anySize

    var expectedWidth: CGFloat {
        switch self {
        case .wide, .anySize:
            return 10000
        case .narrow:
            return 300
        }
    }

    func match(width: CGFloat, verbose: Bool) -> MatchType {
        var result: MatchType = .failed

        switch self {
        case .anySize:
            result = .match
        case .wide:
            result = width >= 300 ? .match : .failed
        case .narrow:
            result = width <= 300 ? .match : .failed
        }
        Logging.verbosePrint(verbose: verbose, content: "Width Match: expected \(expectedWidth), actual: \(width), result: \(result)")
        return result
    }
}
