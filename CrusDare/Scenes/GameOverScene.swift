//
//  GameOverScene.swift
//  CrusDare
//
//  Created by Stepan on 24.10.2025.

import SpriteKit

class GameOverScene: SKScene {
    
    let finalScore: Int
    
    init(size: CGSize, finalScore: Int) {
        self.finalScore = finalScore
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Текст "Game Over"
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        addChild(gameOverLabel)
        
        // Счёт
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.text = "Score: \(finalScore)"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(scoreLabel)
        
        // Подсказка перезапуска
        let restartLabel = SKLabelNode(fontNamed: "Helvetica")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .gray
        restartLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(restartLabel)
    }
    
    // Перезапуск при тапе
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: 0.5)
        print("View exists? \(self.view != nil)")
        self.view?.presentScene(gameScene, transition: transition)
    }
}
