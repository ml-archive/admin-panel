import Fluent

public struct AdminPanelConfig {
    let name: String
    let baseUrl: String

    public init(
        name: String,
        baseUrl: String
    ) {
        self.name = name
        self.baseUrl = baseUrl
    }
}
