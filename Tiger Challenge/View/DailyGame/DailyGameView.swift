import SwiftUI
import SpriteKit

struct DailyGameView: View {
    
    @Environment(\.presentationMode) var presModeDisplay
    @StateObject var mainGameViewModel: MainGameViewModel = MainGameViewModel()
    @EnvironmentObject var userManager: UserManager
    
    @State var dailyGameScene: DailyGameScene!
    
    var body: some View {
        ZStack {
            if dailyGameScene != nil {
                SpriteView(scene: dailyGameScene)
                    .ignoresSafeArea()
            }
            if mainGameViewModel.mainGameState == .game {
                
            } else if mainGameViewModel.mainGameState == .win {
                WinGameResultView(fromDaily: true)
                    .environmentObject(userManager)
            } else if mainGameViewModel.mainGameState == .lose {
                LoseGameResultView(fromDaily: true)
                    .environmentObject(userManager)
            } else if mainGameViewModel.mainGameState == .pause {
                PauseGameView(fromDaily: true)
            }
        }
        .onAppear {
            dailyGameScene = DailyGameScene()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LOSE_TIGER_GAME"))) { _ in
            UserDefaults.standard.set(Date(), forKey: "lastFunctionExecutionDate")
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .lose
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("WIN_TIGER_GAME"))) { _ in
            UserDefaults.standard.set(Date(), forKey: "lastFunctionExecutionDate")
            userManager.credits += 30
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .win
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("CONTINUE_GAME"))) { _ in
            dailyGameScene.continuePlayAction()
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .game
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PAUSE_GAME_CONTENT"))) { _ in
            withAnimation(.linear(duration: 0.5)) {
                mainGameViewModel.mainGameState = .pause
            }
        }
    }
}

#Preview {
    DailyGameView()
        .environmentObject(UserManager())
}
