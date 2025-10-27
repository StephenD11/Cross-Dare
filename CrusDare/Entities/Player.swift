//
//  Player.swift
//  CrusDare
//
//  Created by Stepan on 23.10.2025.
//

import SpriteKit

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let ground: UInt32 = 0x1 << 1
    static let enemy:  UInt32 = 0x1 << 2
    static let sword:  UInt32 = 0x1 << 3
}

class Player: SKSpriteNode {
    
    var isOnGround = false

    
    init() {
        let texture = SKTexture(imageNamed: "placeholder_hero") // позже заменим на спрайт
        super.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.allowsRotation = false
        
        
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.1
        self.physicsBody?.friction = 0.8
        
        self.physicsBody?.categoryBitMask = PhysicsCategory.player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ground
        self.physicsBody?.collisionBitMask = PhysicsCategory.ground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func jump() {
        if isOnGround {
            isOnGround = false
            
            physicsBody?.velocity.dy = 900 
        }
    }
    
    func swordAttack(scene: SKScene) {
        let direction: CGFloat = self.xScale >= 0 ? 1 : -1
        
        let swordHitbox = SKNode()
        swordHitbox.position = CGPoint(
            x: self.position.x + (self.size.width / 2 + 30) * direction,
            y: self.position.y
        )
        swordHitbox.zPosition = 10
        
        swordHitbox.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: 20))
        swordHitbox.physicsBody?.isDynamic = false
        swordHitbox.physicsBody?.categoryBitMask = PhysicsCategory.sword
        swordHitbox.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        swordHitbox.physicsBody?.collisionBitMask = 0
        
        scene.addChild(swordHitbox)
        
        let wait = SKAction.wait(forDuration: 0.3)
        let remove = SKAction.removeFromParent()
        swordHitbox.run(SKAction.sequence([wait, remove]))
        
        print("⚔️ Sword Attack!")
    }
}
