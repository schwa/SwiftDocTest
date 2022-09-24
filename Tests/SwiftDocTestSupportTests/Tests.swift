@testable import SwiftDocTestSupport
import XCTest
import SwiftSyntax
import SwiftParser

final class TriviaToDocTestTests: XCTestCase {
    func testTriviaToDocTestPositive() throws {
        let source = """
/**
```swift doctest
1 + 1 // => 2
```
*/
"""
        let trivia = Trivia(pieces: [TriviaPiece.docBlockComment(source)])
        XCTAssertEqual(try trivia.docTests, ["1 + 1 // => 2\n"])
    }

    func testTriviaToDocTestNegative() throws {
        let source = """
/**
```swift
1 + 1 // => 2
```
*/
"""
        let trivia = Trivia(pieces: [TriviaPiece.docBlockComment(source)])
        XCTAssertEqual(try trivia.docTests, [])
    }

    func testTriviaToDocTestMultiplePositive() throws {
        let source = """
/**
```swift doctest
1 + 1 // => 2
// And then...
2 + 4 // => 4
```
*/
"""
        let trivia = Trivia(pieces: [TriviaPiece.docBlockComment(source)])
        XCTAssertEqual(try trivia.docTests, ["1 + 1 // => 2\n// And then...\n2 + 4 // => 4\n"])
    }

}

final class TrivaToDocTestTests: XCTestCase {
    func test1() throws {
        let source = """
        /**
        ```swift doctest
        1 + 1 // => 2
        // And then...
        2 + 4 // => 4
        ```
        */
        """
        let syntax = try Parser.parse(source: source)
        let tests = try syntax.docTests
        XCTAssertEqual(tests.count, 1)
        XCTAssertEqual(tests[0].assertions.count, 2)
        XCTAssertEqual(tests[0].assertions[0].preamble, nil)
        XCTAssertEqual(tests[0].assertions[0].condition, "1 + 1")
        XCTAssertEqual(tests[0].assertions[0].expectedResult, "2")
        XCTAssertEqual(tests[0].assertions[1].preamble, "// And then...")
        XCTAssertEqual(tests[0].assertions[1].condition, "2 + 4")
        XCTAssertEqual(tests[0].assertions[1].expectedResult, "4")
    }
}
