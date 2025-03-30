//
//  GameViewController.swift
//  ios-game-learning
//
//  Created by 黃勁堯 on 2025/3/30.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // 创建游戏场景
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            // 设置视图属性
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
            // 调试选项
            #if DEBUG
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsPhysics = true
            #endif
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
