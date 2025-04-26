import Foundation

struct Document {
    let id: String
    let content: String
    let metadata: [String: String]
}

struct SearchResult {
    let documentId: String
    let content: String
    let score: Float
}

class HybridSearch {
    private var documents: [String: Document] = [:]
    private var denseIndex: [String: [Float]] = [:]
    private var sparseIndex: [String: Set<String>] = [:]
    
    init() {}
    
    func indexDocument(_ document: Document) throws {
        documents[document.id] = document
        
        // Dense indexing - convert content to vector representation
        denseIndex[document.id] = createDenseVector(from: document.content)
        
        // Sparse indexing - create inverted index
        let terms = tokenize(document.content)
        sparseIndex[document.id] = Set(terms)
    }
    
    func search(query: String, limit: Int = 10) throws -> [SearchResult] {
        let queryVector = createDenseVector(from: query)
        let queryTerms = Set(tokenize(query))
        
        var scores: [String: Float] = [:]
        
        // Combine dense and sparse search results
        for (docId, docVector) in denseIndex {
            let denseScore = cosineSimilarity(queryVector, docVector)
            let sparseScore = jaccardSimilarity(queryTerms, sparseIndex[docId] ?? Set())
            
            // Weighted combination of dense and sparse scores
            scores[docId] = (0.7 * denseScore) + (0.3 * sparseScore)
        }
        
        // Sort by score and convert to SearchResult objects
        return scores.sorted { $0.value > $1.value }
            .prefix(limit)
            .compactMap { docId, score in
                guard let doc = documents[docId] else { return nil }
                return SearchResult(documentId: docId, content: doc.content, score: score)
            }
    }
    
    // MARK: - Private Helper Methods
    
    private func tokenize(_ text: String) -> [String] {
        return text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
    }
    
    private func createDenseVector(from text: String) -> [Float] {
        // Simple bag-of-words vector for demonstration
        // In a real implementation, this would use a proper embedding model
        let terms = tokenize(text)
        var vector = [Float](repeating: 0, count: 300)  // Example dimension
        
        for (i, term) in terms.enumerated() {
            let hash = abs(term.hashValue) % vector.count
            vector[hash] += 1.0 / Float(i + 1)  // Weight by position
        }
        
        // Normalize vector
        let magnitude = sqrt(vector.reduce(0) { $0 + $1 * $1 })
        if magnitude > 0 {
            vector = vector.map { $0 / magnitude }
        }
        
        return vector
    }
    
    private func cosineSimilarity(_ v1: [Float], _ v2: [Float]) -> Float {
        guard v1.count == v2.count else { return 0 }
        
        let dotProduct = zip(v1, v2).reduce(0) { $0 + $1.0 * $1.1 }
        let magnitude1 = sqrt(v1.reduce(0) { $0 + $1 * $1 })
        let magnitude2 = sqrt(v2.reduce(0) { $0 + $1 * $1 })
        
        guard magnitude1 > 0 && magnitude2 > 0 else { return 0 }
        return dotProduct / (magnitude1 * magnitude2)
    }
    
    private func jaccardSimilarity(_ set1: Set<String>, _ set2: Set<String>) -> Float {
        guard !set1.isEmpty || !set2.isEmpty else { return 0 }
        let intersection = set1.intersection(set2).count
        let union = set1.union(set2).count
        return Float(intersection) / Float(union)
    }
}