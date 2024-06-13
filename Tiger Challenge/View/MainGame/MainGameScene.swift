import Foundation
import SpriteKit
import SwiftUI

class MaingameScene: SKScene, SKPhysicsContactDelegate {
    
    enum NetType: String {
        case netEasy = "net_eazy"
        case netHard = "net_hard"
        case netVeryHard = "net_very_hard"
    }
    
    var level: LevelModel
    
    private var pauseButton: SKSpriteNode!
    private var addTimeButton: SKSpriteNode!
    private var pers: SKSpriteNode!
    
    private var addTimeCount = 0 {
        didSet {
            addTimeCountLabel.text = "\(addTimeCount)"
            UserDefaults.standard.set(addTimeCount, forKey: "add_time_count")
        }
    }
    
    private var addTimeCountLabel: SKLabelNode!
    private var creditsLabel: SKLabelNode!
    private var posibilityForErrorLabel: SKLabelNode!
    
    private var credits: Int = 0 {
        didSet {
            creditsLabel.text = "\(credits)"
            UserDefaults.standard.set(credits, forKey: "credits_user")
        }
    }
    
    private var posibilityForError: Int = 0 {
        didSet {
            posibilityForErrorLabel.text = "\(posibilityForError)"
            UserDefaults.standard.set(posibilityForError, forKey: "posibility_for_error_count")
        }
    }
    
    private var timeNode: TimeNode!
    private var rulesNode: RulesNode!
    private var rulesContentShow = false
    
    private var time: Int = 92 {
        didSet {
            timeNode.setTime(time: formatTime(seconds: time))
            if time <= 0 {
                loseGame()
            }
        }
    }
    
    private var allNetsAvailable: [NetType] = []
    private var objectiveRedNet = 10
    private var collectedRedNet = 0 {
        didSet {
            if collectedRedNet == objectiveRedNet {
                winGame()
            }
        }
    }
    private var speedNets = 6.0
    
    private var spawnerNetRed: Timer = Timer()
    private var spawnerNetObs: Timer = Timer()
    private var gameTimer: Timer = Timer()
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private var currentGameFon = ""
    
