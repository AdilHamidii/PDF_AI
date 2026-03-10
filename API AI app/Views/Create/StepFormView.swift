//
//  StepFormView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import Combine

struct StepFormView: View {
    let documentType: DocumentType
    let onComplete: ([String: Any]) -> Void

    @Environment(\.dismiss) var dismiss
    @StateObject private var formManager: FormManager
    @FocusState private var isFieldFocused: Bool

    init(documentType: DocumentType, onComplete: @escaping ([String: Any]) -> Void) {
        self.documentType = documentType
        self.onComplete = onComplete
        self._formManager = StateObject(wrappedValue: FormManager(documentType: documentType))
    }

    var progress: CGFloat {
        CGFloat(formManager.currentStep + 1) / CGFloat(formManager.totalSteps)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Step \(formManager.currentStep + 1) of \(formManager.totalSteps)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondaryText)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.surface)
                            .frame(height: 6)

                        Capsule()
                            .fill(Color.brand)
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.md)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    if let currentField = formManager.currentField {
                        FormFieldView(
                            field: currentField,
                            value: Binding(
                                get: { formManager.fieldValues[currentField.key] ?? "" },
                                set: { formManager.fieldValues[currentField.key] = $0 }
                            ),
                            isFieldFocused: _isFieldFocused
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id(currentField.key)
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.xl)
            }

            Spacer()

            // Bottom buttons
            HStack(spacing: Spacing.sm) {
                if formManager.currentStep > 0 {
                    Button(action: {
                        HapticHelper.light()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            formManager.previousStep()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primaryText)
                            .frame(width: 54, height: 54)
                            .background(Color.cardBackground)
                            .cornerRadius(Radius.button)
                            .cardShadow()
                    }
                }

                if formManager.currentField?.isOptional == true && !formManager.isLastStep {
                    Button(action: {
                        HapticHelper.light()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            formManager.nextStep()
                        }
                    }) {
                        Text("Skip")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.horizontal, Spacing.sm)
                }

                Button(action: {
                    HapticHelper.medium()
                    if formManager.isLastStep && formManager.isCurrentFieldValid {
                        let formData = formManager.collectFormData()
                        onComplete(formData)
                        dismiss()
                    } else if formManager.isCurrentFieldValid {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            formManager.nextStep()
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Text(formManager.isLastStep ? "Generate PDF" : "Next")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(formManager.isCurrentFieldValid ? Color.brand : Color.secondaryText.opacity(0.2))
                    .cornerRadius(Radius.button)
                }
                .disabled(!formManager.isCurrentFieldValid)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
        .background(Color.background)
        .navigationTitle(documentType.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryText)
                }
            }
        }
    }
}

// Form field view
struct FormFieldView: View {
    let field: FormField
    @Binding var value: Any
    @FocusState var isFieldFocused: Bool

    var stringValue: Binding<String> {
        Binding(
            get: { value as? String ?? "" },
            set: { value = $0 }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(field.question)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primaryText)
                .tracking(-0.3)

            if let hint = field.hint {
                Text(hint)
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryText)
            }

            switch field.type {
            case .text:
                TextField(field.placeholder ?? "", text: stringValue)
                    .font(.system(size: 15))
                    .foregroundColor(.primaryText)
                    .tint(.brand)
                    .padding(Spacing.md)
                    .background(Color.cardBackground)
                    .cornerRadius(Radius.input)
                    .cardShadow()
                    .focused($isFieldFocused)
                    .keyboardType(field.keyboardType)
                    .textContentType(field.textContentType)
                    .autocorrectionDisabled(field.keyboardType == .emailAddress)
                    .textInputAutocapitalization(field.keyboardType == .emailAddress ? .never : .words)
                    .onAppear { isFieldFocused = true }

            case .multiline:
                TextEditor(text: stringValue)
                    .font(.system(size: 15))
                    .foregroundColor(.primaryText)
                    .tint(.brand)
                    .frame(minHeight: 120)
                    .padding(Spacing.sm)
                    .background(Color.cardBackground)
                    .cornerRadius(Radius.input)
                    .cardShadow()
                    .focused($isFieldFocused)
                    .onAppear { isFieldFocused = true }

            case .date:
                DatePicker(
                    "",
                    selection: Binding(
                        get: { value as? Date ?? Date() },
                        set: { value = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(.brand)

            case .picker:
                if let options = field.pickerOptions {
                    VStack(spacing: Spacing.sm) {
                        ForEach(options, id: \.self) { option in
                            Button(action: {
                                HapticHelper.selection()
                                value = option
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primaryText)

                                    Spacer()

                                    if (value as? String) == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.brand)
                                    } else {
                                        Circle()
                                            .stroke(Color.border, lineWidth: 1.5)
                                            .frame(width: 18, height: 18)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(Color.cardBackground)
                                .cornerRadius(Radius.input)
                                .cardShadow()
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.input)
                                        .stroke(
                                            (value as? String) == option ? Color.brand : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

// Form manager
class FormManager: ObservableObject {
    let documentType: DocumentType
    @Published var currentStep = 0
    var fieldValues: [String: Any] = [:] {
        didSet { objectWillChange.send() }
    }

    let fields: [FormField]

    var totalSteps: Int { fields.count }
    var currentField: FormField? { fields.indices.contains(currentStep) ? fields[currentStep] : nil }
    var isLastStep: Bool { currentStep == fields.count - 1 }

    var isCurrentFieldValid: Bool {
        guard let field = currentField else { return false }
        if field.isOptional { return true }

        let value = fieldValues[field.key]

        switch field.type {
        case .text, .multiline:
            if let string = value as? String {
                return !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return false
        case .date:
            return value is Date
        case .picker:
            if let string = value as? String {
                return !string.isEmpty
            }
            return false
        }
    }

    init(documentType: DocumentType) {
        self.documentType = documentType
        self.fields = FormFieldsFactory.fields(for: documentType)

        for field in fields where field.type == .date {
            fieldValues[field.key] = Date()
        }
    }

    func nextStep() {
        if currentStep < fields.count - 1 { currentStep += 1 }
    }

    func previousStep() {
        if currentStep > 0 { currentStep -= 1 }
    }

    func collectFormData() -> [String: Any] {
        var data: [String: Any] = [:]
        data["documentType"] = documentType.rawValue

        for field in fields {
            if let value = fieldValues[field.key] {
                if let date = value as? Date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    data[field.key] = formatter.string(from: date)
                } else {
                    data[field.key] = value
                }
            }
        }

        return data
    }
}

#Preview {
    NavigationStack {
        StepFormView(documentType: .cv) { data in
            print(data)
        }
    }
}
