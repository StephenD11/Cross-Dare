//
//  MainMenuScene.swift
//  CrusDare
//
//  Created by Stepan on 27.10.2025.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    let startButton = SKLabelNode(text: "Start")
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        // Заголовок игры
        let titleLabel = SKLabelNode(text: "Crus Dare")
        titleLabel.fontName = "Helvetica-Bold"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        titleLabel.zPosition = 100
        addChild(titleLabel)
        
        // Кнопка Start
        startButton.fontName = "Helvetica-Bold"
        startButton.fontSize = 36
        startButton.fontColor = .green
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 70)
        startButton.zPosition = 100
        addChild(startButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if startButton.contains(location) {
            // Переход на игровую сцену
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            let transition = SKTransition.crossFade(withDuration: 1.0)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
}
