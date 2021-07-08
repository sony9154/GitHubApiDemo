
import Foundation

protocol NodeLifecycleImplementation: class {
    func nodeSetup()
    func nodeUninstall()
}


protocol AnyMakable: class {
    static func make() -> Any?
}
