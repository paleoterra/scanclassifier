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
            return 200
        }
    }

    func match(width: CGFloat) -> MatchType {
        self.expectedWidth <= width ? .match : .failed
    }
}
