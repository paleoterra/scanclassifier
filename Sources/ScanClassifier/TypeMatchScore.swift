//
//  File.swift
//  
//
//  Created by Thomas Moore on 8/7/22.
//

import Foundation

public struct TypeMatchScore {
    public enum Score {
        case match
        case strong
        case weak
        case fail
    }

    public init(results: [MatchType]) {
        self.results = results
    }

    public var results: [MatchType]

    public var matchScore: Score {
        if isStrong {
            return .strong
        } else if isMatched {
            return .match
        } else if isWeak {
            return .weak
        }
        return .fail
    }

    public var isMatched: Bool {
        if results.contains(.failed) {
            return false
        } else if results.contains(.match) {
            return true
        }
        return false
    }

    public var isStrong: Bool {
        guard isMatched else {
            return false
        }
        return matchCount() > 1
    }

    public var isWeak: Bool {
        guard !isMatched else {
            return false
        }
        return matchCount() > 0
    }

    private func matchCount() -> Int {
        results.reduce(0) { count, type in
            type == .optionalMatch || type == .match ? count + 1 : count
        }
    }

}
