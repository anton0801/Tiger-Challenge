import Foundation

class MainGameViewModel: ObservableObject {
    
    @Published var mainGameState: MainGameState = .game
    
}

enum MainGameState {
    case game, win, lose, pause
}
