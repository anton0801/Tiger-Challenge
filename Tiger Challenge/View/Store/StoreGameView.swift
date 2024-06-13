import SwiftUI

struct StoreGameView: View {
    
    @StateObject var storeViewModel: StoreViewModel = StoreViewModel()
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack {
            ZStack {
                Image("game_toolbar")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: 250)
                VStack {
                    HStack {
                        Button {
                            withAnimation(.linear(duration: 0.5)) {
                                storeViewModel.currentStoreItemIndex -= 1
                            }
                        } label: {
                            Image("arrow_left")
                        }
                        .offset(y: 10)
                        .opacity(storeViewModel.currentStoreItemIndex > 0 ? 1 : 0.6)
                        .disabled(storeViewModel.currentStoreItemIndex > 0 ? false : true)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.linear(duration: 0.5)) {
                                storeViewModel.currentStoreItemIndex += 1
                            }
                        } label: {
                            Image("arrow_right")
                        }
                        .offset(y: 10)
                        .opacity(storeViewModel.currentStoreItemIndex < storeViewModel.storeItems.count - 1 ? 1 : 0.6)
                        .disabled(storeViewModel.currentStoreItemIndex < storeViewModel.storeItems.count - 1 ? false : true)
                    }
                    Spacer()
                    ZStack {
                        Image("credits_back")
                        Text("\(userManager.credits)")
                            .font(.custom(.tlHeaderFont, size: 28))
                            .foregroundColor(.white)
                            .padding(.trailing, 40)
                    }
                    .offset(y: -50)
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width, height: 250)
            }
            .edgesIgnoringSafeArea(.top)
    
            ZStack {
                Image("credits_back")
                Text("\(storeViewModel.currentStoreItem.price)")
                    .font(.custom(.tlHeaderFont, size: 28))
                    .foregroundColor(.white)
                    .padding(.trailing, 40)
            }
            .offset(y: -60)
            
            Spacer()
            
            if storeViewModel.currentStoreItem.storeType == .time ||
                storeViewModel.currentStoreItem.storeType == .net {
                Image(storeViewModel.currentStoreItem.id)
            }
            
            if !storeViewModel.currentStoreItem.buyed {
                Button {
                    storeViewModel.buyItem(userManager: userManager)
                } label: {
                    Image("store_button")
                }
                .offset(y: 100)
            } else {
                Button {
                    UserDefaults.standard.set(storeViewModel.currentStoreItem.id, forKey: "current_game_background")
                } label: {
                    Image("select_button")
                }
                .offset(y: 100)
            }
            
            Spacer()
            Spacer()
            
            if storeViewModel.errorBuy {
                Text("You don't have enought credits")
                    .font(.custom(.tlHeaderFont, size: 32))
                    .foregroundColor(.white)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.linear(duration: 0.5)) {
                                storeViewModel.errorBuy = false
                            }
                        }
                    }
                    .offset(y: 50)
            }
            
            ZStack {
                Image("button_bg")
                    .resizable()
                    .frame(width: 160, height: 80)
                Text(storeViewModel.currentStoreItem.storeType.rawValue)
                    .font(.custom(.tlHeaderFont, size: 42))
                    .foregroundColor(.white)
            }
            .offset(y: 40)
        }
        .background(
            Image(storeViewModel.currentBackground)
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 40)
        )
    }
}

#Preview {
    StoreGameView()
        .environmentObject(UserManager())
}
