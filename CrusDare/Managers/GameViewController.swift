//
//  GameViewController.swift
//  CrusDare
//
//  Created by Stepan on 23.10.2025.


import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let skView: SKView
        if let existing = self.view as? SKView {
            skView = existing
        } else {
            skView = SKView(frame: view.bounds)
            self.view.addSubview(skView)
        }

        let scene = MainMenuScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
