import SwiftUI

struct WinGameResultView: View {
    
    var fromDaily: Bool = false
    @EnvironmentObject var userManager: UserManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Image("button_bg")
                        .resizable()
                        .frame(width: 140, height: 80)
                    Text("WIN")
                        .font(.custom(.tlHeaderFont, size: 42))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Image("settings_bg")
                    if !fromDaily {
                        Text("YOU GOT\n10 COINS")
                            .multilineTextAlignment(.center)
                            .font(.custom(.tlHeaderFont, size: 32))
                            .foregroundColor(.white)
                    } else {
                        Text("YOU GOT\n30 COINS")
                            .multilineTextAlignment(.center)
                            .font(.custom(.tlHeaderFont, size: 32))
                            .foregroundColor(.white)
                    }
                }
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("home_btn")
                        .resizable()
                        .frame(width: 80, height: 50)
                }
                .offset(y: -30)
                
                Spacer()
                
                HStack {
                    NavigationLink(destination: StoreGameView()
                        .environmentObject(userManager)
                        .navigationBarBackButtonHidden(true)) {
                            Image("store_button")
                                .resizable()
                                .frame(width: 80, height: 50)
                        }
                    Spacer()
                    NavigationLink(destination: SettingsView()
                        .navigationBarBackButtonHidden(true)) {
                            Image("settings_button_2")
                                .resizable()
                                .frame(width: 85, height: 55)
                        }
                }
            }
            .background(
                Image("game_result_background")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 40)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    WinGameResultView()
        .environmentObject(UserManager())
}
