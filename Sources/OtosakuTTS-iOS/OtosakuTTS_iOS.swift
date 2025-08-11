// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import CoreML
import AVFoundation

public class OtosakuTTS {
    
    private let fastPitch: MLModel
    private let hifiGAN: MLModel
    private let tokenizer: Tokenizer
    private let audioFormat: AVAudioFormat
    
    public init(modelDirectoryURL: URL, computeUnits: MLComputeUnits = .all) throws {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = computeUnits
        
        do {
            fastPitch = try MLModel(
                contentsOf: modelDirectoryURL.appendingPathComponent("FastPitch.mlmodelc"),
                configuration: configuration
            )
        } catch {
            throw OtosakuTTSError.modelLoadingFailed("FastPitch")
        }
        
        do {
            hifiGAN = try MLModel(
                contentsOf: modelDirectoryURL.appendingPathComponent("HiFiGan.mlmodelc"),
                configuration: configuration
            )
        } catch {
            throw OtosakuTTSError.modelLoadingFailed("HiFiGAN")
        }
        
        do {
            tokenizer = try Tokenizer(
                tokensFile: modelDirectoryURL.appendingPathComponent("tokens.txt"),
                dictFile: modelDirectoryURL.appendingPathComponent("cmudict.json")
            )
        } catch {
            throw OtosakuTTSError.tokenizerInitializationFailed(error.localizedDescription)
        }
        
        audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: 22_050,
            channels: 1,
            interleaved: false
        )!
    }
    
    public func generate(text: String) throws -> AVAudioPCMBuffer {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw OtosakuTTSError.emptyInput
        }
        
        let phoneIds = tokenizer.encode(text)
        
        let phones = try makeMultiArray(from: phoneIds)
        
        let fastPitchInput = try MLDictionaryFeatureProvider(dictionary: ["x": phones])
        let fastPitchOutput = try fastPitch.prediction(from: fastPitchInput)
        
        guard let spec = fastPitchOutput.featureValue(for: "spec")?.multiArrayValue else {
            throw OtosakuTTSError.specGenerationFailed
        }
        
        let hifiGANInput = try MLDictionaryFeatureProvider(dictionary: ["x": spec])
        let hifiGANOutput = try hifiGAN.prediction(from: hifiGANInput)
        
        guard let waveform = hifiGANOutput.featureValue(for: "waveform")?.multiArrayValue else {
            throw OtosakuTTSError.waveformGenerationFailed
        }
        
        return try createAudioBuffer(from: waveform)
    }
    
    private func makeMultiArray(from ints: [Int]) throws -> MLMultiArray {
        let arr = try MLMultiArray(shape: [1, NSNumber(value: ints.count)], dataType: .int32)
        for (i, v) in ints.enumerated() { 
            arr[i] = NSNumber(value: Int32(v)) 
        }
        return arr
    }
    
    private func createAudioBuffer(from array: MLMultiArray) throws -> AVAudioPCMBuffer {
        let length = array.count
        var floats = [Float](repeating: 0, count: length)
        for i in 0..<length { 
            floats[i] = array[i].floatValue 
        }
        
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFormat,
            frameCapacity: AVAudioFrameCount(length)
        ) else {
            throw OtosakuTTSError.audioBufferCreationFailed
        }
        
        buffer.frameLength = buffer.frameCapacity
        buffer.floatChannelData!.pointee.update(from: &floats, count: length)
        
        return buffer
    }
}
