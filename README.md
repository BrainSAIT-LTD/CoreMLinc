# CoreML Demo

This project demonstrates advanced CoreML capabilities including PDF processing, hybrid search, and vision-language processing.

## Prerequisites

### Required Models
1. Download the MobileNetV2 Core ML model:
   - Visit Apple's [Machine Learning Models page](https://developer.apple.com/machine-learning/models/)
   - Download MobileNetV2
   - Place the downloaded `MobileNetV2.mlmodel` file in the `Models` directory

## Features

- PDF Processing
  - Text extraction
  - Table detection
  - Chart and infographic recognition
- Hybrid Search System
  - Dense vector search
  - Sparse text search
  - Combined ranking
- Vision Language Processing
  - Image captioning
  - Chart analysis
  - Visual content understanding
- Conversation Management
  - Session handling
  - Message history
  - Context management
- Telemetry System
  - Event tracking
  - Error logging
  - Performance metrics

## Usage

```bash
# Process a PDF file
swift run CoreMLDemo process-pdf path/to/file.pdf --mode all

# Search documents
swift run CoreMLDemo search "your query" --limit 10

# Analyze an image
swift run CoreMLDemo analyze path/to/image.jpg
```

## Project Structure

- `/Sources/CoreMLDemo`: Main source code
  - `/Conversation`: Conversation management
  - `/PDFProcessing`: PDF processing components
  - `/Search`: Hybrid search implementation
  - `/Telemetry`: Observability system
  - `/VisionLanguage`: Vision-language processing

## Dependencies

- ArgumentParser: Command-line interface
- Vision: Image analysis
- CoreML: Machine learning operations
- PDFKit: PDF processing
- ZIPFoundation: Archive handling