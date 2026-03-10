//
//  FormField.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI

enum FormFieldType {
    case text
    case multiline
    case date
    case picker
}

struct FormField {
    let key: String
    let question: String
    let hint: String?
    let type: FormFieldType
    let placeholder: String?
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let isOptional: Bool
    let pickerOptions: [String]?
    
    init(
        key: String,
        question: String,
        hint: String? = nil,
        type: FormFieldType,
        placeholder: String? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        isOptional: Bool = false,
        pickerOptions: [String]? = nil
    ) {
        self.key = key
        self.question = question
        self.hint = hint
        self.type = type
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.isOptional = isOptional
        self.pickerOptions = pickerOptions
    }
}

// Form fields factory
struct FormFieldsFactory {
    static func fields(for documentType: DocumentType) -> [FormField] {
        switch documentType {
        case .cv:
            return cvFields()
        case .coverLetter:
            return coverLetterFields()
        case .letter:
            return letterFields()
        case .receipt:
            return receiptFields()
        case .businessCard:
            return businessCardFields()
        case .freeform:
            return []
        }
    }
    
    // MARK: - CV Fields (11 steps)
    static func cvFields() -> [FormField] {
        return [
            FormField(
                key: "fullName",
                question: "What's your full name?",
                type: .text,
                placeholder: "John Smith",
                textContentType: .name
            ),
            FormField(
                key: "professionalTitle",
                question: "What's your professional title?",
                hint: "e.g. Software Engineer, Product Designer",
                type: .text,
                placeholder: "Software Engineer",
                textContentType: .jobTitle
            ),
            FormField(
                key: "email",
                question: "Your email address",
                type: .text,
                placeholder: "john@example.com",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            ),
            FormField(
                key: "phone",
                question: "Your phone number",
                type: .text,
                placeholder: "+1 (555) 123-4567",
                keyboardType: .phonePad,
                textContentType: .telephoneNumber
            ),
            FormField(
                key: "location",
                question: "Where are you based?",
                hint: "City, Country",
                type: .text,
                placeholder: "Paris, France",
                textContentType: .fullStreetAddress
            ),
            FormField(
                key: "summary",
                question: "Write your professional summary",
                hint: "2-3 sentences about your experience and expertise",
                type: .multiline,
                placeholder: "Passionate software engineer with 5 years of experience..."
            ),
            FormField(
                key: "experience",
                question: "Add your work experience",
                hint: "List your most recent positions (company, role, dates, description)",
                type: .multiline,
                placeholder: "Software Engineer at Google\n2020 - Present\nDeveloped features for Google Search..."
            ),
            FormField(
                key: "education",
                question: "Add your education",
                hint: "List your degrees (institution, degree, dates)",
                type: .multiline,
                placeholder: "Bachelor of Science in Computer Science\nStanford University\n2016 - 2020"
            ),
            FormField(
                key: "skills",
                question: "List your skills",
                hint: "Separate with commas",
                type: .text,
                placeholder: "Swift, iOS, SwiftUI, UIKit, Xcode"
            ),
            FormField(
                key: "languages",
                question: "Languages you speak",
                hint: "Separate with commas, include proficiency level",
                type: .text,
                placeholder: "English (Native), French (Fluent), Spanish (Intermediate)"
            ),
            FormField(
                key: "links",
                question: "Any online profiles?",
                hint: "LinkedIn, GitHub, Portfolio, etc.",
                type: .multiline,
                placeholder: "LinkedIn: linkedin.com/in/johnsmith\nGitHub: github.com/johnsmith",
                isOptional: true
            ),
        ]
    }
    
    // MARK: - Cover Letter Fields (12 steps)
    static func coverLetterFields() -> [FormField] {
        return [
            FormField(
                key: "fullName",
                question: "Your full name",
                type: .text,
                placeholder: "John Smith",
                textContentType: .name
            ),
            FormField(
                key: "yourAddress",
                question: "Your address",
                type: .multiline,
                placeholder: "123 Main Street\nParis, France 75001",
                textContentType: .fullStreetAddress
            ),
            FormField(
                key: "date",
                question: "Today's date",
                type: .date
            ),
            FormField(
                key: "recipientName",
                question: "Recipient's name",
                hint: "Hiring manager or contact person",
                type: .text,
                placeholder: "Jane Doe",
                textContentType: .name
            ),
            FormField(
                key: "recipientTitle",
                question: "Recipient's job title",
                type: .text,
                placeholder: "Hiring Manager",
                textContentType: .jobTitle
            ),
            FormField(
                key: "companyName",
                question: "Company name",
                type: .text,
                placeholder: "Google",
                textContentType: .organizationName
            ),
            FormField(
                key: "companyAddress",
                question: "Company address",
                type: .multiline,
                placeholder: "1600 Amphitheatre Parkway\nMountain View, CA 94043",
                textContentType: .fullStreetAddress
            ),
            FormField(
                key: "position",
                question: "What role are you applying for?",
                type: .text,
                placeholder: "Senior iOS Engineer",
                textContentType: .jobTitle
            ),
            FormField(
                key: "howFound",
                question: "How did you find this role?",
                type: .text,
                placeholder: "LinkedIn job posting"
            ),
            FormField(
                key: "whyRole",
                question: "Why do you want this role?",
                hint: "What excites you about this opportunity?",
                type: .multiline,
                placeholder: "I'm passionate about building exceptional iOS apps..."
            ),
            FormField(
                key: "keyStrengths",
                question: "What are your key strengths for this role?",
                hint: "What makes you a great fit?",
                type: .multiline,
                placeholder: "I have 5 years of experience building iOS apps with Swift..."
            ),
            FormField(
                key: "closingTone",
                question: "Closing tone",
                type: .picker,
                pickerOptions: ["Formal", "Semi-formal"]
            ),
        ]
    }
    
