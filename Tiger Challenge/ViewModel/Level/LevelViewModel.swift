import Foundation

class LevelViewModel: ObservableObject {
    
    @Published var levelsDisplay: [LevelModel] = []
    @Published var levelType: LevelType = .easy
    var levelTypes: [LevelType] = [.easy, .medium, .hard]
    @Published var curPage = 0
    
    init() {
        if !isLevelAvailable(id: 1) {
            unlockLevel(id: 1)
        }
        levelsDisplay = getLevelsByType(levelType)
    }
    
    func nextPage() {
        curPage += 1
        levelType = levelTypes[curPage]
        levelsDisplay = getLevelsByType(levelType)
    }
    
    func prevPage() {
        curPage -= 1
        levelType = levelTypes[curPage]
        levelsDisplay = getLevelsByType(levelType)
    }
    
    func isLevelAvailable(id: Int) -> Bool {
        return UserDefaults.standard.bool(forKey: "level_is_available_\(id)")
    }
    
    func unlockLevel(id: Int) {
        UserDefaults.standard.set(true, forKey: "level_is_available_\(id)")
    }
    
}
