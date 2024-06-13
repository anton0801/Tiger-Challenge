import Foundation

class StoreViewModel: ObservableObject {
    
    var storeItems = [
        StoreItem(id: "add_time_count", storeType: .time, buyed: false, price: 20),
        StoreItem(id: "posibility_for_error_count", storeType: .net, buyed: false, price: 20),
        StoreItem(id: "game_fon_1", storeType: .map, buyed: UserDefaults.standard.bool(forKey: "game_fon_1_bought"), price: 25),
        StoreItem(id: "game_fon_2", storeType: .map, buyed: UserDefaults.standard.bool(forKey: "game_fon_2_bought"), price: 25),
        StoreItem(id: "game_fon_3", storeType: .map, buyed: UserDefaults.standard.bool(forKey: "game_fon_3_bought"), price: 25),
        StoreItem(id: "game_fon_4", storeType: .map, buyed: UserDefaults.standard.bool(forKey: "game_fon_4_bought"), price: 25)
    ]
    
    @Published var currentStoreItem: StoreItem
    @Published var currentStoreItemIndex: Int = 0 {
        didSet {
            currentStoreItem = storeItems[currentStoreItemIndex]
            if currentStoreItem.storeType == .map {
                currentBackground = currentStoreItem.id
            } else {
                currentBackground = UserDefaults.standard.string(forKey: "current_game_background") ?? "game_base_fon"
            }
        }
    }
    @Published var errorBuy: Bool = false
    @Published var currentBackground = UserDefaults.standard.string(forKey: "current_game_background") ?? "game_base_fon"
    
    init() {
        currentStoreItem = storeItems[0]
    }
    
    func buyItem(userManager: UserManager) {
        if userManager.credits >= currentStoreItem.price {
            if currentStoreItem.storeType == .map {
                currentStoreItem = StoreItem(id: currentStoreItem.id, storeType: currentStoreItem.storeType, buyed: true, price: currentStoreItem.price)
                storeItems[currentStoreItemIndex] = currentStoreItem
                UserDefaults.standard.set(true, forKey: "\(currentStoreItem.id)_bought")
            } else {
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: currentStoreItem.id) + 1, forKey: currentStoreItem.id)
            }
            userManager.credits -= currentStoreItem.price
            errorBuy = false
        } else {
            errorBuy = true
        }
    }
    
}
