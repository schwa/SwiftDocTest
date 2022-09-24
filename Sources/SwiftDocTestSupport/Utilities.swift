import Foundation

/**
 '''swift doctest
 "hello\nworld".lines // => ["hello", "world"]
 '''
 */
public extension String {
    var lines: [Substring] {
        split {
            $0.isNewline
        }
    }
}