    init(levelModel: LevelModel) {
        self.level = levelModel
        addTimeCount = UserDefaults.standard.integer(forKey: "add_time_count")
        credits = UserDefaults.standard.integer(forKey: "credits_user")
        posibilityForError = UserDefaults.standard.integer(forKey: "posibility_for_error_count")
        currentGameFon = UserDefaults.standard.string(forKey: "current_game_background") ?? "game_base_fon"
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
    
    func recreateGameContent() -> MaingameScene {
        let newMaingameScene = MaingameScene(levelModel: level)
        view?.presentScene(newMaingameScene)
        return newMaingameScene
    }
    
    override func didMove(to view: SKView) {
        size = CGSize(width: 750, height: 1335)
        physicsWorld.contactDelegate = self
        createFonGame()
        createToolbar()
        createPers()
        createFooter()
        
        if !UserDefaults.standard.bool(forKey: "user_rules_presented") {
            showRulesContent()
            rulesContentShow = true
            UserDefaults.standard.set(true, forKey: "user_rules_presented")
        } else {
            setUpGameData()
        }
    }
    
    private func showRulesContent() {
        rulesNode = RulesNode(size: CGSize(width: 500, height: 250))
        rulesNode.position = CGPoint(x: size.width / 2 - 200, y: size.height / 2 - 200)
        rulesNode.rulesEnded = {
            self.rulesContentShow = false
            let actionFadeOut = SKAction.fadeOut(withDuration: 0.3)
            self.rulesNode.run(actionFadeOut) {
                self.rulesNode.removeFromParent()
                self.setUpGameData()
            }
        }
        addChild(rulesNode)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        if bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2 {
            let contactBName = bodyB.node?.name
            if let contactBName = contactBName {
                if contactBName == "net_red" {
                    collectedRedNet += 1
                    bodyB.node!.removeFromParent()
                } else if allNetsAvailable.contains(where: { $0.rawValue == contactBName }) {
                    if posibilityForError > 0 {
                        posibilityForError -= 1
                    } else {
                        loseGame()
                    }

                    bodyB.node!.removeFromParent()
                }
            }
        }
    }
    
    private func setUpGameData() {
        if level.id >= 5 {
            allNetsAvailable.append(.netVeryHard)
        }
        if level.id >= 3 {
            allNetsAvailable.append(.netHard)
        }
        if level.id >= 2 {
            allNetsAvailable.append(.netEasy)
        }
        
        objectiveRedNet += level.id * 5
        speedNets -= Double(level.id) * 0.2
        time -= level.id * 2
        
        spawnerNetRed = .scheduledTimer(withTimeInterval: 2, repeats: true, block: { _ in
            self.spawnNetRed()
        })
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
    
    @objc private func spawnNetRed() {
        if !isPaused {
            let netRed: SKSpriteNode = .init(imageNamed: "net_red")
            let netRedY = CGFloat.random(in: 250...750)
            netRed.position = CGPoint(x: size.width, y: netRedY)
            netRed.physicsBody = SKPhysicsBody(rectangleOf: netRed.size)
            netRed.physicsBody?.isDynamic = true
            netRed.physicsBody?.affectedByGravity = false
            netRed.physicsBody?.categoryBitMask = 2
            netRed.physicsBody?.collisionBitMask = 1
            netRed.physicsBody?.contactTestBitMask = 1
            netRed.name = "net_red"
            addChild(netRed)
            
            let moveAction = SKAction.move(to: CGPoint(x: 0, y: netRedY), duration: speedNets)
            netRed.run(moveAction) {
                let actionFadeOut = SKAction.fadeOut(withDuration: 0.2)
                netRed.run(actionFadeOut) {
                    netRed.removeFromParent()
                }
            }
        }
    }
    
    private func createFooter() {
        let levelBackround: SKSpriteNode = .init(imageNamed: "button_bg")
        levelBackround.position = CGPoint(x: size.width / 2, y: 100)
        levelBackround.size = CGSize(width: 350, height: 120)
        addChild(levelBackround)
        
        let levelLabel: SKLabelNode = .init(text: "LEVEL \(level.id)")
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
        
        addTimeButton = .init(imageNamed: "add_time_button")
        addTimeButton.position = CGPoint(x: size.width - 70, y: size.height - 60)
        addTimeButton.name = "add_time_button"
        addChild(addTimeButton)
        
        let addTimeLabelBack: SKSpriteNode = .init(imageNamed: "level_bg")
        addTimeLabelBack.size = CGSize(width: 46, height: 40)
        addTimeLabelBack.position = CGPoint(x: addTimeButton.position.x + 30, y: addTimeButton.position.y - 28)
        addChild(addTimeLabelBack)
        
        addTimeCountLabel = .init(text: "\(addTimeCount)")
        addTimeCountLabel.fontName = .tlHeaderFont
        addTimeCountLabel.fontSize = 22
        addTimeCountLabel.fontColor = .white
        addTimeCountLabel.position = CGPoint(x: addTimeLabelBack.position.x, y: addTimeLabelBack.position.y - 7)
        addChild(addTimeCountLabel)
        
        let creditsBack: SKSpriteNode = .init(imageNamed: "credits_back")
        creditsBack.position = CGPoint(x: 110, y: size.height - 150)
        creditsBack.size = CGSize(width: 170, height: 60)
        addChild(creditsBack)
        
        creditsLabel = .init(text: "\(credits)")
        creditsLabel.fontName = .tlHeaderFont
        creditsLabel.fontSize = 24
        creditsLabel.fontColor = .white
        creditsLabel.position = CGPoint(x: 75, y: size.height - 160)
        addChild(creditsLabel)
        
        let posibilityForErrorBack: SKSpriteNode = .init(imageNamed: "posibility_for_error")
        posibilityForErrorBack.position = CGPoint(x: size.width - 110, y: size.height - 150)
        posibilityForErrorBack.size = CGSize(width: 170, height: 60)
        addChild(posibilityForErrorBack)
        
        posibilityForErrorLabel = .init(text: "\(posibilityForError)")
        posibilityForErrorLabel.fontName = .tlHeaderFont
        posibilityForErrorLabel.fontSize = 24
        posibilityForErrorLabel.fontColor = .white
        posibilityForErrorLabel.position = CGPoint(x: size.width - 150, y: size.height - 160)
        addChild(posibilityForErrorLabel)
        
        timeNode = TimeNode(size: CGSize(width: 170, height: 60))
        timeNode.position = CGPoint(x: size.width / 2 - 80, y: size.height - 420)
        addChild(timeNode)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !rulesContentShow {
            let touch = touches.first
            if touch == nil {
                return
            }
            let location = touch!.location(in: self)
            if location.y <= 850 && location.y >= 150 {
                pers.position.y = location.y
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let nodeObjects = nodes(at: loc)
        
        if nodeObjects.contains(addTimeButton) {
            if addTimeCount > 0 {
                time += 15
                addTimeCount -= 1
            }
            return
        }
        
        if nodeObjects.contains(pauseButton) {
            pauseGameContent()
            return
        }
    }
    
}

class TimeNode: SKSpriteNode {
    
    private var timeLabel: SKLabelNode
    private var timeBackground: SKSpriteNode
    
    init(size: CGSize) {
        timeBackground = .init(imageNamed: "button_bg")
        timeBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        timeBackground.size = size
        
        timeLabel = .init(text: "01:00")
        timeLabel.fontName = .tlHeaderFont
        timeLabel.fontSize = 24
        timeLabel.fontColor = .white
        timeLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 10)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(timeBackground)
        addChild(timeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTime(time: String) {
        timeLabel.text = time
    }
    
}

class RulesNode: SKSpriteNode {
    
    private var rulesContent: SKSpriteNode
    private var rulesNextButton: SKSpriteNode
    private var allRulesData = ["rules_1", "rules_2", "rules_3"]
    
    var rulesEnded: () -> Void = { }
    var currentRulesContentIndex = 0 {
        didSet {
            setRulesContent()
        }
    }
    
    init(size: CGSize) {
        rulesContent = .init(imageNamed: allRulesData[currentRulesContentIndex])
        rulesContent.position = CGPoint(x: size.width / 2, y: size.height / 2)
        rulesContent.size = size
        
        rulesNextButton = .init(imageNamed: "next_button")
        rulesNextButton.position = CGPoint(x: size.width / 2, y: -10)
        
        super.init(texture: nil, color: .clear, size: size)
        
        addChild(rulesContent)
        addChild(rulesNextButton)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setRulesContent() {
        let newRulesContentTexture = SKTexture(imageNamed: allRulesData[currentRulesContentIndex])
        let action = SKAction.setTexture(newRulesContentTexture)
        rulesContent.run(action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch == nil {
            return
        }
        let nodesAtLoc = nodes(at: touch!.location(in: self))
        
        if nodesAtLoc.contains(rulesNextButton) {
            if currentRulesContentIndex < allRulesData.count - 1 {
                currentRulesContentIndex += 1
            } else {
                rulesEnded()
            }
        }
    }
    
}

#Preview {
    VStack {
        SpriteView(scene: MaingameScene(levelModel: LevelModel(id: 6, levelType: .easy)))
            .ignoresSafeArea()
    }
}
