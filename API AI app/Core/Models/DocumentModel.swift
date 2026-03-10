import Foundation
import SwiftData

@Model
final class DocumentModel {
    var id: UUID
    var title: String
    var documentType: String
    var promptUsed: String
    var createdAt: Date
    var parentDocumentID: UUID?
    var versionNumber: Int
    var pdfUrl: String?
    var pdfKey: String?
    var latexCode: String?

    init(title: String, documentType: String, promptUsed: String, pdfUrl: String? = nil, pdfKey: String? = nil, latexCode: String? = nil) {
        self.id = UUID()
        self.title = title
        self.documentType = documentType
        self.promptUsed = promptUsed
        self.createdAt = Date()
        self.parentDocumentID = nil
        self.versionNumber = 1
        self.pdfUrl = pdfUrl
        self.pdfKey = pdfKey
        self.latexCode = latexCode
    }
}
