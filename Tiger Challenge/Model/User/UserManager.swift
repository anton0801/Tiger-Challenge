import Foundation


class UserManager: ObservableObject {
    
    @Published var credits: Int = 0 {
        didSet {
            UserDefaults.standard.set(credits, forKey: "credits_user")
        }
    }
    
    init() {
        credits = UserDefaults.standard.integer(forKey: "credits_user")
    }
    
}
