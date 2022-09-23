# SwiftDocTest

_SwiftDocTest_ is an experimental tool for testing Swift example code in documentation.

This is still a work-in-progress, and not yet ready for production...

Unlike [@mattt](https://twitter.com/mattt)'s [DocTest](https://github.com/SwiftDocOrg/DocTest), this project generates swift unit test files in your package.

Example:

Running SwiftDocTest on code that looks like:

```swift
import CoreGraphics
import simd

public extension CGPoint {
    /**
     ```swift doctest
     CGPoint(SIMD2<Float>(1, 2)) // => CGPoint(x: 1, y: 2)
     ```
     */
    init<Scalar>(_ vector: SIMD2<Scalar>) where Scalar: BinaryFloatingPoint {
        self = CGPoint(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
}
```

Produces a unit test .swift file that looks like:

```swift
import XCTest
@testable import SIMDSupport

final class CoreGraphics_DocTests: XCTestCase {
    func test_0320de03() throws {
        XCTAssertEqual(CGPoint(SIMD2<Float>(1, 2)), CGPoint(x: 1, y: 2))
    }
}
```
