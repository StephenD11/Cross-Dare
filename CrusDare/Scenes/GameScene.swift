//
//  GameScene.swift
//  CrusDare
//
//  Created by Stepan on 23.10.2025.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = Player()
    var score = 0
    let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    let highScoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
    
    var moveRightSheet: SKTexture!
    var moveRightFrames: [SKTexture] = []
    var moveRightButton: SKSpriteNode!
    
    var moveLeftSheet: SKTexture!
    var moveLeftFrames: [SKTexture] = []
    var moveLeftButton: SKSpriteNode!
    
    let jumpButton = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 50))
    let attackButton = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
    
    
    var movingLeft  = false
    var movingRight = false
    
    override func didMove(to view: SKView) {
        
        moveLeftSheet = SKTexture(imageNamed: "Button move-Sheet-left")
        moveLeftSheet.filteringMode = .nearest
        
        let frameWidthLeft = 1.0 / 3.0
        let frameHeightLeft = 1.0
        
        moveLeftFrames = [
            SKTexture(rect: CGRect(x: 0/3, y: 0, width: frameWidthLeft, height: frameHeightLeft), in: moveLeftSheet),
            SKTexture(rect: CGRect(x: 1.0/3.0, y: 0, width: frameWidthLeft, height: frameHeightLeft), in: moveLeftSheet),
            SKTexture(rect: CGRect(x: 2.0/3.0, y: 0, width: frameWidthLeft, height: frameHeightLeft), in: moveLeftSheet)
        ]
        
        moveLeftButton = SKSpriteNode(texture: moveLeftFrames[0])
        moveLeftButton.position = CGPoint(x: 100, y: 80)
        moveLeftButton.zPosition = 50
        moveLeftButton.alpha = 0.5
        moveLeftButton.setScale(1.8)
        addChild(moveLeftButton)
        
        moveRightSheet = SKTexture(imageNamed: "Button move-Sheet")
        moveRightSheet.filteringMode = .nearest
        
        let frameWidth = 1.0 / 3.0
        let frameHeight = 1.0
        
        moveRightFrames = [
            SKTexture(rect: CGRect(x: 0/3, y: 0, width: frameWidth, height: frameHeight), in: moveRightSheet),
            SKTexture(rect: CGRect(x: 1.0/3.0, y: 0, width: frameWidth, height: frameHeight), in: moveRightSheet),
            SKTexture(rect: CGRect(x: 2.0/3.0, y: 0, width: frameWidth, height: frameHeight), in: moveRightSheet)
        ]
        
        moveRightButton = SKSpriteNode(texture: moveRightFrames[0])
        moveRightButton.position = CGPoint(x: size.width - 100, y: 80)
        moveRightButton.zPosition = 50
        moveRightButton.setScale(1.8)
        moveRightButton.alpha = 0.5
        addChild(moveRightButton)
        
        
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 80, y: size.height - 50)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        

        let ground = SKSpriteNode(color: .darkGray, size: CGSize(width: size.width, height: 50))
        ground.position = CGPoint(x: size.width / 2, y: ground.size.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
        ground.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        ground.physicsBody?.restitution = 0.0
        ground.physicsBody?.friction = 1.0
        
        addChild(ground)
        
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        highScoreLabel.text = "Top: \(highScore)"
        highScoreLabel.fontSize = 24
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x: size.width - 80, y: size.height - 50)
        highScoreLabel.zPosition = 100
        addChild(highScoreLabel)
        
        
        player.position = CGPoint(x: size.width * 0.5, y: ground.position.y + player.size.height / 2 + 80)
        addChild(player)
        
        jumpButton.position = CGPoint(x: 100, y: 170)
        jumpButton.alpha = 0.3
        jumpButton.zPosition = 50
        addChild(jumpButton)
        
        attackButton.position = CGPoint(x: size.width - 100, y: 170)
        attackButton.alpha = 0.3
        attackButton.zPosition = 50
        addChild(attackButton)
        
        
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnEnemy()
        }
        let delay = SKAction.wait(forDuration: 2.5)
        let sequence = SKAction.sequence([spawnAction, delay])
        run(SKAction.repeatForever(sequence))
    }
    
    func spawnEnemy() {
        for _ in 0..<1 {
            let enemy = Enemy()
            addChild(enemy)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask

        if (a == PhysicsCategory.player && b == PhysicsCategory.ground) ||
           (b == PhysicsCategory.player && a == PhysicsCategory.ground) {
            player.isOnGround = true
        }

        if (a == PhysicsCategory.player && b == PhysicsCategory.enemy) ||
           (b == PhysicsCategory.player && a == PhysicsCategory.enemy) {
            playerDied()
        }

        if (a == PhysicsCategory.sword && b == PhysicsCategory.enemy) ||
           (b == PhysicsCategory.sword && a == PhysicsCategory.enemy) {
            if let enemy = (a == PhysicsCategory.enemy ? contact.bodyA.node : contact.bodyB.node) {
                enemy.removeFromParent()
                increaseScore(by: 1)
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask

        if (a == PhysicsCategory.player && b == PhysicsCategory.ground) ||
           (b == PhysicsCategory.player && a == PhysicsCategory.ground) {
            player.isOnGround = false
        }
    }
    
    func playerDied() {
        guard player.parent != nil else { return }
        print("💀 Crusader dead! — scheduling GameOver transition")
        
        player.removeFromParent()
        
        let gameOverScene = GameOverScene(size: self.size, finalScore: score)
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        
        gameOverScene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 1.0)
        
        let delay = SKAction.wait(forDuration: 0.2)
        let present = SKAction.run { [weak self] in
            guard let self = self, let skView = self.view else { return }
            skView.presentScene(gameOverScene, transition: transition)
        }
        self.run(SKAction.sequence([delay, present]))
    }
    
    func increaseScore(by points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
        updateHighScore()

    }
    
    func updateHighScore() {
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        highScoreLabel.text = "Top: \(highScore)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            if jumpButton.contains(location) { player.jump() }
            if attackButton.contains(location) { player.swordAttack(scene: self) }

            if moveLeftButton.contains(location) {
                movingLeft = true
                movingRight = false
                moveLeftButton.removeAllActions()
                moveLeftButton.texture = moveLeftFrames[1]
            }

            if moveRightButton.contains(location) {
                movingRight = true
                movingLeft = false
                moveRightButton.removeAllActions()
                moveRightButton.texture = moveRightFrames[1]
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if moveLeftButton.contains(location) {
                movingLeft = false
                moveLeftButton.texture = moveLeftFrames[0]
            }
            if moveRightButton.contains(location) {
                movingRight = false
                moveRightButton.texture = moveRightFrames[0]
            }
        }

        if !isAnyTouchOnButton(button: moveLeftButton, touches: touches) {
            movingLeft = false
            moveLeftButton.texture = moveLeftFrames[0]
        }
        if !isAnyTouchOnButton(button: moveRightButton, touches: touches) {
            movingRight = false
            moveRightButton.texture = moveRightFrames[0]
        }
    }

    private func isAnyTouchOnButton(button: SKSpriteNode, touches: Set<UITouch>) -> Bool {
        for touch in touches {
            let location = touch.location(in: self)
            if button.contains(location) {
                return true
            }
        }
        return false
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let body = player.physicsBody else { return }

        let maxSpeed: CGFloat = 200
        let accel: CGFloat = 65
        let airAccel: CGFloat = 50
        let friction: CGFloat = 0.85

        let currentAccel = player.isOnGround ? accel : airAccel

        if movingLeft {
            body.velocity.dx = max(body.velocity.dx - currentAccel, -maxSpeed)
            player.xScale = -1
        } else if movingRight {
            body.velocity.dx = min(body.velocity.dx + currentAccel, maxSpeed)
            player.xScale = 1
        } else {
            body.velocity.dx *= friction
        }

        let halfWidth = player.size.width / 2
        if player.position.x < halfWidth {
            player.position.x = halfWidth
            body.velocity.dx = 0
        } else if player.position.x > size.width - halfWidth {
            player.position.x = size.width - halfWidth
            body.velocity.dx = 0
        }
    }
    

}
