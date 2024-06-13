import Foundation
import SpriteKit
import SwiftUI

class DailyGameScene: SKScene, SKPhysicsContactDelegate {
    
    enum NetType: String {
        case netEasy = "net_eazy"
        case netHard = "net_hard"
        case netVeryHard = "net_very_hard"
        case netRed = "net_red"
    }
    
    private var pers: SKSpriteNode!
    
    private var pauseButton: SKSpriteNode!
    private var creditsLabel: SKLabelNode!
    
    private var credits: Int = 0 {
        didSet {
            creditsLabel.text = "\(credits)"
            UserDefaults.standard.set(credits, forKey: "credits_user")
        }
    }
    
    private var timeNode: TimeNode!
    
    private var time: Int = 40 {
        didSet {
            timeNode.setTime(time: formatTime(seconds: time))
            if time <= 0 {
                loseGame()
            }
        }
    }
    
    private var allNetsAvailable: [NetType] = [.netRed, .netEasy, .netHard, .netVeryHard]
    private var objectiveNet: NetType
    private var objectiveRedNet = 30
    private var collectedRedNet = 0 {
        didSet {
            if collectedRedNet == objectiveRedNet {
                winGame()
            }
        }
    }
    private var speedNets = 4.0
    
    private var spawnerNetObs: Timer = Timer()
    private var gameTimer: Timer = Timer()
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private var currentGameFon = ""
    
