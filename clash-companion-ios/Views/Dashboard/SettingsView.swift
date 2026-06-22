import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accountStore: AccountStore
    
    @State private var showingAddAccount = false
    @State private var backendURL: String = WidgetDataStore.shared.backendURL ?? "http://192.168.1.17:3000/api"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Accounts"), footer: Text("Swipe left to delete a saved account.")) {
                    ForEach(accountStore.savedAccounts) { account in
                        Button(action: {
                            accountStore.switchAccount(to: account.tag)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(account.displayName)
                                        .font(.custom("Clash-Regular", size: 17))
                                        .foregroundColor(.primary)
                                    Text(account.tag)
                                        .font(.custom("Clash-Regular", size: 12))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if accountStore.activeAccount?.tag == account.tag {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteAccount)
                    
                    Button(action: {
                        showingAddAccount = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.orange)
                            Text("Add Another Account")
                                .font(.custom("Clash-Regular", size: 17))
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section(header: Text("Network Settings"), footer: Text("The IP address of the Mac running the Node.js backend. Keep the /api suffix.")) {
                    TextField("Backend URL", text: $backendURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Button("Save Network Changes") {
                    WidgetDataStore.shared.backendURL = backendURL
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingAddAccount) {
                OnboardingView()
                    .environmentObject(accountStore)
            }
        }
    }
    
    private func deleteAccount(at offsets: IndexSet) {
        for index in offsets {
            let account = accountStore.savedAccounts[index]
            accountStore.deleteAccount(tag: account.tag)
        }
    }
}
