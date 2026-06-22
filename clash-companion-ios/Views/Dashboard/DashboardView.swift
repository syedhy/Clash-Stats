import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var accountStore: AccountStore
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.showLoader && viewModel.summary == nil {
                    VStack(spacing: 24) {
                        Image("ArcherQueenLoader")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 250, height: 250)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                            .scaleEffect(1.8)
                            .padding(.bottom, 8)
                        
                        Text("The Queen is searching...")
                            .font(.custom("Clash-Regular", size: 22))
                            .foregroundColor(.primary)
                        
                        Text("Hold your crossbow, this will just take a moment.")
                            .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage, viewModel.summary == nil {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text("Failed to load dashboard")
                            .font(.custom("Clash-Regular", size: 20, relativeTo: .title3))
                            .fontWeight(.bold)
                        Text(error)
                            .font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Try Again") {
                            if let tag = accountStore.playerTag {
                                Task { await viewModel.fetchData(for: tag) }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            if viewModel.isOfflineMode {
                                HStack {
                                    Image(systemName: "wifi.slash")
                                    Text("Server unreachable. Showing last known data.")
                                        .font(.custom("Clash-Regular", size: 14, relativeTo: .footnote))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            if let summary = viewModel.summary {
                                villageCard(summary: summary)
                                if let completion = viewModel.completionProgress {
                                    CompletionProgressCard(progress: completion)
                                }
                                seasonStatsCard(summary: summary)
                                builderBaseCard(summary: summary)
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
                            
                            if let lab = viewModel.laboratory {
                                if !lab.troops.isEmpty || !lab.spells.isEmpty {
                                    laboratoryCard(lab: lab)
                                }
                                if !lab.pets.isEmpty {
                                    petsCard(pets: lab.pets)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarItems(
                leading: Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.primary)
                },
                trailing: Button("Log Out") {
                    accountStore.logout()
                }
            )
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .refreshable {
                if let tag = accountStore.playerTag {
                    await viewModel.fetchData(for: tag)
                }
            }
            .onAppear {
                for family in UIFont.familyNames {
                    print("\(family)")
                    for name in UIFont.fontNames(forFamilyName: family) {
                        print("   \(name)")
                    }
                }
                if let customFont = UIFont(name: "Clash-Regular", size: 24) {
                    UINavigationBar.appearance().largeTitleTextAttributes = [.font: customFont]
                    UINavigationBar.appearance().titleTextAttributes = [.font: customFont]
                }
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
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(summary.name).font(.custom("Clash-Regular", size: 22, relativeTo: .title2)).bold()
                        Text(summary.tag).font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.gray)
                    }
                    Spacer()
                    if let leagueUrl = summary.leagueIconUrl, let url = URL(string: leagueUrl) {
                        VStack {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable().scaledToFit()
                                } else if phase.error != nil {
                                    Image(systemName: "photo").foregroundColor(.secondary)
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(width: 40, height: 40)
                            
                            if let leagueName = summary.leagueName {
                                Text(leagueName).font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                HStack {
                    Text("Town Hall \(summary.townHallLevel)")
                    Spacer()
                    Text("🏆 \(summary.trophies ?? 0)")
                }
                if let clanName = summary.clanName {
                    Text("Clan: \(clanName)").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).foregroundColor(.secondary)
                } else {
                    Text("No Clan").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func seasonStatsCard(summary: PlayerSummary) -> some View {
        CardView(title: "Season Stats", icon: "sword") {
            HStack {
                VStack {
                    Text("⚔️ \(summary.attackWins ?? 0)")
                        .font(.custom("Clash-Regular", size: 20, relativeTo: .title3)).bold()
                    Text("Attack Wins").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text("🛡️ \(summary.defenseWins ?? 0)")
                        .font(.custom("Clash-Regular", size: 20, relativeTo: .title3)).bold()
                    Text("Defense Wins").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func builderBaseCard(summary: PlayerSummary) -> some View {
        CardView(title: "Builder Base", icon: "hammer.fill") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Builder Hall \(summary.builderHallLevel ?? 0)")
                    Spacer()
                    Text("🏆 \(summary.builderBaseTrophies ?? 0)")
                }
                if let best = summary.bestBuilderBaseTrophies {
                    Text("Best: \(best)").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func warCard(war: WarStatus) -> some View {
        CardView(title: "War Performance", icon: "shield.fill") {
            VStack(alignment: .leading, spacing: 12) {
                if war.state == "notInClan" || war.state == "notInWar" {
                    Text(war.state == "notInClan" ? "Join a clan to use war widgets." : "Your clan is not in war.")
                        .foregroundColor(.secondary)
                } else if war.state == "privateWarLog" {
                    Text("Your clan's war log is private.")
                        .foregroundColor(.secondary)
                } else {
                    Text(war.title).font(.custom("Clash-Regular", size: 17, relativeTo: .headline)).foregroundColor(war.state == "inCWL" ? .purple : .orange)
                    Text("\(war.clanName ?? "Clan") vs \(war.opponentName ?? "Opponent")")
                    
                    if !war.title.contains("Prep") {
                        // Clan Score
                        HStack {
                            Text("Clan Score")
                            Spacer()
                            Text("⭐ \(war.clanStars ?? 0) - \(war.opponentStars ?? 0) ⭐").bold()
                        }
                        
                        Divider()
                        
                        // Personal Performance
                        if war.isSpectator == true {
                            Text("Spectator").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).bold().foregroundColor(.gray)
                            Text("You are not on the roster for this war.")
                                .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Your Contribution").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).bold().foregroundColor(.cyan)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Attacks: \(war.attacksUsed ?? 0)/\(war.attacksPerMember ?? 0)")
                                        .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("⭐ \(war.playerStars ?? 0)").bold()
                                    Text(String(format: "%.1f%% Dest", war.playerDestruction ?? 0))
                                        .font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.secondary)
                                }
                            }
                        }
                    } else {
                        Text("War starts soon!")
                            .foregroundColor(.secondary)
                    }
                    
                    if let date = war.parsedPhaseEndsAt {
                        Text("Ends: \(date, style: .timer)")
                            .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
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
                    ForEach(heroes, id: \.name) { hero in
                        VStack(alignment: .leading) {
                            if let urlStr = hero.iconUrl, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFit()
                                    } else if phase.error != nil {
                                        Image(systemName: "photo").foregroundColor(.secondary)
                                    } else {
                                        ProgressView()
                                    }
                                }
                                .frame(width: 40, height: 40)
                            }
                            Text(hero.name).font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).bold().lineLimit(1)
                            Text("Lvl \(hero.level)/\(hero.maxLevel)")
                                .font(.custom("Clash-Regular", size: 11, relativeTo: .caption2))
                                .foregroundColor(.secondary)
                            ProgressView(value: hero.progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                            
                            if let equipment = hero.equipment, !equipment.isEmpty {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(equipment, id: \.name) { eq in
                                        Text("• \(eq.name) (\(eq.level))")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func donationCard(donations: DonationStats) -> some View {
        CardView(title: "Troop Karma", icon: "gift.fill") {
            VStack(alignment: .leading, spacing: 8) {
                Text(donations.mood).font(.custom("Clash-Regular", size: 17, relativeTo: .headline)).foregroundColor(.green)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Donated").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.gray)
                        Text("\(donations.donations)").bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Received").font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).foregroundColor(.gray)
                        Text("\(donations.donationsReceived)").bold()
                    }
                }
                Text("Balance: \(donations.balance > 0 ? "+" : "")\(donations.balance)")
                    .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                    .foregroundColor(donations.balance >= 0 ? .green : .red)
            }
        }
    }
    
    private func laboratoryCard(lab: LaboratoryData) -> some View {
        CardView(title: "Laboratory", icon: "flask.fill") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Troops").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).bold()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(lab.troops, id: \.name) { troop in
                            VStack {
                                if let urlStr = troop.iconUrl, let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image { image.resizable().scaledToFit() }
                                        else if phase.error != nil { Image(systemName: "photo").foregroundColor(.secondary) }
                                        else { ProgressView() }
                                    }
                                        .frame(width: 30, height: 30)
                                }
                                Text(troop.name).font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).lineLimit(1).frame(width: 60)
                                Text("Lvl \(troop.level)").font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(troop.level == troop.maxLevel ? .orange : .secondary)
                            }
                        }
                    }
                }
                
                Text("Spells").font(.custom("Clash-Regular", size: 15, relativeTo: .subheadline)).bold().padding(.top, 5)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(lab.spells, id: \.name) { spell in
                            VStack {
                                if let urlStr = spell.iconUrl, let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image { image.resizable().scaledToFit() }
                                        else if phase.error != nil { Image(systemName: "photo").foregroundColor(.secondary) }
                                        else { ProgressView() }
                                    }
                                        .frame(width: 30, height: 30)
                                }
                                Text(spell.name).font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).lineLimit(1).frame(width: 60)
                                Text("Lvl \(spell.level)").font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(spell.level == spell.maxLevel ? .cyan : .secondary)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func petsCard(pets: [Troop]) -> some View {
        CardView(title: "Pet House", icon: "pawprint.fill") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(pets, id: \.name) { pet in
                        VStack {
                            if let urlStr = pet.iconUrl, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image { image.resizable().scaledToFit() }
                                    else if phase.error != nil { Image(systemName: "photo").foregroundColor(.secondary) }
                                    else { ProgressView() }
                                }
                                    .frame(width: 30, height: 30)
                            }
                            Text(pet.name).font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).lineLimit(1).frame(width: 60)
                            Text("Lvl \(pet.level)").font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(pet.level == pet.maxLevel ? .purple : .secondary)
                        }
                    }
                }
            }
        }
    }
}

