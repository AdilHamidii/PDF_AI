//
//  PDFService.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import Foundation

struct PDFGenerateRequest: Encodable {
    let prompt: String?
    let documentType: String
    let formData: [String: String]?
}

struct PDFGenerateResponse: Decodable {
    let pdfUrl: String
    let pdfKey: String
    let latex: String
}

struct PDFErrorResponse: Decodable {
    let error: String
    let details: String?
    let latex: String?
}

enum PDFServiceError: LocalizedError {
    case invalidURL
    case serverError(String)
    case networkError(Error)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL"
        case .serverError(let msg): return msg
        case .networkError(let err): return err.localizedDescription
        case .decodingError: return "Failed to parse server response"
        }
    }
}

actor PDFService {
    static let shared = PDFService()

    private let baseURL = Config.apiBaseURL

    func generate(prompt: String?, documentType: String, formData: [String: Any]?) async throws -> PDFGenerateResponse {
        guard let url = URL(string: "\(baseURL)/generate") else {
            throw PDFServiceError.invalidURL
        }

        // Convert formData [String: Any] to [String: String] for JSON encoding
        var stringFormData: [String: String]? = nil
        if let formData {
            var converted: [String: String] = [:]
            for (key, value) in formData {
                converted[key] = "\(value)"
            }
            stringFormData = converted
        }

        var body: [String: Any] = ["documentType": documentType]
        if let prompt { body["prompt"] = prompt }
        if let stringFormData { body["formData"] = stringFormData }

        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 90

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw PDFServiceError.decodingError
        }

        if httpResponse.statusCode == 200 {
            let decoded = try JSONDecoder().decode(PDFGenerateResponse.self, from: data)
            return decoded
        } else {
            if let errorResponse = try? JSONDecoder().decode(PDFErrorResponse.self, from: data) {
                throw PDFServiceError.serverError(errorResponse.error)
            }
            throw PDFServiceError.serverError("Server returned status \(httpResponse.statusCode)")
        }
    }

    func downloadPDF(from urlString: String) async throws -> URL {
        guard let url = URL(string: urlString) else {
            throw PDFServiceError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(UUID().uuidString).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        try data.write(to: fileURL)

        return fileURL
    }
}
