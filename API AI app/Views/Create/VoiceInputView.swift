//
//  VoiceInputView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import Speech
import AVFoundation
import Combine

struct VoiceInputView: View {
    let onTranscriptionComplete: (String) -> Void

    @StateObject private var voiceManager = VoiceInputManager()
    @State private var showPermissionAlert = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Waveform
            WaveformView(audioLevel: voiceManager.audioLevel, isRecording: voiceManager.isRecording)
                .frame(height: 100)
                .padding(.horizontal, Spacing.lg)

            // Mic button
            Button(action: {
                if voiceManager.hasPermissions {
                    if voiceManager.isRecording {
                        voiceManager.stopRecording()
                        if !voiceManager.transcribedText.isEmpty {
                            onTranscriptionComplete(voiceManager.transcribedText)
                        }
                    } else {
                        voiceManager.startRecording()
                    }
                } else {
                    showPermissionAlert = true
                }
            }) {
                Circle()
                    .fill(voiceManager.isRecording ? Color.error : Color.brand)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: voiceManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                    )
                    .shadow(color: (voiceManager.isRecording ? Color.error : Color.brand).opacity(0.2), radius: 8, x: 0, y: 3)
            }

            Text(voiceManager.isRecording ? "Tap to stop" : "Tap to speak")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondaryText)

            // Transcription preview
            if !voiceManager.transcribedText.isEmpty {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Transcription")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    Text(voiceManager.transcribedText)
                        .font(.system(size: 15))
                        .foregroundColor(.primaryText)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.surface)
                        .cornerRadius(Radius.input)

                    Button(action: {
                        voiceManager.transcribedText = ""
                        voiceManager.startRecording()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Re-record")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.brand)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.lg)
        .onAppear { voiceManager.requestPermissions() }
        .onDisappear { voiceManager.stopRecording() }
        .alert("Microphone Access Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("PDFai needs microphone access for voice input.")
        }
    }
}

struct WaveformView: View {
    let audioLevel: CGFloat
    let isRecording: Bool

    private let barCount = 30

    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    height: barHeight(for: index),
                    isRecording: isRecording,
                    delay: Double(index) * 0.02
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func barHeight(for index: Int) -> CGFloat {
        let normalizedIndex = CGFloat(index) / CGFloat(barCount)
        let center = CGFloat(0.5)
        let distance = abs(normalizedIndex - center)
        let baseHeight: CGFloat = 0.15
        let variation = (1.0 - distance * 2) * audioLevel
        return max(baseHeight, variation)
    }
}

struct WaveformBar: View {
    let height: CGFloat
    let isRecording: Bool
    let delay: Double

    @State private var animatedHeight: CGFloat = 0.15

    var body: some View {
        Capsule()
            .fill(Color.brand.opacity(0.6))
            .frame(width: 2.5)
            .frame(height: 100 * animatedHeight)
            .animation(.linear(duration: 0.1), value: animatedHeight)
            .onChange(of: height) { _, newValue in
                if isRecording { animatedHeight = newValue }
            }
            .onChange(of: isRecording) { _, newValue in
                if !newValue { animatedHeight = 0.15 }
            }
            .onAppear {
                if isRecording {
                    withAnimation(.linear(duration: 0.1).delay(delay)) {
                        animatedHeight = height
                    }
                }
            }
    }
}

// Voice input manager
class VoiceInputManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var audioLevel: CGFloat = 0.15
    @Published var hasPermissions = false

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.hasPermissions = status == .authorized
            }
        }
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermissions = self.hasPermissions && granted
            }
        }
    }

    func startRecording() {
        guard hasPermissions else { return }

        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        transcribedText = ""

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
            let channelData = buffer.floatChannelData?[0]
            let channelDataValue = channelData?.pointee ?? 0
            let level = abs(channelDataValue)
            DispatchQueue.main.async {
                self.audioLevel = min(CGFloat(level) * 10, 1.0)
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine error: \(error)")
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }
            if error != nil || result?.isFinal == true {
                self.stopRecording()
            }
        }

        isRecording = true
        HapticHelper.medium()
    }

    func stopRecording() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil

        isRecording = false
        audioLevel = 0.15
        HapticHelper.medium()
    }
}

#Preview {
    VoiceInputView { text in
        print("Transcribed: \(text)")
    }
}
