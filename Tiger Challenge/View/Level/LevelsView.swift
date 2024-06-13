import SwiftUI

struct LevelsView: View {
    
    @Environment(\.presentationMode) var preMode
    @StateObject var levelViewModel = LevelViewModel()
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Image("button_bg")
                    Text(levelViewModel.levelType.rawValue)
                        .font(.custom(.tlHeaderFont, size: 48))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                LazyVGrid(columns: getColumnsForLevelType()) {
                    ForEach(levelViewModel.levelsDisplay, id: \.id) { level in
                        LevelItemView(levelModel: level)
                            .environmentObject(levelViewModel)
                            .environmentObject(userManager)
                    }
                }
                
                Spacer()
                    
                HStack {
                    Button {
                        withAnimation(.linear(duration: 0.5)) {
                            levelViewModel.prevPage()
                        }
                    } label: {
                        Image("arrow_left")
                    }
                    .offset(y: 10)
                    .opacity(levelViewModel.curPage > 0 ? 1 : 0.6)
                    .disabled(levelViewModel.curPage > 0 ? false : true)
                    
                    Spacer()
                    
                    Button {
                        preMode.wrappedValue.dismiss()
                    } label: {
                        Image("home_btn")
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.linear(duration: 0.5)) {
                            levelViewModel.nextPage()
                        }
                    } label: {
                        Image("arrow_right")
                    }
                    .offset(y: 10)
                    .opacity(levelViewModel.curPage < 3 ? 1 : 0.6)
                    .disabled(levelViewModel.curPage < 3 ? false : true)
                }
            }
            .background(
                Image("levels_bg")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 40)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func getColumnsForLevelType() -> [GridItem] {
        if levelViewModel.levelType == .easy {
            return [GridItem(.fixed(90))]
        } else if levelViewModel.levelType == .medium {
            return [GridItem(.fixed(90)), GridItem(.fixed(90))]
        }
        return [GridItem(.fixed(90)), GridItem(.fixed(90)), GridItem(.fixed(90))]
    }
    
}

struct LevelItemView: View {
    
    var levelModel: LevelModel
    
    @EnvironmentObject var levelViewModel: LevelViewModel
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        if levelViewModel.isLevelAvailable(id: levelModel.id) {
            NavigationLink(destination: MainGameView(levelModel: levelModel)
                .environmentObject(userManager)
                .environmentObject(levelViewModel)
                .navigationBarBackButtonHidden(true)) {
                ZStack {
                    Image("level_bg")
                        .resizable()
                        .frame(width: 90, height: 90)
                    Text("\(levelModel.id)")
                        .font(.custom(.tlHeaderFont, size: 48))
                        .foregroundColor(.white)
                }
                .padding(2)
            }
        } else {
            Image("lock_item")
                .resizable()
                .frame(width: 90, height: 90)
                .padding(2)
        }
    }
    
}

#Preview {
    LevelsView()
        .environmentObject(UserManager())
}
