import SwiftUI

struct LoseGameResultView: View {
    
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
                    Text("LOSE")
                        .font(.custom(.tlHeaderFont, size: 42))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Image("settings_bg")
                    if !fromDaily {
                        Text("TRY\nAGAIN")
                            .multilineTextAlignment(.center)
                            .font(.custom(.tlHeaderFont, size: 32))
                            .foregroundColor(.white)
                    } else {
                        Text("TRY AGAIN\nIN 24 HOURS")
                            .multilineTextAlignment(.center)
                            .font(.custom(.tlHeaderFont, size: 32))
                            .foregroundColor(.white)
                    }
                }
                HStack {
                    if !fromDaily {
                        Button {
                            NotificationCenter.default.post(name: Notification.Name("REPLAY_GAME_ACTION"), object: nil)
                        } label: {
                            Image("replay_game")
                                .resizable()
                                .frame(width: 80, height: 50)
                        }
                        .offset(y: -30)
                    }
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image("home_btn")
                            .resizable()
                            .frame(width: 80, height: 50)
                    }
                    .offset(y: -30)
                }
                
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
    LoseGameResultView()
        .environmentObject(UserManager())
}
