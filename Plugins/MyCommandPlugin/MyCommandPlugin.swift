import PackagePlugin
import Foundation
import SwiftDocTestSupport
import Everything

@main
struct MyCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        print(context.package.targets)
        // try SwiftDocTest(package: FSPath(target.directory).parent).run()
    }
}
