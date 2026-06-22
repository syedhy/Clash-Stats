import WidgetKit
import SwiftUI

struct HeroLevelsWidgetView: View {
    var entry: ClashWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            
            if let heroes = entry.heroes, !heroes.isEmpty {
                if family == .systemMedium {
                    mediumHeroView(heroes)
                } else {
                    smallHeroView(heroes)
                }
            } else {
                Text("No Heroes").font(.caption).foregroundColor(.secondary)
            }
        }
    }
    
    private func smallHeroView(_ heroes: [Hero]) -> some View {
        let maxedTotal = heroes.reduce(0) { $0 + $1.level }
        let maxPossible = heroes.reduce(0) { $0 + $1.maxLevel }
        let progress = maxPossible > 0 ? Int((Double(maxedTotal) / Double(maxPossible)) * 100) : 0
        
        let weakest = heroes.min(by: { $0.progress < $1.progress })
        
        return VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "crown.fill").foregroundColor(.orange)
            Text("Heroes").font(.headline)
            
            Text("\(progress)% maxed")
                .font(.subheadline)
                .bold()
            
            if let w = weakest {
                let shortName = w.name.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined()
                Text("\(shortName) needs \(w.maxLevel - w.level) lvls")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func mediumHeroView(_ heroes: [Hero]) -> some View {
        HStack {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(heroes.prefix(4), id: \.name) { hero in
                    let shortName = hero.name.components(separatedBy: " ").compactMap { $0.first }.map { String($0) }.joined()
                    VStack(alignment: .leading) {
                        Text("\(shortName) \(hero.level) / \(hero.maxLevel)")
                            .font(.caption)
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
                .containerBackground(Color(UIColor.systemGroupedBackground), for: .widget)
        }
        .configurationDisplayName("Hero Levels")
        .description("Track your overall hero upgrade progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
