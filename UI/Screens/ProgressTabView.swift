//
//  ProgressTabView.swift
//  Counting Sheep
//

import SwiftUI

// MARK: - Heatmap calendar (month grid, app accent for completed days)

private let appAccent = Color(red: 0.6, green: 0.5, blue: 0.9)
/// High-contrast label for weight/streak text on dark cards (replaces low-contrast purple/secondary).
private let progressLabelColor = Color.white.opacity(0.88)
private let heatmapCompleted = appAccent
private let heatmapEmpty = Color.white.opacity(0.14)
private let heatmapOutside = Color.white.opacity(0.04)

/// Maps growth stage to a tint for the icon circle on the Progress screen,
/// keeping the gamification thread visible in the analytical view.
private func growthTint(for stage: SheepGrowthStage) -> Color {
    switch stage {
    case .needsCare: return Color(red: 0.55, green: 0.45, blue: 0.85).opacity(0.5)
    case .growing:   return Color(red: 0.55, green: 0.45, blue: 0.85).opacity(0.75)
    case .thriving:  return Color(red: 0.55, green: 0.45, blue: 0.85)
    }
}

struct HeatmapCalendarView: View {
    var month: Date
    var completionDates: Set<Date>
    var cellSize: CGFloat = 28

    private let cal = Calendar.current
    private var weekdaySymbols: [String] {
        (0..<7).map { cal.veryShortWeekdaySymbols[(cal.firstWeekday - 1 + $0) % 7] }
    }

    private var monthStart: Date {
        cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month
    }

    private var numberOfDays: Int {
        cal.range(of: .day, in: .month, for: monthStart)?.count ?? 0
    }

    private var firstWeekdayOffset: Int {
        let oneBased = cal.component(.weekday, from: monthStart)
        return (oneBased - cal.firstWeekday + 7) % 7
    }

    /// Linear list: nil = empty cell, 1...N = day of month.
    private var dayCells: [Int?] {
        var out = Array(repeating: Optional<Int>.none, count: firstWeekdayOffset)
        for d in 1...numberOfDays { out.append(d) }
        return out
    }

    private func isCompleted(day: Int) -> Bool {
        guard let date = cal.date(byAdding: .day, value: day - 1, to: monthStart) else { return false }
        let startOfDay = cal.startOfDay(for: date)
        return completionDates.contains(startOfDay)
    }

    private var gridSpacing: CGFloat { 4 }

