import SwiftUI

struct MenuView: View {

    @StateObject var menuViewModel: MenuViewModel = MenuViewModel()
    
    @State var goToNeededPage = false
    @StateObject var userManager = UserManager()
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        menuViewModel.onEvent(menuEvent: .info)
                    } label: {
                        Image("info_game_button")
                            .resizable()
                            .frame(width: 80, height: 50)
                    }
                    Button {
                        menuViewModel.onEvent(menuEvent: .store)
                    } label: {
                        Image("store_button")
                            .resizable()
                            .frame(width: 80, height: 50)
                    }
                }
                Button {
                    menuViewModel.onEvent(menuEvent: .play)
                } label: {
                    Image("play_button")
                        .resizable()
                        .frame(width: 180, height: 90)
                }
                .padding(.top)
                
                Spacer()
                
                Button {
                    menuViewModel.onEvent(menuEvent: .settings)
                } label: {
                    Image("settings_button")
                        .resizable()
                        .frame(width: 220, height: 100)
                }
                
                Spacer()
                
                if menuViewModel.timeRemaining == "Function is available" {
                    Button {
                        menuViewModel.onEvent(menuEvent: .daily)
                    } label: {
                        Image("daily_button")
                            .resizable()
                            .frame(width: 180, height: 90)
                    }
                    .padding(.bottom)
                } else {
                    ZStack {
                        Image("button_bg")
                            .resizable()
                            .frame(width: 220, height: 90)
                        Text(menuViewModel.timeRemaining)
                            .font(.custom(.tlHeaderFont, size: 42))
                            .foregroundColor(.white)
                    }
                }
                
                if menuViewModel.menuEvent == .play {
                    NavigationLink(destination: LevelsView()
                        .environmentObject(userManager)
                        .navigationBarBackButtonHidden(true), isActive: $goToNeededPage) {
                        EmptyView()
                    }
                } else if menuViewModel.menuEvent == .settings {
                    NavigationLink(destination: SettingsView()
                        .navigationBarBackButtonHidden(true), isActive: $goToNeededPage) {
                        EmptyView()
                    }
                } else if menuViewModel.menuEvent == .daily {
                    NavigationLink(destination: DailyGameView()
                        .environmentObject(userManager)
                        .navigationBarBackButtonHidden(true), isActive: $goToNeededPage) {
                        EmptyView()
                    }
                } else if menuViewModel.menuEvent == .store {
                    NavigationLink(destination: StoreGameView()
                        .environmentObject(userManager)
                        .navigationBarBackButtonHidden(true), isActive: $goToNeededPage) {
                        EmptyView()
                    }
                } else if menuViewModel.menuEvent == .info {
                    NavigationLink(destination: InfoGameRulesView()
                        .navigationBarBackButtonHidden(true), isActive: $goToNeededPage) {
                        EmptyView()
                    }
                } else if menuViewModel.menuEvent == .menu {
                    
                }
            }
            .onChange(of: menuViewModel.menuEvent) { _ in
                goToNeededPage = true
            }
            .background(
                Image("background")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 40)
            )
            .onAppear {
                menuViewModel.menuEvent = .menu
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    MenuView()
}
