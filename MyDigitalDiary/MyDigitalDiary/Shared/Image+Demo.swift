import SwiftUI

extension Image {

    static let about = symbol("lightbulb")
    static let documentation = symbol("doc.text")
    static let menu = symbol("ellipsis.circle")
    static let safari = symbol("safari")
    static let sidebarLeading = symbol("sidebar.leading")
    static let textEditor = symbol("doc.richtext")

    static func symbol(_ named: String) -> Image {
        Image(systemName: named)
    }
}
