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
    
    let jumpButton = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 50))
    let attackButton = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
    
    let moveLeftButton = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
    let moveRightButton = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
    
    var movingLeft  = false
    var movingRight = false
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
        
        // Лейбл счёта
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 80, y: size.height - 50)
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        // Земля
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
        
        moveLeftButton.position = CGPoint(x:100, y: 60)
        
        moveRightButton.position = CGPoint(x: size.width - 100, y: 60)
        
        moveLeftButton.alpha = 0.3
        moveRightButton.alpha = 0.3
        addChild(moveLeftButton)
        addChild(moveRightButton)
        
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
        gameOverScene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 1.0)
        
        let delay = SKAction.wait(forDuration: 0.2) // 0.1–0.3 обычно достаточно
        let present = SKAction.run { [weak self] in
            guard let self = self, let skView = self.view else { return }
            skView.presentScene(gameOverScene, transition: transition)
        }
        self.run(SKAction.sequence([delay, present]))
    }
    
    func increaseScore(by points: Int) {
        score += points
        scoreLabel.text = "Score: \(score)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        movingLeft = false
        movingRight = false
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if jumpButton.contains(location) { player.jump() }
            if attackButton.contains(location) { player.swordAttack(scene: self) }
            
            if moveLeftButton.contains(location) {
                movingLeft = true
                movingRight = false
            }
            
            if moveRightButton.contains(location) {
                movingRight = true
                movingLeft = false
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingLeft = false
        movingRight = false
        
        for touch in touches {
            let location = touch.location(in: self)
            
            if moveLeftButton.contains(location) { movingLeft = false }
            if moveRightButton.contains(location) { movingRight = false }
        }
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
