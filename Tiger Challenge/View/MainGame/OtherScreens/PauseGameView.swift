import SwiftUI

struct PauseGameView: View {
    
    var fromDaily: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Image("button_bg")
                        .resizable()
                        .frame(width: 170, height: 80)
                    Text("PAUSE")
                        .font(.custom(.tlHeaderFont, size: 42))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                ZStack {
                    Image("settings_bg")
                    Text("GAME\nON\nPAUSE")
                        .multilineTextAlignment(.center)
                        .font(.custom(.tlHeaderFont, size: 32))
                        .foregroundColor(.white)
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
                        NotificationCenter.default.post(name: Notification.Name("CONTINUE_GAME"), object: nil)
                    } label: {
                        Image("next_button")
                            .resizable()
                            .frame(width: 80, height: 50)
                    }
                    .offset(y: -30)
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
    PauseGameView()
}
