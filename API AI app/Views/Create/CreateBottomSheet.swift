//
//  CreateBottomSheet.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

struct CreateBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMode: InputMode = .text
    @State private var promptText = ""
    @Binding var showStepForm: Bool
    @Binding var selectedTemplateForForm: DocumentType?
    @Binding var showGenerating: Bool
    @Binding var freeformPrompt: String
    @Binding var freeformDocumentType: String

    enum InputMode {
        case text
        case voice
    }

    var isGenerateEnabled: Bool {
        !promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.secondaryText.opacity(0.2))
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.sm)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    Text("Create a PDF")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primaryText)
                        .tracking(-0.3)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.md)

                    // Mode selector
                    ModeSelector(selectedMode: $selectedMode)
                        .padding(.horizontal, Spacing.lg)

                    if selectedMode == .text {
                        TextInputMode(
                            promptText: $promptText,
                            onTemplateSelected: { template in
                                selectedTemplateForForm = template
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showStepForm = true
                                }
                            }
                        )
                    } else {
                        VoiceInputView(
                            onTranscriptionComplete: { text in
                                promptText = text
                                selectedMode = .text
                            }
                        )
                    }

                    if selectedMode == .text && isGenerateEnabled {
                        Button(action: {
                            HapticHelper.medium()
                            freeformPrompt = promptText
                            freeformDocumentType = "freeform"
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showGenerating = true
                            }
                        }) {
                            Text("Generate PDF")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.brand)
                                .cornerRadius(Radius.button)
                        }
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                    }
                }
            }
        }
        .background(Color.background)
    }
}

struct ModeSelector: View {
    @Binding var selectedMode: CreateBottomSheet.InputMode
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ModeButton(
                icon: "character.cursor.ibeam",
                title: "Text",
                isSelected: selectedMode == .text,
                animation: animation,
                action: {
                    HapticHelper.light()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = .text
                    }
                }
            )

            ModeButton(
                icon: "mic",
                title: "Voice",
                isSelected: selectedMode == .voice,
                animation: animation,
                action: {
                    HapticHelper.light()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = .voice
                    }
                }
            )
        }
        .padding(4)
        .background(Color.surface)
        .cornerRadius(Radius.button)
    }
}

struct ModeButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .primaryText : .secondaryText)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: Radius.input)
                            .fill(Color.cardBackground)
                            .matchedGeometryEffect(id: "selector", in: animation)
                            .cardShadow()
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TextInputMode: View {
    @Binding var promptText: String
    let onTemplateSelected: (DocumentType) -> Void
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Template chips
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Templates")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .padding(.horizontal, Spacing.lg)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(DocumentType.allCases, id: \.self) { type in
                            TemplateChipButton(
                                documentType: type,
                                action: {
                                    HapticHelper.medium()
                                    isTextFieldFocused = false
                                    if type.isPro {
                                        print("Show paywall for \(type.displayName)")
                                    } else {
                                        onTemplateSelected(type)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }

            // Divider
            HStack(spacing: Spacing.md) {
                Rectangle().fill(Color.border).frame(height: 0.5)
                Text("or describe freely")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondaryText)
                    .layoutPriority(1)
                Rectangle().fill(Color.border).frame(height: 0.5)
            }
            .padding(.horizontal, Spacing.lg)

            // Text editor
            ZStack(alignment: .topLeading) {
                TextEditor(text: $promptText)
                    .font(.system(size: 15))
                    .foregroundColor(.primaryText)
                    .tint(.brand)
                    .focused($isTextFieldFocused)
                    .frame(minHeight: 100, maxHeight: 180)
                    .padding(Spacing.sm)
                    .background(Color.cardBackground)
                    .cornerRadius(Radius.input)
                    .cardShadow()

                if promptText.isEmpty && !isTextFieldFocused {
                    Text("Describe your document...")
                        .font(.system(size: 15))
                        .foregroundColor(.secondaryText.opacity(0.5))
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, Spacing.lg)

            Text("\(promptText.count)/1000")
                .font(.system(size: 11))
                .foregroundColor(.secondaryText.opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, Spacing.lg)
        }
    }
}

struct TemplateChipButton: View {
    let documentType: DocumentType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: documentType.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(documentType.color)

                Text(documentType.displayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primaryText)

                if documentType.isPro {
                    Text("PRO")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.proGold)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.proGold.opacity(0.12))
                        .cornerRadius(3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.cardBackground)
            .cornerRadius(Radius.pill)
            .cardShadow()
        }
        .pressableButton()
    }
}

#Preview {
    @Previewable @State var showForm = false
    @Previewable @State var template: DocumentType? = nil
    @Previewable @State var showGen = false
    @Previewable @State var prompt = ""
    @Previewable @State var docType = ""

    CreateBottomSheet(
        showStepForm: $showForm,
        selectedTemplateForForm: $template,
        showGenerating: $showGen,
        freeformPrompt: $prompt,
        freeformDocumentType: $docType
    )
}
