import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var accountStore: AccountStore
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var step = 1
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                if step == 1 {
                    VStack(spacing: 16) {
                        Image(systemName: "shield.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.orange)
                        
                        Text("Clash Companion")
                            .font(.custom("Clash-Regular", size: 34, relativeTo: .largeTitle))
                            .fontWeight(.bold)
                        
                        Text("Cute widgets for wars, heroes, and donations")
                            .font(.custom("Clash-Regular", size: 20, relativeTo: .title3))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("This app uses the official Clash of Clans API.")
                            .font(.custom("Clash-Regular", size: 13, relativeTo: .footnote))
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                } else if step == 2 {
                    VStack(spacing: 16) {
                        Image(systemName: "key.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.orange)
                        
                        Text("Connection Setup")
                            .font(.custom("Clash-Regular", size: 34, relativeTo: .largeTitle))
                            .fontWeight(.bold)
                        
                        Text("To verify your account, you will need your Player Tag and the API Token found in the Clash of Clans Settings.")
                            .font(.custom("Clash-Regular", size: 17, relativeTo: .body))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("The token is only used once for verification.")
                            .font(.custom("Clash-Regular", size: 13, relativeTo: .footnote))
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("Link Village")
                            .font(.custom("Clash-Regular", size: 34, relativeTo: .largeTitle))
                            .fontWeight(.bold)
                        
                        TextField("Player Tag (e.g. #ABC123)", text: $viewModel.playerTag)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                        
                        SecureField("API Token", text: $viewModel.apiToken)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.custom("Clash-Regular", size: 12, relativeTo: .caption))
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                Button(action: {
                    if step < 3 {
                        withAnimation { step += 1 }
                    } else {
                        Task {
                            await viewModel.connect(accountStore: accountStore)
                        }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    } else {
                        Text(step < 3 ? "Next" : "Connect")
                            .font(.custom("Clash-Regular", size: 17, relativeTo: .headline))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView().environmentObject(AccountStore())
    }
}
