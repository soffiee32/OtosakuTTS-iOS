//
//  ContentView.swift
//  Example
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var viewModel = TTSViewModel()
    @State private var inputText = "The quick brown fox jumps over the lazy dog."
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Text to synthesize:")
                        .font(.headline)
                    
                    TextEditor(text: $inputText)
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal)
                
                if viewModel.isDownloading {
                    VStack(spacing: 12) {
                        ProgressView(value: viewModel.downloadProgress)
                            .progressViewStyle(.linear)
                            .padding(.horizontal)
                        
                        Text("Downloading models... \(Int(viewModel.downloadProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if viewModel.isProcessing {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Generating speech...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    Task {
                        await viewModel.synthesizeSpeech(from: inputText)
                    }
                }) {
                    Label("Speak", systemImage: "speaker.wave.3.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canSynthesize ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.canSynthesize || inputText.isEmpty)
                .padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("OtosakuTTS Demo")
            .task {
                await viewModel.initialize()
            }
        }
    }
}
