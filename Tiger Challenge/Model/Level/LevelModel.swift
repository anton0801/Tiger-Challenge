import Foundation

struct LevelModel: Identifiable {
    var id: Int
    var levelType: LevelType
}

enum LevelType: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

var allLevels: [LevelModel] = [
    LevelModel(id: 1, levelType: .easy),
    LevelModel(id: 2, levelType: .easy),
    LevelModel(id: 3, levelType: .easy),
    LevelModel(id: 4, levelType: .medium),
    LevelModel(id: 5, levelType: .medium),
    LevelModel(id: 6, levelType: .medium),
    LevelModel(id: 7, levelType: .medium),
    LevelModel(id: 8, levelType: .medium),
    LevelModel(id: 9, levelType: .medium),
    LevelModel(id: 10, levelType: .hard),
    LevelModel(id: 11, levelType: .hard),
    LevelModel(id: 12, levelType: .hard),
    LevelModel(id: 13, levelType: .hard),
    LevelModel(id: 14, levelType: .hard),
    LevelModel(id: 15, levelType: .hard),
    LevelModel(id: 16, levelType: .hard),
    LevelModel(id: 17, levelType: .hard),
    LevelModel(id: 18, levelType: .hard),
    LevelModel(id: 19, levelType: .hard),
    LevelModel(id: 20, levelType: .hard),
    LevelModel(id: 21, levelType: .hard),
    LevelModel(id: 22, levelType: .hard),
    LevelModel(id: 23, levelType: .hard),
    LevelModel(id: 24, levelType: .hard)
]

func getLevelsByType(_ type: LevelType) -> [LevelModel] {
    return allLevels.filter { $0.levelType == type }
}
