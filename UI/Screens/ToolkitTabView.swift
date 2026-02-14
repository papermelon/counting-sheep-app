//
//  ToolkitTabView.swift
//  Counting Sheep
//

import SwiftUI
import PDFKit

struct ToolkitTabView: View {
    private struct ReadingItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let icon: String
        let fileName: String
    }

    private struct AudioItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let icon: String
        let isAvailable: Bool
    }

    private let readingItems: [ReadingItem] = [
        ReadingItem(
            id: "sleep_wellness_booklet",
            title: "Sleep Wellness Booklet",
            subtitle: "Foundational guide for healthier sleep",
            icon: "book.closed.fill",
            fileName: "Sleep Wellness Booklet"
        )
    ]

    private let audioItems: [AudioItem] = [
        AudioItem(id: "body_scan", title: "Body Scan", subtitle: "Guided relaxation", icon: "waveform.path.ecg", isAvailable: false),
        AudioItem(id: "pmr", title: "Progressive Muscle Relaxation", subtitle: "Tension release sequence", icon: "figure.strengthtraining.functional", isAvailable: false),
        AudioItem(id: "yoga_nidra", title: "Yoga Nidra (NSDR)", subtitle: "Deep rest practice", icon: "figure.mind.and.body", isAvailable: false),
    ]
    @State private var selectedPDFURL: URL?
    @State private var showMissingResourceAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                List {
                    Section {
                        ForEach(readingItems) { item in
                            Button {
                                if let url = Bundle.main.url(forResource: item.fileName, withExtension: "pdf") {
                                    selectedPDFURL = url
                                } else {
                                    showMissingResourceAlert = true
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: item.icon)
                                        .font(.title2)
                                        .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(Color.white.opacity(0.12)))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.title)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                        Text(item.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.72))
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.55))
                                }
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.white.opacity(0.08))
                            .listRowSeparatorTint(.white.opacity(0.2))
                        }
                    } header: {
                        Text("Reading")
                            .foregroundStyle(.secondary)
                    }

                    Section {
                        ForEach(audioItems) { item in
                            HStack(spacing: 16) {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                                    .frame(width: 44, height: 44)
                                    .background(Circle().fill(Color.white.opacity(0.12)))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.72))
                                }
                                Spacer()
                                if !item.isAvailable {
                                    Text("Coming soon")
                                        .font(.caption2)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.85))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(Capsule().fill(Color.white.opacity(0.16)))
                                }
                            }
                            .listRowBackground(Color.white.opacity(0.08))
                            .listRowSeparatorTint(.white.opacity(0.2))
                        }
                    } header: {
                        Text("Audio")
                            .foregroundStyle(.secondary)
                    } footer: {
                        Text("More toolkit content can be added as reading PDFs and guided audio tracks.")
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Toolkit")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(white: 0.08), for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .sheet(isPresented: Binding(
                    get: { selectedPDFURL != nil },
                    set: { if !$0 { selectedPDFURL = nil } }
                )) {
                    NavigationStack {
                        if let url = selectedPDFURL {
                            PDFReaderView(url: url)
                                .navigationTitle("Sleep Wellness Booklet")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbarBackground(Color(white: 0.08), for: .navigationBar)
                                .toolbarColorScheme(.dark, for: .navigationBar)
                                .toolbar {
                                    ToolbarItem(placement: .topBarLeading) {
                                        Button {
                                            selectedPDFURL = nil
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    ToolbarItem(placement: .topBarTrailing) {
                                        Button("Done") {
                                            selectedPDFURL = nil
                                        }
                                        .foregroundStyle(.white)
                                    }
                                }
                        }
                    }
                }
                .alert("Resource not found", isPresented: $showMissingResourceAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("The Sleep Wellness Booklet PDF is not available in this build.")
                }
            }
        }
    }
}

private struct PDFReaderView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .black
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

#Preview {
    ToolkitTabView()
}