    override init() {
        credits = UserDefaults.standard.integer(forKey: "credits_user")
        currentGameFon = UserDefaults.standard.string(forKey: "current_game_background") ?? "game_base_fon"
        objectiveNet = allNetsAvailable.randomElement() ?? allNetsAvailable[0]
        super.init(size: CGSize(width: 750, height: 1335))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loseGame() {
        isPaused = true
        NotificationCenter.default.post(name: Notification.Name("LOSE_TIGER_GAME"), object: nil)
    }
    
    private func winGame() {
        isPaused = true
        NotificationCenter.default.post(name: Notification.Name("WIN_TIGER_GAME"), object: nil)
    }
    
    private func pauseGameContent() {
        isPaused = true
        NotificationCenter.default.post(name: Notification.Name("PAUSE_GAME_CONTENT"), object: nil)
    }
    
    func continuePlayAction() {
        isPaused = false
    }
    
    override func didMove(to view: SKView) {
        size = CGSize(width: 750, height: 1335)
        physicsWorld.contactDelegate = self
        createFonGame()
        createToolbar()
        createPers()
        createFooter()
        setUpGameData()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        if bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2 {
            let contactBName = bodyB.node?.name
            if let contactBName = contactBName {
                if contactBName == objectiveNet.rawValue {
                    collectedRedNet += 1
                    bodyB.node!.removeFromParent()
                } else if allNetsAvailable.contains(where: { $0.rawValue == contactBName }) {
                    loseGame()
                    bodyB.node!.removeFromParent()
                }
            }
        }
    }
    
    private func setUpGameData() {
        gameTimer = .scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            if !self.isPaused {
                self.time -= 1
            }
        })
        if !allNetsAvailable.isEmpty {
            spawnerNetObs = .scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { _ in
                self.spawnNet()
            })
        }
    }
    
    @objc private func spawnNet() {
        if !isPaused {
            let netSelected = allNetsAvailable.randomElement() ?? allNetsAvailable[0]
            let netObs: SKSpriteNode = .init(imageNamed: netSelected.rawValue)
            let netObsY = CGFloat.random(in: 250...750)
            netObs.position = CGPoint(x: size.width, y: netObsY)
            netObs.physicsBody = SKPhysicsBody(rectangleOf: netObs.size)
            netObs.physicsBody?.isDynamic = true
            netObs.physicsBody?.affectedByGravity = false
            netObs.physicsBody?.categoryBitMask = 2
            netObs.physicsBody?.collisionBitMask = 1
            netObs.physicsBody?.contactTestBitMask = 1
            netObs.name = netSelected.rawValue
            if netSelected == .netVeryHard {
                netObs.size = CGSize(width: netObs.size.width * 1.4, height: netObs.size.height * 1.4)
            }
            addChild(netObs)
            
            switch (netSelected) {
            case .netEasy:
                let moveAction = SKAction.move(to: CGPoint(x: 0, y: netObsY), duration: speedNets)
                netObs.run(moveAction) {
                    let actionFadeOut = SKAction.fadeOut(withDuration: 0.2)
                    netObs.run(actionFadeOut) {
                        netObs.removeFromParent()
                    }
                }
            case .netRed:
                let moveAction = SKAction.move(to: CGPoint(x: 0, y: netObsY), duration: speedNets)
                netObs.run(moveAction) {
                    let actionFadeOut = SKAction.fadeOut(withDuration: 0.2)
                    netObs.run(actionFadeOut) {
                        netObs.removeFromParent()
                    }
                }
            case .netHard:
                let moveFirstAction = SKAction.move(to: CGPoint(x: netObs.position.x - 230, y: netObs.position.y + 40), duration: speed / 4.0)
                let moveSecondAction = SKAction.move(to: CGPoint(x: netObs.position.x - 270, y: netObs.position.y - 80), duration: speed / 4.0)
                let moveThirdAction = SKAction.move(to: CGPoint(x: netObs.position.x - 370, y: netObs.position.y + 60), duration: speed / 4.0)
                let moveFourAction = SKAction.move(to: CGPoint(x: netObs.position.x - 390, y: netObs.position.y - 70), duration: speed / 4.0)
                let moveFiveAction = SKAction.move(to: CGPoint(x: netObs.position.x - 750, y: netObs.position.y + 100), duration: speed / 4.0)
                let actionFadeOut = SKAction.fadeIn(withDuration: 0.2)
                let sequence = SKAction.sequence([moveFirstAction, moveSecondAction, moveThirdAction, moveFourAction, moveFiveAction, actionFadeOut])
                netObs.run(sequence) {
                    netObs.removeFromParent()
                }
            case .netVeryHard:
                let moveFirstAction = SKAction.move(to: CGPoint(x: netObs.position.x - 230, y: netObs.position.y + 40), duration: speed / 5.0)
                let moveSecondAction = SKAction.move(to: CGPoint(x: netObs.position.x - 270, y: netObs.position.y - 80), duration: speed / 5.0)
                let moveThirdAction = SKAction.move(to: CGPoint(x: netObs.position.x - 370, y: netObs.position.y + 60), duration: speed / 5.0)
                let moveFourAction = SKAction.move(to: CGPoint(x: netObs.position.x - 390, y: netObs.position.y - 70), duration: speed / 5.0)
                let moveFiveAction = SKAction.move(to: CGPoint(x: netObs.position.x - 750, y: netObs.position.y + 100), duration: speed / 5.0)
                let actionFadeOut = SKAction.fadeIn(withDuration: 0.2)
                let sequence = SKAction.sequence([moveFirstAction, moveSecondAction, moveThirdAction, moveFourAction, moveFiveAction, actionFadeOut])
                netObs.run(sequence) {
                    netObs.removeFromParent()
                }
            }
        }
    }
    
    private func createFooter() {
        let levelBackround: SKSpriteNode = .init(imageNamed: "button_bg")
        levelBackround.position = CGPoint(x: size.width / 2, y: 100)
        levelBackround.size = CGSize(width: 350, height: 120)
        addChild(levelBackround)
        
        let levelLabel: SKLabelNode = .init(text: "DAILY")
        levelLabel.fontName = .tlHeaderFont
        levelLabel.fontSize = 42
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: size.width / 2, y: 85)
        addChild(levelLabel)
    }
    
    private func createPers() {
        pers = .init(imageNamed: "pers")
        pers.position = CGPoint(x: 150, y: 300)
        pers.size = CGSize(width: 170, height: 220)
        pers.name = "pers"
        pers.physicsBody = SKPhysicsBody(rectangleOf: pers.size)
        pers.physicsBody?.isDynamic = false
        pers.physicsBody?.affectedByGravity = false
        pers.physicsBody?.categoryBitMask = 1
        pers.physicsBody?.collisionBitMask = 2
        pers.physicsBody?.contactTestBitMask = 2
        addChild(pers)
    }
    
    private func createFonGame() {
        let gameFon: SKSpriteNode = .init(imageNamed: currentGameFon)
        gameFon.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameFon.size = size
        addChild(gameFon)
    }
    
    private func createToolbar() {
        let gameToolbar: SKSpriteNode = .init(imageNamed: "game_toolbar")
        gameToolbar.position = CGPoint(x: size.width / 2, y: size.height - 175)
        gameToolbar.size = CGSize(width: size.width, height: 350)
        addChild(gameToolbar)
        
        pauseButton = .init(imageNamed: "pause")
        pauseButton.position = CGPoint(x: 70, y: size.height - 60)
        pauseButton.name = "pause"
        addChild(pauseButton)

        let creditsBack: SKSpriteNode = .init(imageNamed: "credits_back")
        creditsBack.position = CGPoint(x: size.width / 2, y: size.height - 150)
        creditsBack.size = CGSize(width: 170, height: 60)
        addChild(creditsBack)
        
        creditsLabel = .init(text: "\(credits)")
        creditsLabel.fontName = .tlHeaderFont
        creditsLabel.fontSize = 24
        creditsLabel.fontColor = .white
        creditsLabel.position = CGPoint(x: size.width / 2 - 35, y: size.height - 160)
        addChild(creditsLabel)
        
        timeNode = TimeNode(size: CGSize(width: 170, height: 60))
        timeNode.position = CGPoint(x: size.width / 2 - 80, y: size.height - 420)
        
        let objectiveNetBack: SKSpriteNode = .init(imageNamed: "button_bg")
        objectiveNetBack.position = CGPoint(x: size.width / 2, y: size.height - 420)
        objectiveNetBack.size.width = 300
        addChild(objectiveNetBack)
        
        let objectiveNetIcon: SKSpriteNode = .init(imageNamed: objectiveNet.rawValue)
        objectiveNetIcon.position = CGPoint(x: size.width / 2, y: size.height - 420)
        addChild(objectiveNetIcon)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch == nil {
            return
        }
        let location = touch!.location(in: self)
        if location.y <= 850 && location.y >= 150 {
            pers.position.y = location.y
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let nodeObjects = nodes(at: loc)

        if nodeObjects.contains(pauseButton) {
            pauseGameContent()
            return
        }
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: DailyGameScene())
            .ignoresSafeArea()
    }
}
