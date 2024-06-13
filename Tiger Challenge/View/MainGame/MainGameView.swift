import SwiftUI
import SpriteKit

struct MainGameView: View {
    
    var levelModel: LevelModel
    @Environment(\.presentationMode) var presModeDisplay
    @StateObject var mainGameViewModel: MainGameViewModel = MainGameViewModel()
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var levelViewModel: LevelViewModel
    
    @State var mainGameScene: MaingameScene!
    
    var body: some View {
        ZStack {
            if mainGameScene != nil {
                SpriteView(scene: mainGameScene)
                    .ignoresSafeArea()
            }
            if mainGameViewModel.mainGameState == .game {
                
            } else if mainGameViewModel.mainGameState == .win {
                WinGameResultView()
                    .environmentObject(userManager)
            } else if mainGameViewModel.mainGameState == .lose {
                LoseGameResultView()
                    .environmentObject(userManager)
            } else if mainGameViewModel.mainGameState == .pause {
                PauseGameView()
            }
        }
        .onAppear {
            mainGameScene = MaingameScene(levelModel: levelModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PAUSE_GAME_CONTENT"))) { _ in
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .pause
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LOSE_TIGER_GAME"))) { _ in
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .lose
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("WIN_TIGER_GAME"))) { _ in
            userManager.credits += 10
            levelViewModel.unlockLevel(id: self.levelModel.id + 1)
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .win
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("REPLAY_GAME_ACTION"))) { _ in
            mainGameScene = mainGameScene.recreateGameContent()
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .game
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CONTINUE_GAME"))) { _ in
            mainGameScene.continuePlayAction()
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .game
            }
        }
    }
}

#Preview {
    MainGameView(levelModel: LevelModel(id: 2, levelType: .easy))
        .environmentObject(UserManager())
}