    // MARK: - Formal Letter Fields (8 steps)
    static func letterFields() -> [FormField] {
        return [
            FormField(
                key: "fullName",
                question: "Your full name",
                type: .text,
                placeholder: "John Smith",
                textContentType: .name
            ),
            FormField(
                key: "yourAddress",
                question: "Your address",
                type: .multiline,
                placeholder: "123 Main Street\nParis, France 75001",
                textContentType: .fullStreetAddress
            ),
            FormField(
                key: "date",
                question: "Date",
                type: .date
            ),
            FormField(
                key: "recipientName",
                question: "Recipient's name",
                type: .text,
                placeholder: "John Doe",
                textContentType: .name
            ),
            FormField(
                key: "recipientAddress",
                question: "Recipient's address",
                type: .multiline,
                placeholder: "456 Elm Street\nLondon, UK",
                textContentType: .fullStreetAddress
            ),
            FormField(
                key: "subject",
                question: "Subject line",
                type: .text,
                placeholder: "Request for Apartment Repair"
            ),
            FormField(
                key: "body",
                question: "Letter body",
                hint: "Write the main content of your letter",
                type: .multiline,
                placeholder: "Dear Sir/Madam,\n\nI am writing to..."
            ),
            FormField(
                key: "closingSalutation",
                question: "Closing salutation",
                type: .picker,
                pickerOptions: ["Yours sincerely", "Yours faithfully", "Best regards"]
            ),
        ]
    }
    
    // MARK: - Receipt Fields (10 steps) - Pro
    static func receiptFields() -> [FormField] {
        return [
            FormField(
                key: "businessName",
                question: "Business name",
                type: .text,
                placeholder: "Acme Inc.",
                textContentType: .organizationName
            ),
            FormField(
                key: "businessAddress",
                question: "Business address",
                type: .multiline,
                placeholder: "123 Business Ave\nCity, Country",
                textContentType: .fullStreetAddress
            ),
            FormField(
                key: "receiptNumber",
                question: "Receipt number",
                hint: "A unique identifier for this receipt",
                type: .text,
                placeholder: "#001234",
                keyboardType: .numbersAndPunctuation
            ),
            FormField(
                key: "date",
                question: "Date",
                type: .date
            ),
            FormField(
                key: "customerName",
                question: "Customer name",
                type: .text,
                placeholder: "John Smith",
                textContentType: .name
            ),
            FormField(
                key: "lineItems",
                question: "Line items",
                hint: "Item name and price on each line",
                type: .multiline,
                placeholder: "Web Design - $500\nLogo Design - $200\nBranding - $300"
            ),
            FormField(
                key: "taxRate",
                question: "Tax rate (%)",
                type: .text,
                placeholder: "20",
                keyboardType: .decimalPad
            ),
            FormField(
                key: "paymentMethod",
                question: "Payment method",
                type: .picker,
                pickerOptions: ["Cash", "Card", "Bank Transfer", "Other"]
            ),
            FormField(
                key: "notes",
                question: "Notes",
                hint: "Additional information (optional)",
                type: .multiline,
                placeholder: "Thank you for your business!",
                isOptional: true
            ),
            FormField(
                key: "logo",
                question: "Business logo",
                hint: "Optional - you can add a logo later",
                type: .text,
                placeholder: "No logo",
                isOptional: true
            ),
        ]
    }
    
    // MARK: - Business Card Fields (9 steps) - Pro
    static func businessCardFields() -> [FormField] {
        return [
            FormField(
                key: "fullName",
                question: "Full name",
                type: .text,
                placeholder: "John Smith",
                textContentType: .name
            ),
            FormField(
                key: "title",
                question: "Professional title",
                type: .text,
                placeholder: "Founder & CEO",
                textContentType: .jobTitle
            ),
            FormField(
                key: "company",
                question: "Company name",
                type: .text,
                placeholder: "Acme Inc.",
                textContentType: .organizationName
            ),
            FormField(
                key: "email",
                question: "Email",
                type: .text,
                placeholder: "john@acme.com",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            ),
            FormField(
                key: "phone",
                question: "Phone",
                type: .text,
                placeholder: "+1 (555) 123-4567",
                keyboardType: .phonePad,
                textContentType: .telephoneNumber
            ),
            FormField(
                key: "website",
                question: "Website",
                type: .text,
                placeholder: "www.acme.com",
                keyboardType: .URL,
                textContentType: .URL
            ),
            FormField(
                key: "linkedin",
                question: "LinkedIn URL",
                hint: "Optional",
                type: .text,
                placeholder: "linkedin.com/in/johnsmith",
                keyboardType: .URL,
                textContentType: .URL,
                isOptional: true
            ),
            FormField(
                key: "address",
                question: "Address",
                hint: "Optional",
                type: .multiline,
                placeholder: "123 Business Ave, City",
                textContentType: .fullStreetAddress,
                isOptional: true
            ),
            FormField(
                key: "cardStyle",
                question: "Card style",
                type: .picker,
                pickerOptions: ["Classic", "Minimal", "Bold"]
            ),
        ]
    }
}
