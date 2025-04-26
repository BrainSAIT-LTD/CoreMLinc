import Foundation

// Example demonstrating different ways to use the CoreML image classifier

// 1. Basic single image classification
func classifySingleImage() {
    let imageURL = URL(fileURLWithPath: "Images/cat.jpg")
    do {
        try classifyImage(at: imageURL)
    } catch {
        print("Classification failed:", error)
    }
}

// 2. Batch processing multiple images
func batchClassification(imageNames: [String]) {
    for imageName in imageNames {
        let imageURL = URL(fileURLWithPath: "Images/\(imageName)")
        do {
            print("\nClassifying \(imageName):")
            try classifyImage(at: imageURL)
        } catch {
            print("Failed to classify \(imageName):", error)
        }
    }
}

// 3. Directory processing
func classifyImagesInDirectory(directory: String) {
    let fileManager = FileManager.default
    do {
        let imageURLs = try fileManager.contentsOfDirectory(atPath: directory)
            .filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".png") }
            .map { URL(fileURLWithPath: "\(directory)/\($0)") }
        
        for imageURL in imageURLs {
            print("\nClassifying \(imageURL.lastPathComponent):")
            try classifyImage(at: imageURL)
        }
    } catch {
        print("Directory processing failed:", error)
    }
}

// Example usage:
print("=== Single Image Classification ===")
classifySingleImage()

print("\n=== Batch Classification ===")
batchClassification(imageNames: ["dog.jpg", "bird.jpg"])

print("\n=== Directory Processing ===")
classifyImagesInDirectory(directory: "Images")