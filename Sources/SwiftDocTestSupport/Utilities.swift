import Foundation

public extension String {
    var lines: [Substring] {
        split {
            $0.isNewline
        }
    }
}
