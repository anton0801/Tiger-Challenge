import Foundation

class SettingsViewModel: ObservableObject {
    
    @Published var musicOn: Bool = false {
        didSet {
            UserDefaults.standard.set(musicOn, forKey: "music_app")
        }
    }
    
    @Published var soundsOn: Bool = false {
        didSet {
            UserDefaults.standard.set(soundsOn, forKey: "sounds_app")
        }
    }
    
    init() {
        musicOn = UserDefaults.standard.bool(forKey: "music_app")
        soundsOn = UserDefaults.standard.bool(forKey: "sounds_app")
    }
    
}
