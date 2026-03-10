//
//  SearchView.swift
//  PDFai
//
//  Created by Adyl on 10/03/2026.
//

import SwiftUI
import Combine
import SwiftData

struct SearchView: View {
    let documents: [DocumentModel]

    @State private var searchText = ""
    @State private var debouncedSearchText = ""
    @FocusState private var isSearchFocused: Bool

    private let debouncePublisher = PassthroughSubject<String, Never>()

    var filteredDocuments: [DocumentModel] {
        if debouncedSearchText.isEmpty {
            return documents
        }

        return documents.filter { document in
            document.title.localizedCaseInsensitiveContains(debouncedSearchText) ||
            document.documentType.localizedCaseInsensitiveContains(debouncedSearchText) ||
            document.promptUsed.localizedCaseInsensitiveContains(debouncedSearchText) ||
            DocumentType(rawValue: document.documentType)?.displayName.localizedCaseInsensitiveContains(debouncedSearchText) ?? false
        }
    }

    var groupedDocuments: [(DocumentType, [DocumentModel])] {
        let grouped = Dictionary(grouping: filteredDocuments) { document in
            DocumentType(rawValue: document.documentType) ?? .freeform
        }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondaryText)

                    TextField("Search your PDFs", text: $searchText)
                        .font(.system(size: 15))
                        .foregroundColor(.primaryText)
                        .focused($isSearchFocused)
                        .tint(.brand)
                        .autocorrectionDisabled()

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.secondaryText.opacity(0.4))
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 13)
                .background(Color.cardBackground)
                .cornerRadius(Radius.button)
                .cardShadow()
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

                // Results
                ScrollView(showsIndicators: false) {
                    if filteredDocuments.isEmpty {
                        VStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color.surface)
                                    .frame(width: 72, height: 72)

                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 28, weight: .light))
                                    .foregroundColor(.secondaryText.opacity(0.5))
                            }

                            Text("No results found")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    } else if debouncedSearchText.isEmpty {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            Text("All PDFs")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.secondaryText)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.horizontal, Spacing.md)
                                .padding(.top, Spacing.sm)

                            ForEach(filteredDocuments) { document in
                                FeaturedDocumentCard(document: document)
                                    .padding(.horizontal, Spacing.md)
                            }
                        }
                        .padding(.vertical, Spacing.sm)
                    } else {
                        VStack(alignment: .leading, spacing: Spacing.lg) {
                            ForEach(groupedDocuments, id: \.0) { type, documents in
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    HStack(spacing: Spacing.sm) {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(type.color)

                                        Text("\(type.displayName) (\(documents.count))")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.secondaryText)
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                    }
                                    .padding(.horizontal, Spacing.md)

                                    ForEach(documents) { document in
                                        FeaturedDocumentCard(document: document)
                                            .padding(.horizontal, Spacing.md)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, Spacing.sm)
                    }
                }
            }
            .background(Color.background)
        }
        .onAppear {
            isSearchFocused = true
        }
        .onReceive(
            debouncePublisher
                .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        ) { value in
            debouncedSearchText = value
        }
        .onChange(of: searchText) { _, newValue in
            debouncePublisher.send(newValue)
        }
    }
}

#Preview {
    SearchView(documents: [])
        .modelContainer(for: [UserModel.self, DocumentModel.self], inMemory: true)
}
