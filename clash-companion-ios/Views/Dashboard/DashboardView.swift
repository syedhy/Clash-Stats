import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var accountStore: AccountStore
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let summary = viewModel.summary {
                        villageCard(summary: summary)
                    } else if viewModel.isLoading {
                        ProgressView().padding()
                    }
                    
                    if let war = viewModel.warStatus {
                        warCard(war: war)
                    }
                    
                    if let heroes = viewModel.heroes {
                        heroesCard(heroes: heroes)
                    }
                    
                    if let donations = viewModel.donations {
                        donationCard(donations: donations)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarItems(trailing: Button("Log Out") {
                accountStore.logout()
            })
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .refreshable {
                if let tag = accountStore.playerTag {
                    await viewModel.fetchData(for: tag)
                }
            }
            .onAppear {
                if let tag = accountStore.playerTag, viewModel.summary == nil {
                    Task {
                        await viewModel.fetchData(for: tag)
                    }
                }
            }
        }
    }
    
    private func villageCard(summary: PlayerSummary) -> some View {
        CardView(title: "Connected Village", icon: "house.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text(summary.name).font(.title2).bold()
                Text(summary.tag).font(.caption).foregroundColor(.gray)
                HStack {
                    Text("Town Hall \(summary.townHallLevel)")
                    Spacer()
                    Text("🏆 \(summary.trophies ?? 0)")
                }
                if let clanName = summary.clanName {
                    Text("Clan: \(clanName)").font(.subheadline).foregroundColor(.secondary)
                } else {
                    Text("No Clan").font(.subheadline).foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func warCard(war: WarStatus) -> some View {
        CardView(title: "War Status", icon: "shield.fill") {
            VStack(alignment: .leading, spacing: 8) {
                if war.state == "notInClan" {
                    Text("Join a clan to use war widgets.")
                        .foregroundColor(.secondary)
                } else if war.state == "privateWarLog" {
                    Text("Your clan's war log is private.")
                        .foregroundColor(.secondary)
                } else if war.state == "notInWar" {
                    Text("Your clan is not in war.")
                        .foregroundColor(.secondary)
                } else {
                    Text(war.title).font(.headline).foregroundColor(.orange)
                    Text("\(war.clanName ?? "") vs \(war.opponentName ?? "")")
                    HStack {
                        Text("Attacks Left: \(war.attacksLeft ?? 0)")
                        Spacer()
                        Text("⭐ \(war.clanStars ?? 0) - \(war.opponentStars ?? 0) ⭐")
                    }
                    if let phaseEndsAt = war.phaseEndsAt, let date = ISO8601DateFormatter().date(from: phaseEndsAt) {
                        Text("Ends: \(date, style: .timer)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func heroesCard(heroes: [Hero]) -> some View {
        CardView(title: "Hero Levels", icon: "crown.fill") {
            if heroes.isEmpty {
                Text("No heroes available.").foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(heroes.prefix(4), id: \.name) { hero in
                        VStack(alignment: .leading) {
                            Text(hero.name).font(.caption).bold().lineLimit(1)
                            Text("Lvl \(hero.level)/\(hero.maxLevel)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            ProgressView(value: hero.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                        }
                    }
                }
            }
        }
    }
    
    private func donationCard(donations: DonationStats) -> some View {
        CardView(title: "Troop Karma", icon: "gift.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text(donations.mood).font(.headline).foregroundColor(.green)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Donated").font(.caption).foregroundColor(.gray)
                        Text("\(donations.donations)").bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Received").font(.caption).foregroundColor(.gray)
                        Text("\(donations.donationsReceived)").bold()
                    }
                }
                Text("Balance: \(donations.balance > 0 ? "+" : "")\(donations.balance)")
                    .font(.caption)
                    .foregroundColor(donations.balance >= 0 ? .green : .red)
            }
        }
    }
}
