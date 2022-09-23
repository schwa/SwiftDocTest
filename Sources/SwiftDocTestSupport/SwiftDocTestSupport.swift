import CryptoKit
import Everything
import Foundation
import RegexBuilder
import Stencil
import SwiftSyntax
import SwiftSyntaxParser

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

        let regex = Regex {
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

        let syntax = try SyntaxParser.parse(path.url)
        var allDocComments: [String] = []
        try syntax.walk { element, _, _, _ in
            if let token = Syntax(fromProtocol: element).as(TokenSyntax.self) {
                if let leadingTrivia = token.leadingTrivia, !leadingTrivia.isEmpty {
                    let docComments: [String] = try leadingTrivia.compactMap { trivia in
                        switch trivia {
                        case .docBlockComment(let comment):
                            let comment = comment.lines.map { $0.trimmingCharacters(in: .whitespaces) }.joined(separator: "\n")
                            guard let match = try regex.firstMatch(in: comment) else {
                                return nil
                            }
                            return String(match.1)
                        default:
                            return nil
                        }
                    }
                    allDocComments += docComments
                }
            }
        }
        let tests = try allDocComments.map { docComment in
            let pattern = Regex {
                Capture {
                    OneOrMore(.any)
                }
                " // => "
                Capture {
                    OneOrMore(.any)
                }
            }
            let docComment = String(docComment).trimmingCharacters(in: .newlines)
            guard let match = try pattern.firstMatch(in: docComment) else {
                fatalError()
            }
            let hash = SHA256.hash(data: docComment.data(using: .utf8)!).map {
                "0" + String($0, radix: 16).prefix(2)
            }.joined()

            let test = Test(name: String(hash.prefix(8)), preamble: nil, condition: String(match.1), expectedResult: String(match.2))
            return test
        }
        self.tests = tests
    }
}

public struct Test {
    public let name: String
    public let preamble: String?
    public let condition: String
    public let expectedResult: String
}
