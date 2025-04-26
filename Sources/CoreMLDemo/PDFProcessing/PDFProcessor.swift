import PDFKit
import Vision
import CoreML
import Foundation

enum ContentType: CaseIterable {
    case text
    case tables
    case charts
    case infographics
}

struct PageContent {
    var text: [String] = []
    var tables: [TableContent] = []
    var images: [ImageContent] = []
}

/// Handles multimodal PDF data extraction including text, tables, charts, and infographics
class PDFProcessor {
    private let pdfDocument: PDFDocument
    private let visionModel: VNCoreMLModel
    
    enum ExtractionMode {
        case text
        case tables
        case charts
        case infographics
        case all
    }
    
    init?(url: URL) throws {
        guard let document = PDFDocument(url: url) else {
            return nil
        }
        self.pdfDocument = document
        self.visionModel = try VNCoreMLModel(for: MLModel(contentsOf: URL(fileURLWithPath: "Models/MobileNetV2.mlmodel")))
    }
    
    /// Extracts content from PDF based on specified mode
    func extractContent(mode: ExtractionMode) async throws -> PDFContent {
        var content = PDFContent()
        
        for i in 0..<pdfDocument.pageCount {
            guard let page = pdfDocument.page(at: i) else { continue }
            
            let pageContent = try await extractContentFromPage(page)
            content.text.append(contentsOf: pageContent.text)
            content.tables.append(contentsOf: pageContent.tables)
            content.images.append(contentsOf: pageContent.images)
        }
        
        return content
    }
    
    private func extractContentFromPage(_ page: PDFPage) async throws -> PageContent {
        var content = PageContent()
        
        // Handle different content types
        for contentType in ContentType.allCases {
            switch contentType {
            case .text:
                content.text.append(contentsOf: try await extractText(from: page))
            case .tables:
                content.tables.append(contentsOf: try await extractTables(from: page))
            case .charts, .infographics:
                let nsImage = page.thumbnail(of: CGSize(width: 1024, height: 1024), for: .cropBox)
                if let imageContent = try? analyzeImage(nsImage) {
                    content.images.append(imageContent)
                }
            }
        }
        
        return content
    }
    
    private func extractTables(from page: PDFPage) async throws -> [TableContent] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let nsImage = page.thumbnail(of: CGSize(width: 1024, height: 1024), for: .cropBox)
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return []
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        
        let observations = request.results ?? []
        return try await processTableObservations(observations)
    }
    
    private func analyzeImage(_ nsImage: NSImage) throws -> ImageContent {
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw PDFProcessingError.imageConversionFailed
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest()
        try handler.perform([request])
        
        let observations = request.results ?? []
        let textObservations = observations
        
        let type = determineImageType(textObservations)
        let description = textObservations.first?.topCandidates(1).first?.string ?? ""
        let confidence = textObservations.first?.confidence ?? 0
        return ImageContent(type: type, confidence: confidence, description: description)
    }
    
    private func extractText(from page: PDFPage) async throws -> [String] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let nsImage = page.thumbnail(of: CGSize(width: 1024, height: 1024), for: .cropBox)
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return []
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])
        
        let observations = request.results ?? []
        return observations.compactMap { observation -> String? in
            guard let textObservation = observation as? VNRecognizedTextObservation else { return nil }
            return textObservation.topCandidates(1).first?.string
        }
    }
    
    private func determineImageType(_ observations: [VNRecognizedTextObservation]) -> ImageType {
        // Logic to determine if the image is a chart, infographic, or other
        let topResults = observations.prefix(3)
        for result in topResults {
            if let text = result.topCandidates(1).first?.string.lowercased() {
                if text.contains("chart") || text.contains("graph") {
                    return .chart
                } else if text.contains("diagram") || text.contains("infographic") {
                    return .infographic
                }
            }
        }
        return .other
    }
    
    private func processTableObservations(_ observations: [VNRecognizedTextObservation]) async throws -> [TableContent] {
        let recognizedText = observations.compactMap { observation -> (String, CGRect)? in
            guard let firstCandidate = observation.topCandidates(1).first else { return nil }
            return (firstCandidate.string, observation.boundingBox)
        }
        
        return try detectTableStructures(from: recognizedText)
    }
    
    private func detectTableStructures(from recognizedText: [(String, CGRect)]) throws -> [TableContent] {
        var tables: [TableContent] = []
        
        // Group text elements by their vertical position (rows)
        let rowGroups = groupIntoRows(recognizedText)
        
        // Convert row groups into table structures
        for rowGroup in rowGroups {
            if rowGroup.count >= 2 { // Minimum 2 rows to consider it a table
                let rows = rowGroup.map { rowElements in
                    // Each rowElements is an array of tuples, extract just the text strings
                    rowElements.0
                }
                tables.append(TableContent(rows: [rows], confidence: 0.8))
            }
        }
        
        return tables
    }
    
    private func groupIntoRows(_ recognizedText: [(String, CGRect)]) -> [[(String, CGRect)]] {
        let sortedByY = recognizedText.sorted { $0.1.minY > $1.1.minY }
        var rows: [[(String, CGRect)]] = []
        var currentRow: [(String, CGRect)] = []
        var lastY: CGFloat = -1
        
        for element in sortedByY {
            if lastY == -1 || abs(element.1.minY - lastY) < 10 {
                currentRow.append(element)
            } else {
                if !currentRow.isEmpty {
                    rows.append(currentRow.sorted { $0.1.minX < $1.1.minX })
                    currentRow = [element]
                }
            }
            lastY = element.1.minY
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow.sorted { $0.1.minX < $1.1.minX })
        }
        
        return rows
    }
}

struct PDFContent {
    var text: [String] = []
    var tables: [TableContent] = []
    var images: [ImageContent] = []
}

struct TableContent {
    var rows: [[String]]
    var confidence: Float
}

struct ImageContent {
    var type: ImageType
    var confidence: Float
    var description: String
}

enum ImageType {
    case chart
    case infographic
    case other
}

enum PDFProcessingError: Error {
    case imageConversionFailed
}