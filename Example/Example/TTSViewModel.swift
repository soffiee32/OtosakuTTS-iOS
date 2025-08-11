//
//  TTSViewModel.swift
//  Example
//

import Foundation
import AVFoundation
import OtosakuTTS_iOS

@MainActor
class TTSViewModel: ObservableObject {
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var canSynthesize = false
    
    private var tts: OtosakuTTS?
    private let modelManager = ModelManager.shared
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        audioEngine.connect(
            playerNode,
            to: audioEngine.mainMixerNode,
            format: AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: 22_050,
                channels: 1,
                interleaved: false
            )!
        )
        
        do {
            try audioEngine.start()
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
        }
    }
    
    func initialize() async {
        errorMessage = nil
        
        if !modelManager.isModelDownloaded {
            await downloadModels()
        }
        
        if modelManager.isModelDownloaded {
            await loadTTS()
        }
    }
    
    private func downloadModels() async {
        isDownloading = true
        downloadProgress = 0
        
        do {
            try await modelManager.downloadModels { [weak self] progress in
                self?.downloadProgress = progress
            }
            await loadTTS()
        } catch {
            errorMessage = "Failed to download models: \(error.localizedDescription)"
        }
        
        isDownloading = false
    }
    
    private func loadTTS() async {
        do {
            tts = try OtosakuTTS(modelDirectoryURL: modelManager.modelsDirectory)
            canSynthesize = true
        } catch {
            errorMessage = "Failed to load TTS: \(error.localizedDescription)"
            canSynthesize = false
        }
    }
    
    func synthesizeSpeech(from text: String) async {
        guard let tts = tts else {
            errorMessage = "TTS not initialized"
            return
        }
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text"
            return
        }
        
        errorMessage = nil
        isProcessing = true
        
        do {
            let buffer = try await Task.detached(priority: .userInitiated) {
                try tts.generate(text: text)
            }.value
            
            playerNode.stop()
            playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts) { [weak self] in
                Task { @MainActor in
                    self?.isProcessing = false
                }
            }
            playerNode.play()
            
        } catch {
            errorMessage = "Failed to synthesize speech: \(error.localizedDescription)"
            isProcessing = false
        }
    }
}