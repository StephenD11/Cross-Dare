//
//  Enemy.swift
//  CrusDare
//
//  Created by Stepan on 24.10.2025.
//

import SpriteKit

class Enemy: SKSpriteNode {
    
    init() {
        let randomY = CGFloat.random(in: 80...200)
        let duration = Double.random(in: 1.0...6.0)
        
        let texture = SKTexture(imageNamed: "placeholder_enemy") // позже заменим на спрайт
        super.init(texture: texture, color: .clear, size: CGSize(width: 40, height: 40))
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false

        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.ground
        
        let spawnFromLeft = Bool.random()
        let sceneWidth = self.scene?.size.width ?? UIScreen.main.bounds.width
        if spawnFromLeft {
            self.position = CGPoint(x: -40, y: randomY)
        } else {
            self.position = CGPoint(x: sceneWidth + 40, y: randomY)
        }
        
        
        let moveX: CGFloat
        if spawnFromLeft {
            moveX = sceneWidth + 80
        } else {
            moveX = -(sceneWidth + 80)
        }
        
        
        let moveAction = SKAction.moveBy(x: moveX, y: 0, duration: duration)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAction, remove])
        run(sequence)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
