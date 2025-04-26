# Quick Start Guide - CoreML Image Classification

## Prerequisites
- Xcode 13.0 or later
- macOS 12.0 or later
- MobileNetV2.mlmodel (included in Models directory)

## Setup and Usage

1. **Build the Project**
   ```bash
   swift build
   ```

2. **Prepare Test Images**
   - Create an `Images` directory in your project root
   - Add some test images (JPG or PNG format)

3. **Run Classification**
   ```swift
   import Foundation
   
   // Example usage
   let imageURL = URL(fileURLWithPath: "Images/test-image.jpg")
   do {
       try classifyImage(at: imageURL)
   } catch {
       print("Classification failed:", error)
   }
   ```

## Example Output
```
Top classifications:
• golden retriever: 98.5%
• Labrador retriever: 0.8%
• tennis ball: 0.7%
```

## Common Use Cases

1. **Single Image Classification**
   ```swift
   let url = URL(fileURLWithPath: "path/to/image.jpg")
   try classifyImage(at: url)
   ```

2. **Batch Processing**
   ```swift
   let imageUrls = [
       URL(fileURLWithPath: "image1.jpg"),
       URL(fileURLWithPath: "image2.jpg")
   ]
   
   for url in imageUrls {
       try classifyImage(at: url)
   }
   ```

## Troubleshooting

1. **Model Not Found**
   - Ensure MobileNetV2.mlmodel is in the Models directory
   - Check file permissions

2. **Image Loading Fails**
   - Verify image path is correct
   - Ensure image format is supported (JPG, PNG)
   - Check image file is not corrupted

3. **Low Confidence Results**
   - Try different angles or lighting
   - Ensure image is clear and well-lit
   - Consider adjusting confidence threshold in ClassifierConfig