import Foundation
import SwiftSyntax

public extension Syntax {
    func walk(_ visitor: (_ syntax: Syntax, _ skip: inout Bool, _ stop: inout Bool, _ depth: Int) throws -> Void) rethrows {
        func walk(element: Syntax, stop: inout Bool, depth: Int, _ visitor: (_ syntax: Syntax, _ skip: inout Bool, _ stop: inout Bool, _ depth: Int) throws -> Void) rethrows {
            var skip = false
            try visitor(element, &skip, &stop, depth)
            if !skip && !stop {
                for child in element.children(viewMode: .all) {
                    try walk(element: child, stop: &stop, depth: depth + 1, visitor)
                }
            }
        }
        var stop = false
        try walk(element: self, stop: &stop, depth: 0, visitor)
    }
}

public extension SyntaxProtocol {

    var ancestors: [Syntax] {
        guard let parent else {
            return []
        }
        return [parent] + parent.ancestors
    }

    func firstAncestor(where test: (Syntax) -> Bool) -> Syntax? {
        guard let parent else {
            return nil
        }
        if test(parent) == true {
            return parent
        }
        else {
            return parent.firstAncestor(where: test)
        }
    }

    var onlyChildToken: TokenSyntax? {
        guard children(viewMode: .all).count == 1 else {
            return nil
        }
        return children(viewMode: .all).first(of: TokenSyntax.self)
    }


    var nextSyntax: Syntax? {
        guard let siblings = parent?.children(viewMode: .all) else {
            return nil
        }
        let index = siblings.firstIndex(of: Syntax(self))!
        guard index < siblings.endIndex else {
            return nil
        }
        let nextIndex = siblings.index(after: index)
        let nextSyntax = siblings[nextIndex]
        return nextSyntax
    }

    func recursiveFindFirst <S>(of type: S.Type) -> S? where S: SyntaxProtocol {
        var result: S?
        Syntax(fromProtocol: self).walk { syntax, stop, skip, depth in
            if syntax.is(type) {
                result = syntax.as(type)
                stop = true
            }
        }
        return result
    }
}

public extension Collection where Element == Syntax {
    func first<S>(of type: S.Type) -> S? where S: SyntaxProtocol {
        guard let first = first(where: { $0.is(type) }) else {
            return nil
        }
        return first.as(type)
    }
}

public extension DeclSyntaxProtocol {
    // TODO: Should never return nil
    var name: String? {
        guard let firstToken = children(viewMode: .all).first(of: TokenSyntax.self) else {
            return nil
        }
        switch firstToken.tokenKind {
        case .structKeyword, .classKeyword, .extensionKeyword, .enumKeyword, .protocolKeyword, .funcKeyword, .typealiasKeyword, .associatedtypeKeyword:
            guard let nextSyntax = firstToken.nextSyntax else {
                return nil
            }
            if let simpleType = nextSyntax.as(SimpleTypeIdentifierSyntax.self) {
                return simpleType.onlyChildToken!.text
            }
            else if let memberType = nextSyntax.as(MemberTypeIdentifierSyntax.self) {
                //return memberType.name
                fatalError()
            }
            else {
                return nextSyntax.as(TokenSyntax.self)!.text
            }
        case .caseKeyword:
            guard let nextSyntax = firstToken.nextSyntax, let enumCaseElement = nextSyntax.recursiveFindFirst(of: EnumCaseElementSyntax.self) else {
                fatalError()
            }
            return enumCaseElement.firstToken!.text
        case .varKeyword, .letKeyword:
            guard let patternBindingList = firstToken.nextSyntax?.as(PatternBindingListSyntax.self) else {
                fatalError("Could not find a PatternBindingListSyntax.")
            }
            guard let identifierPattern = patternBindingList.recursiveFindFirst(of: IdentifierPatternSyntax.self) else {
                fatalError("Could not find a IdentifierPatternSyntax.")
            }
            return identifierPattern.onlyChildToken!.text
        default:
            return nil
        }
    }

    var scopedName: String? {
        fatalError()
    }
}
