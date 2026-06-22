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
                Text("Open app to load").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.secondary)
            }
            
            VStack {
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
    
    private func smallWarView(_ war: WarStatus) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "cross.fill")
                .foregroundColor(.orange)
                .padding(.bottom, 2)
            
            Text(war.title)
                .font(.custom("Clash-Regular", size: 17, relativeTo: .headline))
                .minimumScaleFactor(0.8)
            
            if war.state == "private" {
                Text("Clan log is private")
                    .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                    .foregroundColor(.secondary)
            } else if war.state == "notInWar" {
                Text("Currently not in a war")
                    .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                    .foregroundColor(.secondary)
            } else if war.state == "inWar" || war.state == "inCWL" || war.state == "preparation" {
                if war.isSpectator == true {
                    Text("Spectator")
                        .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                        .foregroundColor(.secondary)
                } else {
                    Text("\(war.attacksLeft ?? 0) attacks left")
                        .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                        .foregroundColor(.secondary)
                }
                
                if let date = war.parsedPhaseEndsAt {
                    Text(date, style: .timer)
                        .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                        .foregroundColor(.red)
                        .bold()
                }
            } else {
                Text(war.state == "notInClan" ? "No Clan" : "Check App")
                    .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
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
                    Text(war.title).font(.custom("Clash-Regular", size: 17, relativeTo: .headline))
                }
                
                if war.state == "private" {
                    Text("Clan log is private")
                        .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                        .foregroundColor(.secondary)
                } else if war.state == "notInWar" {
                    Text("Currently not in a war")
                        .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                        .foregroundColor(.secondary)
                } else if war.state == "inWar" || (war.state == "inCWL" && !war.title.contains("Prep")) {
                    if war.isSpectator == true {
                        Text("You are a spectator")
                            .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(war.attacksUsed ?? 0) / \(war.attacksPerMember ?? 0) attacks used")
                            .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                    }
                    Text("\(war.clanStars ?? 0) ⭐ vs \(war.opponentStars ?? 0) ⭐")
                        .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                        .bold()
                    
                    if let date = war.parsedPhaseEndsAt {
                        HStack(spacing: 4) {
                            Text("Ends in:")
                            Text(date, style: .timer).foregroundColor(.red).bold()
                        }.font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                    }
                } else {
                    Text(war.state == "preparation" ? "War starts soon" : "No active war")
                        .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
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
                .environment(\.font, .custom("Clash-Regular", size: 14, relativeTo: .body))
                .containerBackground(Color(UIColor.systemGroupedBackground), for: .widget)
        }
        .configurationDisplayName("War Attack Reminder")
        .description("Keep track of your war attacks and remaining time.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
