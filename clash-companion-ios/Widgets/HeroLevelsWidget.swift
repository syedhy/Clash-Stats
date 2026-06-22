import WidgetKit
import SwiftUI
import AppIntents

struct HeroLevelsWidgetView: View {
    var entry: ClashWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            
            if let heroes = entry.heroes, !heroes.isEmpty {
                if family == .systemLarge {
                    largeHeroView(heroes)
                } else if family == .systemMedium {
                    mediumHeroView(heroes)
                } else {
                    smallHeroView(heroes)
                }
            } else {
                Text("No Heroes").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.secondary)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(intent: RefreshIntent()) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.orange.opacity(0.8))
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }
                Spacer()
                Text("Updated at \(formattedDate)")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    private func smallHeroView(_ heroes: [Hero]) -> some View {
        let maxedTotal = heroes.reduce(0) { $0 + $1.level }
        let maxPossible = heroes.reduce(0) { $0 + $1.maxLevel }
        let progress = maxPossible > 0 ? Int((Double(maxedTotal) / Double(maxPossible)) * 100) : 0
        
        let weakest = heroes.min(by: { $0.progress < $1.progress })
        
        return VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "crown.fill").foregroundColor(.orange)
            Text("Heroes").font(.custom("Clash-Regular", size: 17, relativeTo: .headline))
            
            Text("\(progress)% maxed")
                .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                .bold()
            
            if let w = weakest {
                let shortName = w.name.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined()
                Text("\(shortName) needs \(w.maxLevel - w.level) lvls")
                    .font(.custom("Clash-Regular", size: 11, relativeTo: .caption2))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func mediumHeroView(_ heroes: [Hero]) -> some View {
        HStack {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(heroes.prefix(6), id: \.name) { hero in
                    let shortName = hero.name.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined()
                    VStack(alignment: .leading) {
                        Text("\(shortName) \(hero.level)/\(hero.maxLevel)")
                            .font(.custom("Clash-Regular", size: 11, relativeTo: .caption2))
                            .bold()
                            .lineLimit(1)
                        ProgressView(value: hero.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    private func largeHeroView(_ heroes: [Hero]) -> some View {
        VStack(alignment: .leading) {
            Text("Heroes").font(.custom("Clash-Regular", size: 17, relativeTo: .headline)).foregroundColor(.orange)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(heroes, id: \.name) { hero in
                    let shortName = hero.name.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined()
                    VStack(alignment: .leading) {
                        Text("\(shortName) \(hero.level)/\(hero.maxLevel)")
                            .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                            .bold()
                        ProgressView(value: hero.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct HeroLevelsWidget: Widget {
    let kind: String = "HeroLevelsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClashTimelineProvider()) { entry in
            HeroLevelsWidgetView(entry: entry)
                .environment(\.font, .custom("Clash-Regular", size: 14, relativeTo: .body))
                .containerBackground(Color(UIColor.systemGroupedBackground), for: .widget)
        }
        .configurationDisplayName("Hero Levels")
        .description("Track your overall hero upgrade progress.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
