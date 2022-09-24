import CryptoKit
import Everything
import RegexBuilder
import SwiftParser
import SwiftSyntax

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

// MARK: -


public extension TriviaPiece {

    private static let docTestRegex = Regex {
        "/**\n"
        ZeroOrMore {
            ZeroOrMore(.any)
            "\n"
        }
        "```swift doctest\n"
        Capture {
            OneOrMore {
                OneOrMore(.any)
                "\n"
            }
        }
        "```\n"
        "*/"
    }

    var docTest: String? {
        get throws {
            switch self {
            case .docBlockComment(let comment):
                let comment = comment.lines.map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
                guard let match = try Self.docTestRegex.firstMatch(in: comment) else {
                    return nil
                }
                return String(match.1)
            default:
                return nil
            }
        }
    }
}

public extension Trivia {
    var docTests: [String] {
        get throws {
            try compactMap { try $0.docTest }
        }
    }
}

public extension SyntaxProtocol {
    var docTests: [Test] {
        get throws {
            var allDocComments: [String] = []
            try Syntax(fromProtocol: self).walk { element, _, _, _ in
                if let token = Syntax(fromProtocol: element).as(TokenSyntax.self) {
                    if let leadingTrivia = token.leadingTrivia, !leadingTrivia.isEmpty {
                        guard let decl = token.firstAncestor(where: { $0.is(DeclSyntax.self)})?.as(DeclSyntax.self) else {
                            fatalError()
                        }
                        print(decl.name)
                        allDocComments += try leadingTrivia.docTests
                    }
                }
            }
            let tests = try allDocComments.map { docComment in
                try Test(docComment: docComment)
            }
            return tests
        }
    }
}

extension Test {

    static let assertionRegex = Regex {
        Capture {
            OneOrMore(.any)
        }
        " // => "
        Capture {
            OneOrMore(.any)
        }
    }

    init(docComment: String) throws {
        var preambles: [String] = []
        var assertions: [Assertion] = []
        for line in docComment.lines {
            if let match = try Self.assertionRegex.firstMatch(in: line) {
                let preamble = preambles.isEmpty ? nil : preambles.joined(separator: "\n")
                assertions.append(.init(preamble: preamble, condition: String(match.1), expectedResult: String(match.2)))
                preambles = []
            }
            else {
                preambles.append(String(line))
            }
        }
        let hash = SHA256.hash(data: docComment.data(using: .utf8)!).map {
            "0" + String($0, radix: 16).prefix(2)
        }.joined()
        self = Test(name: String(hash.prefix(8)), assertions: assertions)
    }
}
