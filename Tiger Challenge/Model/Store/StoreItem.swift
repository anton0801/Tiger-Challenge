import Foundation

struct StoreItem: Identifiable {
    let id: String
    let storeType: StoreItemType
    let buyed: Bool
    let price: Int
}

enum StoreItemType: String {
    case map = "Map"
    case net = "Net"
    case time = "Time"
}
