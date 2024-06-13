import Foundation

class MenuViewModel: ObservableObject {
    
    @Published var menuEvent: MenuEvent? = nil
    
    func onEvent(menuEvent: MenuEvent?) {
        self.menuEvent = menuEvent
    }
    
    @Published var timeRemaining: String = ""
    private var timer: Timer?
    private let functionInterval: TimeInterval = 24 * 60 * 60
    
    init() {
        checkFunctionAvailability()
    }
    
    func executeFunction() {
        if isFunctionAvailable() {
            UserDefaults.standard.set(Date(), forKey: "lastFunctionExecutionDate")
            checkFunctionAvailability()
        }
    }
    
    private func isFunctionAvailable() -> Bool {
        guard let lastExecutionDate = UserDefaults.standard.object(forKey: "lastFunctionExecutionDate") as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastExecutionDate) >= functionInterval
    }
    
    private func checkFunctionAvailability() {
        if isFunctionAvailable() {
            timeRemaining = "Function is available"
            timer?.invalidate()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        guard let lastExecutionDate = UserDefaults.standard.object(forKey: "lastFunctionExecutionDate") as? Date else {
            timeRemaining = "Function is available"
            timer?.invalidate()
            return
        }
        
        let timeInterval = Date().timeIntervalSince(lastExecutionDate)
        if timeInterval >= functionInterval {
            timeRemaining = "Function is available"
            timer?.invalidate()
        } else {
            let remainingTime = functionInterval - timeInterval
            let hours = Int(remainingTime) / 3600
            let minutes = (Int(remainingTime) % 3600) / 60
            let seconds = Int(remainingTime) % 60
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }
    
}
