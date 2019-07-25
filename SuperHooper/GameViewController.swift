//
//  GameViewController.swift
//  SuperHooper
//
//  Created by Gabriel Palmer on 7/12/19.
//  Copyright © 2019 Gabriel Palmer. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    @IBOutlet weak var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        skView.ignoresSiblingOrder = true
//        skView.showsFPS = true
//        skView.showsNodeCount = true
//        skView.showsPhysics = true

        let scene = GameScene(size: view.frame.size)
        scene.scaleMode = .aspectFit
        skView.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
