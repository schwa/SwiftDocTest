import ArgumentParser
import Everything
import Foundation
import RegexBuilder
import Stencil
import SwiftDocTestSupport

@main
struct SwiftDocTest: ParsableCommand {
    //    @Flag(help: "Include a counter with each repetition.")
    //    var includeCounter = false
    //
    //    var count: Int?
    //
    @Option(name: .shortAndLong, help: "Path to swift package.")
    var package: FSPath

    mutating func run() throws {
        assert(package.exists && package.isDirectory)

        let modules = try (package / "Sources").children!
            .filter {
                $0.isDirectory && !$0.isHidden
            }
            .map { path in
                try Module(path: path)
            }

        for module in modules {
            let context = ["module": module]
            let ext = Extension()
            ext.registerFilter("makeIdentifier") { (value: Any?) in
                if let value = value as? String {
                    return value
                        .trimmingCharacters(in: .whitespaces)
                        .replacing(#/[\+]/#) { _ in
                            ""
                        }
                }
                return value
            }
            let environment = Environment(loader: BundleLoader(bundle: .module), extensions: [ext])
            let rendered = try environment.renderTemplate(name: "DocTests.swift.stencil", context: context)
                .replacing(#/.+\/\/ strip\n/#, with: { _ in
                    return ""
                })
                .replacing(#/^(.+)[ \t]+$/#.anchorsMatchLineEndings(), with: { match in
                    match.1
                })
                .replacing(#/\n\n\n+/#, with: { _ in "\n\n" })

            let testsPath = package / "Tests" / (module.name + "Tests")


            guard testsPath.exists else {
                fatalError("\(testsPath) does not exist")
            }

            try rendered.write(to: (testsPath / "DocTest.swift").url, atomically: true, encoding: .utf8)
        }
    }
}

extension FSPath: ExpressibleByArgument {
    public init?(argument: String) {
        self = FSPath(path: argument)
    }
}

extension FSPath {
    var isHidden: Bool {
        return name.hasPrefix(".") // TODO: finder hidden
    }
}

public struct BundleLoader: Loader {
    let bundle: Bundle

    public init(bundle: Bundle) {
        self.bundle = bundle
    }

    public func loadTemplate(name: String, environment: Stencil.Environment) throws -> Stencil.Template {
        let pattern = Regex {
            Anchor.startOfLine
            Capture {
                OneOrMore(.any)
            }
            "."
            Capture {
                OneOrMore(.any)
            }
            Anchor.endOfLine
        }
        guard let match = try pattern.firstMatch(in: name) else {
            fatalError()
        }
        let (name, pathExtension) = (String(match.1), String(match.2))
        let url = bundle.url(forResource: name, withExtension: pathExtension)!
        let templateContent = try String(contentsOf: url)
        return .init(templateString: templateContent, environment: environment, name: name)
    }
}
