import TemplateKit

extension AdminPanelUser: TemplateDataRepresentable {
    public func convertToTemplateData() throws -> TemplateData {
        return .dictionary([
            "id": id.map(TemplateData.int) ?? .null,
            "email": .string(email),
            "name": .string(name),
            "title": title.map(TemplateData.string) ?? .null,
            "avatarURL": avatarURL.map(TemplateData.string) ?? .null,
            "role": role.map { .string($0.description) } ?? .null
        ])
    }
}
