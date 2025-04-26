import Foundation
import Vision
import CoreML

struct ImageCaption {
    let text: String
    let confidence: Float
}

class VisionLanguageProcessor {
    private let telemetry: TelemetryManager
    private let model: VNCoreMLModel
    
    init(telemetry: TelemetryManager) throws {
        self.telemetry = telemetry
        // Initialize with MobileNetV2 for image analysis
        let modelUrl = URL(fileURLWithPath: "Models/MobileNetV2.mlmodel")
        self.model = try VNCoreMLModel(for: MLModel(contentsOf: modelUrl))
    }
    
    func generateCaption(for image: CGImage) async throws -> ImageCaption {
        let request = VNCoreMLRequest(model: model) { request, error in
            if let error = error {
                self.telemetry.logError("Image caption generation failed", error)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])
        
        guard let observations = request.results as? [VNClassificationObservation],
              let topResult = observations.first else {
            throw VLProcessingError.noResults
        }
        
        // Log the successful caption generation
        telemetry.logEvent("image_caption_generated", metadata: [
            "confidence": String(topResult.confidence)
        ])
        
        // Convert classification result to natural language caption
        let caption = convertClassificationToCaption(topResult.identifier)
        return ImageCaption(text: caption, confidence: topResult.confidence)
    }
    
    private func convertClassificationToCaption(_ classification: String) -> String {
        // Convert classification labels to more natural language
        // Example: "golden_retriever" -> "This appears to be a Golden Retriever"
        let words = classification.split(separator: "_")
            .map { $0.capitalized }
            .joined(separator: " ")
        
        return "This appears to be a \(words)"
    }
}

enum VLProcessingError: Error {
    case noResults
}