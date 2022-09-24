import Everything
import SwiftParser

public struct Module {
    public let path: FSPath
    public let name: String
    public let sources: [Source]

    public init(path: FSPath) throws {
        self.path = path
        name = path.stem

        sources = try path.children!
            .filter {
                $0.pathExtension == "swift"
            }
            .map {
                try Source(path: $0)
            }
    }
}

public struct Source {
    public let path: FSPath
    public let name: String
    public let tests: [Test]

    public init(path: FSPath) throws {
        self.path = path
        name = path.stem
        let source = try String(contentsOf: path.url)
        let syntax = try Parser.parse(source: source)
        tests = try syntax.docTests
    }
}

public struct Test {
    // TODO: Line/Column info
    // TODO: Add name of parent declaration
    public let name: String
    public let assertions: [Assertion]
}

public struct Assertion {
    public let preamble: String?
    public let condition: String
    public let expectedResult: String
}
