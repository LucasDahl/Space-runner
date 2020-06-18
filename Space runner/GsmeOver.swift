//
//  GsmeOver.swift
//  Space runner
//
//  Created by Lucas Dahl on 6/17/20.
//  Copyright © 2020 Lucas Dahl. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    // Functions
    override func sceneDidLoad() {
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
            
            // Create the level
            let levelOne = GameScene(fileNamed: "LevelOne")
            self.view?.presentScene(levelOne)
            self.removeAllActions()
            
        }
        
    }
    
}
