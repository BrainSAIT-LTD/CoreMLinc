# CoreMLDemo API Reference

## ClassifierConfig

Configuration structure for the Vision classifier.

```swift
struct ClassifierConfig {
    static let modelName: String
    static let confidenceThreshold: Float
}
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `modelName` | `String` | Name of the CoreML model file (default: "MobileNetV2") |
| `confidenceThreshold` | `Float` | Minimum confidence level for valid classifications (default: 0.7) |

## Functions

### setupVisionClassifier()

```swift
func setupVisionClassifier() throws -> VNCoreMLModel
```

Initializes and configures the Vision classifier with the MobileNetV2 model.

#### Returns
- `VNCoreMLModel`: Configured Vision model ready for classification

#### Throws
- `Error`: If model loading fails

#### Search Paths
1. Bundle.module resource
2. Bundle.main resource
3. Local Models directory

### classifyImage(at:)

```swift
func classifyImage(at imageURL: URL) throws
```

Performs image classification on a given image.

#### Parameters
- `imageURL`: URL path to the image file

#### Throws
- `Error`: If image processing or classification fails

#### Output
Prints classification results to console:
- Class identifier
- Confidence percentage (filtered by threshold)
- Top 3 results above confidence threshold

## Usage Example

```swift
do {
    let imageURL = URL(fileURLWithPath: "Images/sample.jpg")
    try classifyImage(at: imageURL)
} catch {
    print("Classification error:", error)
}
```

## Error Handling

The API implements comprehensive error handling for:
1. Model loading failures
2. Image loading issues
3. Classification processing errors
4. Invalid results

## Thread Safety

- Vision requests are thread-safe
- Multiple classification requests can run concurrently
- Model loading should be done once and reused