import Foundation
import ArgumentParser
import CoreML
import Vision
import PDFKit
import SwiftUI

#if ENABLE_GUI
let _ = CoreMLDemoApp.main()
#else
@available(macOS 10.15, *)
@main
struct CoreMLDemo: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "coreml-demo",
        abstract: "A demo of CoreML capabilities with PDF processing, search, and image analysis",
        subcommands: [ProcessPDF.self, Search.self, Analyze.self]
    )
}

// PDF Processing Command
@available(macOS 10.15, *)
extension CoreMLDemo {
    struct ProcessPDF: AsyncParsableCommand {
        @Argument(help: "Path to the PDF file")
        var pdfPath: String
        
        @Option(name: .shortAndLong, help: "Content type to extract (text, tables, charts, all)")
        var mode: String = "all"
        
        func run() async throws {
            let telemetryManager = TelemetryManager()
            guard let processor = try PDFProcessor(url: URL(fileURLWithPath: pdfPath)) else {
                throw RuntimeError("Failed to initialize PDF processor")
            }
            
            let extractionMode: PDFProcessor.ExtractionMode
            switch mode.lowercased() {
            case "text": extractionMode = .text
            case "tables": extractionMode = .tables
            case "charts": extractionMode = .charts
            default: extractionMode = .all
            }
            
            do {
                let content = try await processor.extractContent(mode: extractionMode)
                printContent(content)
                telemetryManager.logEvent("pdf_processing_complete")
            } catch {
                print("Error processing PDF: \(error)")
                telemetryManager.logError("PDF processing failed", error)
            }
        }
        
        private func printContent(_ content: PDFContent) {
            print("\nExtracted Content:")
            if !content.text.isEmpty {
                print("\nText:")
                content.text.forEach { print($0) }
            }
            if !content.tables.isEmpty {
                print("\nTables:")
                content.tables.forEach { table in
                    print("Table (confidence: \(String(format: "%.2f%%", table.confidence * 100))):")
                    table.rows.forEach { print($0.joined(separator: " | ")) }
                    print("---")
                }
            }
            if !content.images.isEmpty {
                print("\nImages:")
                content.images.forEach { image in
                    print("Type: \(image.type)")
                    print("Description: \(image.description)")
                    print("Confidence: \(String(format: "%.2f%%", image.confidence * 100))")
                    print("---")
                }
            }
        }
    }
    
    // Search Command
    struct Search: ParsableCommand {
        @Argument(help: "Search query")
        var query: String
        
        @Option(name: .shortAndLong, help: "Maximum number of results")
        var limit: Int = 10
        
        func run() throws {
            let searcher = HybridSearch()
            
            // Add some sample documents for testing
            try searcher.indexDocument(Document(
                id: "doc1",
                content: "Sample document content for testing search functionality",
                metadata: ["type": "test"]
            ))
            
            let results = try searcher.search(query: query, limit: limit)
            print("\nSearch Results:")
            for result in results {
                print("\nDocument ID: \(result.documentId)")
                print("Score: \(String(format: "%.2f", result.score))")
                print("Content: \(result.content)")
            }
        }
    }
    
    // Image Analysis Command
    struct Analyze: AsyncParsableCommand {
        @Argument(help: "Path to the image file")
        var imagePath: String
        
        func run() async throws {
            let telemetryManager = TelemetryManager()
            
            do {
                let imageUrl = URL(fileURLWithPath: imagePath)
                if FileManager.default.fileExists(atPath: imagePath) {
                    let vlProcessor = try VisionLanguageProcessor(telemetry: telemetryManager)
                    if let image = NSImage(contentsOf: imageUrl),
                       let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                        let caption = try await vlProcessor.generateCaption(for: cgImage)
                        print("Caption: \(caption.text)")
                        print("Confidence: \(String(format: "%.2f%%", caption.confidence * 100))")
                        telemetryManager.logEvent("image_analysis_complete")
                    } else {
                        print("Failed to load image")
                        telemetryManager.logError("Image loading failed", RuntimeError("Invalid image format"))
                    }
                } else {
                    print("Image file not found at path: \(imagePath)")
                    telemetryManager.logError("Image not found", RuntimeError("File not found"))
                }
            } catch {
                print("Error analyzing image: \(error)")
                telemetryManager.logError("Image analysis failed", error)
            }
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }
}

// Run the program
CoreMLDemo.main()
#endif