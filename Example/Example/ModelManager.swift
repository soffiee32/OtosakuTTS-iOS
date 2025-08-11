//
//  ModelManager.swift
//  Example
//

import Foundation
import ZIPFoundation

class ModelManager: ObservableObject {
    static let shared = ModelManager()
    
    private let modelURL = "https://firebasestorage.googleapis.com/v0/b/my-project-1494707780868.firebasestorage.app/o/fastpitch_hifigan.zip?alt=media&token=d239c2de-fe93-460e-a1e4-044923a1be58"
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var modelsDirectory: URL {
        documentsDirectory.appendingPathComponent("TTSModels")
    }
    
    private var zipFileURL: URL {
        documentsDirectory.appendingPathComponent("fastpitch_hifigan.zip")
    }
    
    var isModelDownloaded: Bool {
        let fastPitchExists = FileManager.default.fileExists(atPath: modelsDirectory.appendingPathComponent("FastPitch.mlmodelc").path)
        let hifiGanExists = FileManager.default.fileExists(atPath: modelsDirectory.appendingPathComponent("HiFiGan.mlmodelc").path)
        let tokensExists = FileManager.default.fileExists(atPath: modelsDirectory.appendingPathComponent("tokens.txt").path)
        let dictExists = FileManager.default.fileExists(atPath: modelsDirectory.appendingPathComponent("cmudict.json").path)
        
        return fastPitchExists && hifiGanExists && tokensExists && dictExists
    }
    
    func downloadModels(progressHandler: @escaping (Double) -> Void) async throws {
        guard !isModelDownloaded else { return }
        
        let session = URLSession.shared
        let (asyncBytes, response) = try await session.bytes(from: URL(string: modelURL)!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "ModelManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to download models"])
        }
        
        let totalBytes = httpResponse.expectedContentLength
        var downloadedBytes: Int64 = 0
        var data = Data()
        
        for try await byte in asyncBytes {
            data.append(byte)
            downloadedBytes += 1
            
            if downloadedBytes % 10000 == 0 {
                let progress = Double(downloadedBytes) / Double(totalBytes)
                await MainActor.run {
                    progressHandler(progress)
                }
            }
        }
        
        await MainActor.run {
            progressHandler(1.0)
        }
        
        try data.write(to: zipFileURL)
        
        try await extractModels()
        
        try? FileManager.default.removeItem(at: zipFileURL)
    }
    
    private func extractModels() async throws {
        guard FileManager.default.fileExists(atPath: zipFileURL.path) else {
            throw NSError(domain: "ModelManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "ZIP file not found"])
        }
        
        try FileManager.default.createDirectory(at: modelsDirectory, withIntermediateDirectories: true)
        
        try FileManager.default.unzipItem(at: zipFileURL, to: modelsDirectory)
        
        // Remove __MACOSX folder if exists
        let macosxFolder = modelsDirectory.appendingPathComponent("__MACOSX")
        try? FileManager.default.removeItem(at: macosxFolder)
        
        // Find the fastpitch_hifigan folder and move its contents to the root
        let fastpitchFolder = modelsDirectory.appendingPathComponent("fastpitch_hifigan")
        if FileManager.default.fileExists(atPath: fastpitchFolder.path) {
            let contents = try FileManager.default.contentsOfDirectory(at: fastpitchFolder, includingPropertiesForKeys: nil)
            
            for item in contents {
                let destinationURL = modelsDirectory.appendingPathComponent(item.lastPathComponent)
                try? FileManager.default.removeItem(at: destinationURL)
                try FileManager.default.moveItem(at: item, to: destinationURL)
            }
            
            try? FileManager.default.removeItem(at: fastpitchFolder)
        }
    }
    
    func clearModels() throws {
        if FileManager.default.fileExists(atPath: modelsDirectory.path) {
            try FileManager.default.removeItem(at: modelsDirectory)
        }
        if FileManager.default.fileExists(atPath: zipFileURL.path) {
            try FileManager.default.removeItem(at: zipFileURL)
        }
    }
}