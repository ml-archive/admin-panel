public struct AdminPanelConfig {
    let name: String
    let baseUrl: String
    let skin: String
    let fromName: String

    public init(
        name: String,
        baseUrl: String,
        skin: String,
        fromName: String
    ) {
        self.name = name
        self.baseUrl = baseUrl
        self.skin = skin
        self.fromName = fromName
    }
}
