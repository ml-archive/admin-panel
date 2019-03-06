/// Configuration for template paths used when rendering tags.
public struct TagTemplatePaths {

    /// Path to template for Quill WYSIWYG field.
    public let wysiwygField: String

    /// Create a new TagTemplatePaths configuration value.
    ///
    /// - Parameters:
    ///   - wysiwygField: path to template for Quill WYSIWYG field.
    public init(wysiwygField: String = "AdminPanel/Submissions/Fields/quill-wysiwyg") {
        self.wysiwygField = wysiwygField
    }
}
