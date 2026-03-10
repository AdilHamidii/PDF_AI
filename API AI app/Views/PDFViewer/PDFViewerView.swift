//
//  PDFViewerView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import QuickLook
import SwiftData

struct PDFViewerView: View {
    let document: DocumentModel
    let pdfURL: URL

    @Environment(\.dismiss) var dismiss
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    @State private var showRegenerateSheet = false
    @State private var showDeleteAlert = false
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        ZStack {
            QuickLookView(url: pdfURL)
                .ignoresSafeArea()

            VStack {
                // Top bar
                HStack {
                    Button(action: {
                        HapticHelper.light()
                        dismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.brand)
                    }

                    Spacer()

                    if isEditingTitle {
                        TextField("Title", text: $editedTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .multilineTextAlignment(.center)
                            .focused($isTitleFocused)
                            .onSubmit { saveTitle() }
                    } else {
                        Text(document.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                            .onTapGesture { startEditingTitle() }
                    }

                    Spacer()

                    // Invisible spacer for centering
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 15))
                    }
                    .opacity(0)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(Color.background.opacity(0.95))

                Spacer()

                // Action bar
                HStack(spacing: Spacing.lg) {
                    ActionButton(icon: "arrow.clockwise", label: "Redo") {
                        HapticHelper.medium()
                        showRegenerateSheet = true
                    }
                    ActionButton(icon: "square.and.arrow.up", label: "Share") {
                        HapticHelper.light()
                        sharePDF()
                    }
                    ActionButton(icon: "arrow.down.circle", label: "Save") {
                        HapticHelper.light()
                        downloadPDF()
                    }
                    ActionButton(icon: "trash", label: "Delete") {
                        HapticHelper.warning()
                        showDeleteAlert = true
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(
                    Capsule()
                        .fill(Color.cardBackground)
                        .elevatedShadow()
                )
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showRegenerateSheet) {
            RegenerateSheet(document: document)
        }
        .alert("Delete PDF?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                print("Delete: \(document.title)")
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear { editedTitle = document.title }
    }

    private func startEditingTitle() {
        isEditingTitle = true
        isTitleFocused = true
    }

    private func saveTitle() {
        isEditingTitle = false
        isTitleFocused = false
        if !editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("Save title: \(editedTitle)")
        } else {
            editedTitle = document.title
        }
    }

    private func sharePDF() {
        let activityVC = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }

    private func downloadPDF() {
        let documentPicker = UIDocumentPickerViewController(forExporting: [pdfURL])
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(documentPicker, animated: true)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.brand)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondaryText)
            }
        }
    }
}

// QuickLook wrapper
struct QuickLookView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        init(url: URL) { self.url = url }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            url as QLPreviewItem
        }
    }
}

struct RegenerateSheet: View {
    let document: DocumentModel
    @Environment(\.dismiss) var dismiss
    @State private var modifications = ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("What would you like to change?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primaryText)
                        .tracking(-0.3)

                    Text("Describe your modifications")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $modifications)
                        .font(.system(size: 15))
                        .foregroundColor(.primaryText)
                        .tint(.brand)
                        .focused($isTextFieldFocused)
                        .frame(minHeight: 140)
                        .padding(Spacing.sm)
                        .background(Color.surface)
                        .cornerRadius(Radius.input)

                    if modifications.isEmpty && !isTextFieldFocused {
                        Text("e.g. Make it more formal, add a skills section...")
                            .font(.system(size: 15))
                            .foregroundColor(.secondaryText.opacity(0.5))
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)
                            .allowsHitTesting(false)
                    }
                }
                .padding(.horizontal, Spacing.lg)

                Spacer()

                Button(action: {
                    HapticHelper.medium()
                    print("Regenerate with: \(modifications)")
                    dismiss()
                }) {
                    Text("Regenerate")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(modifications.isEmpty ? Color.secondaryText.opacity(0.2) : Color.brand)
                        .cornerRadius(Radius.button)
                }
                .disabled(modifications.isEmpty)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
            .background(Color.background)
            .navigationTitle("Regenerate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.brand)
                }
            }
            .onAppear { isTextFieldFocused = true }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    PDFViewerView(
        document: DocumentModel(title: "Sample PDF", documentType: "cv", promptUsed: "Sample"),
        pdfURL: URL(string: "https://www.example.com/sample.pdf")!
    )
    .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
