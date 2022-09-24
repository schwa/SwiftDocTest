import ArgumentParser
import Everything
import Foundation
import RegexBuilder
import Stencil
import SwiftDocTestSupport

@main
struct CLI: ParsableCommand {

    @Option(name: .shortAndLong, help: "Path to swift package.")
    var package: FSPath

    mutating func run() throws {
        try SwiftDocTest(package: package).run()
    }
}

extension FSPath: ExpressibleByArgument {
    public init?(argument: String) {
        self = FSPath(path: argument)
    }
}
