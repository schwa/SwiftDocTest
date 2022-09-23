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

