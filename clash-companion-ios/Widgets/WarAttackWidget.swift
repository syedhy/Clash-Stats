import WidgetKit
import SwiftUI

struct WarAttackWidgetView: View {
    var entry: ClashWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            
            if let war = entry.warStatus {
                if family == .systemMedium {
                    mediumWarView(war)
                } else {
                    smallWarView(war)
                }
            } else {
                Text("Open app to load").font(.caption).foregroundColor(.secondary)
            }
        }
    }
    
    private func smallWarView(_ war: WarStatus) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "cross.fill")
                .foregroundColor(.orange)
                .padding(.bottom, 2)
            
            Text(war.title)
                .font(.headline)
                .minimumScaleFactor(0.8)
            
            if war.state == "inWar" || war.state == "inCWL" || war.state == "preparation" {
                Text("\(war.attacksLeft ?? 0) attacks left")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let endsAt = war.phaseEndsAt, let date = ISO8601DateFormatter().date(from: endsAt) {
                    Text(date, style: .timer)
                        .font(.caption)
                        .foregroundColor(.red)
                        .bold()
                }
            } else {
                Text(war.state == "notInClan" ? "No Clan" : "Check App")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private func mediumWarView(_ war: WarStatus) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "shield.fill").foregroundColor(.orange)
                    Text(war.title).font(.headline)
                }
                
                if war.state == "inWar" || (war.state == "inCWL" && !war.title.contains("Prep")) {
                    Text("\(war.attacksUsed ?? 0) / \(war.attacksPerMember ?? 0) attacks used")
                        .font(.subheadline)
                    Text("\(war.clanStars ?? 0) ⭐ vs \(war.opponentStars ?? 0) ⭐")
                        .font(.subheadline)
                        .bold()
                    
                    if let endsAt = war.phaseEndsAt, let date = ISO8601DateFormatter().date(from: endsAt) {
                        HStack(spacing: 4) {
                            Text("Ends in:")
                            Text(date, style: .timer).foregroundColor(.red).bold()
                        }.font(.caption)
                    }
                } else {
                    Text(war.state == "preparation" ? "War starts soon" : "No active war")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct WarAttackWidget: Widget {
    let kind: String = "WarAttackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClashTimelineProvider()) { entry in
            WarAttackWidgetView(entry: entry)
                .containerBackground(Color(UIColor.systemGroupedBackground), for: .widget)
        }
        .configurationDisplayName("War Attack Reminder")
        .description("Keep track of your war attacks and remaining time.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