    var body: some View {
        let columns = Array(repeating: GridItem(.fixed(cellSize), spacing: gridSpacing), count: 7)

        VStack(spacing: 8) {
            // Weekday headers – use the same LazyVGrid so they align exactly with the day cells
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, sym in
                    Text(sym)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.55))
                        .frame(width: cellSize, height: cellSize * 0.7)
                }
            }

            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(Array(dayCells.enumerated()), id: \.offset) { _, cell in
                    if let d = cell {
                        let completed = isCompleted(day: d)
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(completed ? heatmapCompleted : heatmapEmpty)
                                .frame(width: cellSize, height: cellSize)
                            Text("\(d)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(completed ? Color.white : Color.white.opacity(0.7))
                        }
                        .frame(width: cellSize, height: cellSize)
                    } else {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(heatmapOutside)
                            .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
}

struct ProgressTabView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedPage = 0
    @State private var heatmapMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.08).ignoresSafeArea()
                VStack(spacing: 0) {
                    progressSegmentBar
                    TabView(selection: $selectedPage) {
                        weightPage.tag(0)
                        streaksPage.tag(1)
                        last30Page.tag(2)
                        sleepPage.tag(3)
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

    private var progressSegmentBar: some View {
        let labels = ["Growth", "Streaks", "30 days", "Sleep"]
        return HStack(spacing: 0) {
            ForEach(0..<labels.count, id: \.self) { index in
                let isSelected = selectedPage == index
                Button {
                    selectedPage = index
                } label: {
                    Text(labels[index])
                        .font(.subheadline)
                        .fontWeight(isSelected ? .semibold : .medium)
                        .foregroundStyle(isSelected ? Color.black : Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.white : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.12))
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var weightPage: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gameState.habitSheep) { sheep in
                    weightCard(sheep)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    private func weightCard(_ s: HabitSheep) -> some View {
        let (label, value) = weightLabelAndValue(s)
        return HStack(spacing: 16) {
            Image(systemName: s.systemImage)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Circle().fill(growthTint(for: s.growthStage)))
            VStack(alignment: .leading, spacing: 4) {
                Text(s.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(progressLabelColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ProgressView(value: value, total: 1.0)
                .tint(appAccent)
                .frame(width: 80)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func weightLabelAndValue(_ s: HabitSheep) -> (String, Double) {
        switch s.growthStage {
        case .needsCare: return ("\(s.weightKg) KG • Needs care", 0.2)
        case .growing: return ("\(s.weightKg) KG • Growing", 0.5)
        case .thriving: return ("\(s.weightKg) KG • Thriving", 1.0)
        }
    }

    private var streaksPage: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(gameState.habitSheep) { sheep in
                    HStack(spacing: 16) {
                        Image(systemName: sheep.systemImage)
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(growthTint(for: sheep.growthStage)))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(sheep.displayTitle)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\(sheep.consecutiveDaysDone) \(sheep.consecutiveDaysDone == 1 ? "day" : "days") streak")
                                .font(.subheadline)
                                .foregroundStyle(progressLabelColor)
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
            LazyVStack(spacing: 16) {
                monthNavigator
                ForEach(gameState.habitSheep) { sheep in
                    last30HeatmapCard(sheep)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    private var monthNavigator: some View {
        let cal = Calendar.current
        let formatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "MMMM yyyy"
            return f
        }()
        return HStack {
            Button {
                if let prev = cal.date(byAdding: .month, value: -1, to: heatmapMonth) {
                    heatmapMonth = prev
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text(formatter.string(from: heatmapMonth))
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            Button {
                if let next = cal.date(byAdding: .month, value: 1, to: heatmapMonth) {
                    heatmapMonth = next
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, 4)
    }

    private func last30HeatmapCard(_ s: HabitSheep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: s.systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(growthTint(for: s.growthStage)))
                Text(s.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            HeatmapCalendarView(month: heatmapMonth, completionDates: s.completionDateSet, cellSize: 28)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    // MARK: - Sleep page

    /// Sleep stage color palette
    private var deepSleepColor: Color { Color(red: 0.25, green: 0.2, blue: 0.55) }
    private var coreSleepColor: Color { appAccent }
    private var remSleepColor: Color { Color(red: 0.72, green: 0.65, blue: 0.95) }
    private var inBedColor: Color { Color.white.opacity(0.2) }

    private var sleepPage: some View {
        Group {
            if !gameState.healthKitAuthorized {
                sleepNotConnectedView
            } else if gameState.sleepRecords.isEmpty {
                sleepNoDataView
            } else {
                sleepDataView
            }
        }
    }

    private var sleepNotConnectedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 48))
                .foregroundStyle(appAccent)
            Text("Sleep tracking not connected")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Connect Apple Health in Settings to see your sleep data here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var sleepNoDataView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 48))
                .foregroundStyle(appAccent)
            Text("No sleep data yet")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Wear your Apple Watch to bed or use iPhone bedtime tracking. Data will appear here automatically.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var sleepDataView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                lastNightCard
                sevenDayTrendCard
                sleepStageAveragesCard
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    // MARK: Last night card

    private var lastNightRecord: SleepRecord? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Try today first (woke up today), then yesterday
        if let rec = gameState.sleepRecords.first(where: { cal.startOfDay(for: $0.date) == today }) {
            return rec
        }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: today),
           let rec = gameState.sleepRecords.first(where: { cal.startOfDay(for: $0.date) == yesterday }) {
            return rec
        }
        return gameState.sleepRecords.last
    }

    private var lastNightCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Last night")
                .font(.headline)
                .foregroundStyle(.white)

            if let record = lastNightRecord {
                // Big total
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(String(format: "%.1f", record.totalHours))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("hrs asleep")
                        .font(.subheadline)
                        .foregroundStyle(progressLabelColor)
                }

                // Stage bar
                sleepStageBar(record: record)

                // In bed vs asleep
                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("In bed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f hrs", record.inBedHours))
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Efficiency")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.0f%%", record.efficiency * 100))
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    // Goal met?
                    HStack(spacing: 4) {
                        Image(systemName: record.metGoal(gameState.sleepGoalHours) ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(record.metGoal(gameState.sleepGoalHours) ? Color.green : Color.orange)
                        Text(record.metGoal(gameState.sleepGoalHours) ? "Goal met" : "Goal missed")
                            .font(.caption)
                            .foregroundStyle(progressLabelColor)
                    }
                }
            } else {
                Text("No data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func sleepStageBar(record: SleepRecord) -> some View {
        let total = max(record.totalMinutes, 1)
        return VStack(spacing: 6) {
            GeometryReader { geo in
                let w = geo.size.width
                HStack(spacing: 1) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(deepSleepColor)
                        .frame(width: max(2, w * record.deepMinutes / total))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(coreSleepColor)
                        .frame(width: max(2, w * record.coreMinutes / total))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(remSleepColor)
                        .frame(width: max(2, w * record.remMinutes / total))
                }
            }
            .frame(height: 12)

            // Legend
            HStack(spacing: 12) {
                sleepLegendDot(color: deepSleepColor, label: "Deep")
                sleepLegendDot(color: coreSleepColor, label: "Core")
                sleepLegendDot(color: remSleepColor, label: "REM")
                Spacer()
            }
        }
    }

    private func sleepLegendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: 7-day trend card

    private var last7Records: [SleepRecord] {
        let cal = Calendar.current
        guard let weekAgo = cal.date(byAdding: .day, value: -7, to: cal.startOfDay(for: Date())) else { return [] }
        return gameState.sleepRecords.filter { $0.date >= weekAgo }.suffix(7).map { $0 }
    }

    private var sevenDayTrendCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("7-day trend")
                .font(.headline)
                .foregroundStyle(.white)

            let records = last7Records
            if records.isEmpty {
                Text("Not enough data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                let maxHours = max(records.map(\.totalHours).max() ?? 10, gameState.sleepGoalHours + 1)
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(records) { record in
                        VStack(spacing: 4) {
                            Text(String(format: "%.0f", record.totalHours))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(progressLabelColor)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(record.metGoal(gameState.sleepGoalHours) ? appAccent : Color.orange.opacity(0.7))
                                .frame(height: max(8, CGFloat(record.totalHours / maxHours) * 100))

                            Text(dayLabel(for: record.date))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 130)
                .overlay(alignment: .leading) {
                    // Dashed goal line
                    GeometryReader { geo in
                        let y = geo.size.height - CGFloat(gameState.sleepGoalHours / maxHours) * 100 - 18
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geo.size.width, y: y))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(Color.white.opacity(0.3))
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2))
    }

    // MARK: Sleep stage averages card

    private var sleepStageAveragesCard: some View {
        let records = last7Records
        let count = Double(max(records.count, 1))
        let avgDeep = records.map(\.deepMinutes).reduce(0, +) / count
        let avgCore = records.map(\.coreMinutes).reduce(0, +) / count
        let avgREM = records.map(\.remMinutes).reduce(0, +) / count

        return VStack(alignment: .leading, spacing: 14) {
            Text("Average stages (7 days)")
                .font(.headline)
                .foregroundStyle(.white)

            if records.isEmpty {
                Text("Not enough data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                sleepStageRow(label: "Deep", minutes: avgDeep, color: deepSleepColor)
                sleepStageRow(label: "Core", minutes: avgCore, color: coreSleepColor)
                sleepStageRow(label: "REM", minutes: avgREM, color: remSleepColor)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.08)))
    }

    private func sleepStageRow(label: String, minutes: Double, color: Color) -> some View {
        HStack(spacing: 12) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(width: 50, alignment: .leading)
            ProgressView(value: min(minutes, 180), total: 180)
                .tint(color)
            Text(String(format: "%.0fm", minutes))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(progressLabelColor)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

#Preview {
    ProgressTabView()
        .environmentObject(GameState())
}
