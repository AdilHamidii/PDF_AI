//
//  GeneratingView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import SwiftData

struct GeneratingView: View {
    let prompt: String?
    let documentType: String
    let formData: [String: Any]?

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var currentStage = 0
    @State private var showCancelAlert = false
    @State private var progress: CGFloat = 0
    @State private var generationTask: Task<Void, Never>?
    @State private var errorMessage: String?
    @State private var generatedDocument: DocumentModel?
    @State private var localPDFURL: URL?
    @State private var showPDFViewer = false

    let stages = [
        "Understanding your request",
        "Writing LaTeX code",
        "Compiling document",
        "Finishing up"
    ]

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            // Title
            AnimatedTitleView()

            // Progress ring
            ZStack {
                Circle()
                    .stroke(Color.surface, lineWidth: 4)
                    .frame(width: 110, height: 110)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.brand, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: progress)

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.primaryText)
            }

            // Stages
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(0..<stages.count, id: \.self) { index in
                    StageRow(
                        text: stages[index],
                        state: stageState(for: index),
                        isVisible: index <= currentStage
                    )
                }
            }
            .padding(.horizontal, Spacing.xl)

            // Error message
            if let errorMessage {
                VStack(spacing: Spacing.sm) {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        self.errorMessage = nil
                        self.currentStage = 0
                        self.progress = 0
                        startGeneration()
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.brand)
                }
                .padding(.horizontal, Spacing.xl)
            }

            Spacer()

            // Ad placeholder
            VStack(spacing: Spacing.xs) {
                Text("Ad")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondaryText.opacity(0.3))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .frame(width: 320, height: 200)
            .background(Color.cardBackground)
            .cornerRadius(Radius.card)
            .cardShadow()

            Spacer()
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCancelAlert = true }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
        }
        .alert("Cancel generation?", isPresented: $showCancelAlert) {
            Button("Continue", role: .cancel) {}
            Button("Cancel", role: .destructive) {
                generationTask?.cancel()
                dismiss()
            }
        } message: {
            Text("Your PDF generation will be stopped.")
        }
        .navigationDestination(isPresented: $showPDFViewer) {
            if let doc = generatedDocument, let url = localPDFURL {
                PDFViewerView(document: doc, pdfURL: url)
            }
        }
        .onAppear { startGeneration() }
        .onDisappear { generationTask?.cancel() }
    }

    private func stageState(for index: Int) -> StageRowState {
        if index < currentStage { return .completed }
        if index == currentStage { return .active }
        return .pending
    }

    private func startGeneration() {
        generationTask = Task {
            do {
                // Stage 0: Understanding request
                withAnimation { progress = 0.1 }

                // Stage 1: Writing LaTeX (API call starts)
                try await Task.sleep(for: .milliseconds(600))
                if Task.isCancelled { return }
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.3)) { currentStage = 1 }
                    withAnimation { progress = 0.25 }
                }

                // Make API call
                let response = try await PDFService.shared.generate(
                    prompt: prompt,
                    documentType: documentType,
                    formData: formData
                )

                if Task.isCancelled { return }

                // Stage 2: Compiling (API returned, downloading PDF)
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.3)) { currentStage = 2 }
                    withAnimation { progress = 0.65 }
                }

                // Download PDF to local file
                let localURL = try await PDFService.shared.downloadPDF(from: response.pdfUrl)

                if Task.isCancelled { return }

                // Stage 3: Finishing up (save to SwiftData)
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.3)) { currentStage = 3 }
                    withAnimation { progress = 0.9 }
                }

                try await Task.sleep(for: .milliseconds(400))
                if Task.isCancelled { return }

                // Save document
                let title = generateTitle()
                await MainActor.run {
                    let document = DocumentModel(
                        title: title,
                        documentType: documentType,
                        promptUsed: prompt ?? "Template form",
                        pdfUrl: response.pdfUrl,
                        pdfKey: response.pdfKey,
                        latexCode: response.latex
                    )
                    modelContext.insert(document)
                    try? modelContext.save()

                    withAnimation { progress = 1.0 }
                    generatedDocument = document
                    localPDFURL = localURL

                    HapticHelper.success()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showPDFViewer = true
                    }
                }

            } catch is CancellationError {
                // User cancelled
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    HapticHelper.error()
                }
            }
        }
    }

    private func generateTitle() -> String {
        if let type = DocumentType(rawValue: documentType) {
            return "\(type.displayName) - \(Date().formatted(date: .abbreviated, time: .omitted))"
        }
        return "Document - \(Date().formatted(date: .abbreviated, time: .omitted))"
    }
}

struct AnimatedTitleView: View {
    @State private var animatedLetters: [Bool]
    let title = "Creating your PDF..."

    init() {
        _animatedLetters = State(initialValue: Array(repeating: false, count: "Creating your PDF...".count))
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(title.enumerated()), id: \.offset) { index, character in
                Text(String(character))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primaryText)
                    .tracking(-0.3)
                    .opacity(animatedLetters.indices.contains(index) && animatedLetters[index] ? 1.0 : 0.0)
            }
        }
        .onAppear {
            for index in 0..<title.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.04) {
                    withAnimation(.easeIn(duration: 0.08)) {
                        if animatedLetters.indices.contains(index) {
                            animatedLetters[index] = true
                        }
                    }
                }
            }
        }
    }
}

enum StageRowState {
    case completed, active, pending
}

struct StageRow: View {
    let text: String
    let state: StageRowState
    let isVisible: Bool

    @State private var hasAppeared = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Group {
                switch state {
                case .completed:
                    ZStack {
                        Circle()
                            .fill(Color.success.opacity(0.12))
                            .frame(width: 24, height: 24)

                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.success)
                    }
                case .active:
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.brand)
                        .frame(width: 24, height: 24)
                case .pending:
                    Circle()
                        .fill(Color.surface)
                        .frame(width: 24, height: 24)
                }
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(state == .pending ? .secondaryText.opacity(0.4) : .primaryText)

            Spacer()
        }
        .opacity(hasAppeared ? 1.0 : 0.0)
        .offset(y: hasAppeared ? 0 : 10)
        .onChange(of: isVisible) { _, newValue in
            if newValue && !hasAppeared {
                withAnimation(.easeOut(duration: 0.3)) {
                    hasAppeared = true
                }
            }
        }
        .onAppear {
            if isVisible {
                withAnimation(.easeOut(duration: 0.3)) {
                    hasAppeared = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GeneratingView(prompt: "Create a CV", documentType: "cv", formData: nil)
    }
    .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
