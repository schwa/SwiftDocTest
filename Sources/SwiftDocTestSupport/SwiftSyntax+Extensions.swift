import CryptoKit
import Foundation
import RegexBuilder
import SwiftSyntax

public extension SyntaxProtocol {
    func walk(_ visitor: (_ syntax: SyntaxProtocol, _ skip: inout Bool, _ stop: inout Bool, _ depth: Int) throws -> Void) rethrows {
        func walk(element: SyntaxProtocol, stop: inout Bool, depth: Int, _ visitor: (_ syntax: SyntaxProtocol, _ skip: inout Bool, _ stop: inout Bool, _ depth: Int) throws -> Void) rethrows {
            var skip = false
            try visitor(element, &skip, &stop, depth)
            if !skip && !stop {
                for child in element.children {
                    try walk(element: child, stop: &stop, depth: depth + 1, visitor)
                }
            }
        }
        var stop = false
        try walk(element: self, stop: &stop, depth: 0, visitor)
    }
}

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
            try walk { element, _, _, _ in
                if let token = Syntax(fromProtocol: element).as(TokenSyntax.self) {
                    if let leadingTrivia = token.leadingTrivia, !leadingTrivia.isEmpty {
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