struct PetHouseCard: View {
    let pets: [Troop]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pet House").font(.custom("Clash-Regular", size: 17, relativeTo: .headline))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(pets, id: \.name) { pet in
                        VStack {
                            Text(pet.name).font(.custom("Clash-Regular", size: 12, relativeTo: .caption)).lineLimit(1).frame(width: 70)
                            Text("Lvl \(pet.level)").font(.custom("Clash-Regular", size: 11, relativeTo: .caption2)).foregroundColor(pet.level == pet.maxLevel ? .purple : .secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct CompletionProgressCard: View {
    let progress: CompletionProgress
    
    var body: some View {
        HStack(spacing: 20) {
            CircularProgressRing(percentage: progress.heroes, label: "Heroes", color: .orange)
            CircularProgressRing(percentage: progress.laboratory, label: "Laboratory", color: .purple)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

struct CircularProgressRing: View {
    let percentage: Double
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 6)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(percentage / 100.0))
                    .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: percentage)
                
                Text(String(format: "%.0f%%", percentage))
                    .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                    .bold()
            }
            .frame(width: 50, height: 50)
            
            Text(label)
                .font(.custom("Clash-Regular", size: 11, relativeTo: .caption2))
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var backendURL: String = WidgetDataStore.shared.backendURL ?? "http://192.168.1.17:3000/api"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Network Settings"), footer: Text("The IP address of the Mac running the Node.js backend. Keep the /api suffix.")) {
                    TextField("Backend URL", text: $backendURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Button("Save") {
                    WidgetDataStore.shared.backendURL = backendURL
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
