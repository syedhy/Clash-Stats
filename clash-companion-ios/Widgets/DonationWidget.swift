import WidgetKit
import SwiftUI

struct DonationWidgetView: View {
    var entry: ClashWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
            
            if let donations = entry.donations {
                if family == .systemMedium {
                    mediumDonationView(donations)
                } else {
                    smallDonationView(donations)
                }
            } else {
                Text("No Data").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.secondary)
            }
        }
    }
    
    private func smallDonationView(_ donations: DonationStats) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: "gift.fill").foregroundColor(.green)
            Text("Troop Karma").font(.custom("Clash-Regular", size: 17, relativeTo: .headline)).minimumScaleFactor(0.8)
            
            Text("\(donations.donations) given")
                .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
            
            let prefix = donations.balance > 0 ? "+" : ""
            Text("\(prefix)\(donations.balance) balance")
                .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                .foregroundColor(donations.balance >= 0 ? .green : .red)
        }
        .padding()
    }
    
    private func mediumDonationView(_ donations: DonationStats) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "gift.fill").foregroundColor(.green)
                    Text("Troop Karma").font(.custom("Clash-Regular", size: 17, relativeTo: .headline))
                }
                
                Text(donations.mood)
                    .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                    .foregroundColor(.green)
                    .bold()
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Donated").font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(.secondary)
                        Text("\(donations.donations)").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).bold()
                    }
                    VStack(alignment: .leading) {
                        Text("Received").font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(.secondary)
                        Text("\(donations.donationsReceived)").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).bold()
                    }
                    VStack(alignment: .leading) {
                        Text("Ratio").font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(.secondary)
                        Text(String(format: "%.2f", donations.ratio)).font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).bold()
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct DonationWidget: Widget {
    let kind: String = "DonationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClashTimelineProvider()) { entry in
            DonationWidgetView(entry: entry)
                .environment(\.font, .custom("Clash-Regular", size: 14, relativeTo: .body))
                .containerBackground(Color(UIColor.systemGroupedBackground), for: .widget)
        }
        .configurationDisplayName("Donation Tracker")
        .description("Track your troop donations and balance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
