//
//  ProgressTabView.swift
//  Sheep Atsume
//

import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedPage = 0

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("", selection: $selectedPage) {
                        Text("Strength").tag(0)
                        Text("Streaks").tag(1)
                        Text("30 days").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    TabView(selection: $selectedPage) {
                        strengthPage.tag(0)
                        streaksPage.tag(1)
                        last30Page.tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .navigationTitle("Progress")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color(white: 0.08), for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
    }

    private var strengthPage: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gameState.habitSheep) { sheep in
                    strengthCard(sheep)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    private func strengthCard(_ s: HabitSheep) -> some View {
        let (label, value) = strengthLabelAndValue(s)
        return HStack(spacing: 16) {
            Image(systemName: s.systemImage)
                .font(.title2)
                .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white.opacity(0.12)))
            VStack(alignment: .leading, spacing: 4) {
                Text(s.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ProgressView(value: value, total: 1.0)
                .tint(Color(red: 0.6, green: 0.5, blue: 0.9))
                .frame(width: 80)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func strengthLabelAndValue(_ s: HabitSheep) -> (String, Double) {
        switch s.growthStage {
        case .needsCare: return ("Needs care", 0.2)
        case .growing: return ("Growing", 0.5)
        case .thriving: return ("Thriving", 1.0)
        }
    }

    private var streaksPage: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gameState.habitSheep) { sheep in
                    HStack(spacing: 16) {
                        Image(systemName: sheep.systemImage)
                            .font(.title2)
                            .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(Color.white.opacity(0.12)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sheep.displayTitle)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\(sheep.consecutiveDaysDone) \(sheep.consecutiveDaysDone == 1 ? "day" : "days") streak")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    private var last30Page: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gameState.habitSheep) { sheep in
                    last30Card(sheep)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    private func last30Card(_ s: HabitSheep) -> some View {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let start = cal.date(byAdding: .day, value: -29, to: today) ?? today
        let totalDays = max(1, cal.dateComponents([.day], from: start, to: today).day ?? 30)
        let completed = s.completionDateSet.filter { $0 >= start && $0 <= today }.count
        let pct = totalDays > 0 ? Double(completed) / Double(totalDays) * 100 : 0
        return HStack(spacing: 16) {
            Image(systemName: s.systemImage)
                .font(.title2)
                .foregroundStyle(Color(red: 0.6, green: 0.5, blue: 0.9))
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color.white.opacity(0.12)))
            VStack(alignment: .leading, spacing: 2) {
                Text(s.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(Int(round(pct)))% of last 30 days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }
}

#Preview {
    ProgressTabView()
        .environmentObject(GameState())
}
