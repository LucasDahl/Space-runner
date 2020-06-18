//
//  LevelOne.swift
//  Space runner
//
//  Created by Lucas Dahl on 6/17/20.
//  Copyright © 2020 Lucas Dahl. All rights reserved.
//

import Foundation
import SpriteKit

class LevelOne: GameScene {
    
    
    // Call the override functions
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Change to level 2
        if score >= 1 {
            
            let nextLevel = GameScene(fileNamed: "LevelTwo")
            nextLevel?.scaleMode = .aspectFill
            
            // Present the next level
            view?.presentScene(nextLevel)
            
            // Play the level up sound
            run(Sound.levelUp.action)
            
        }
        
    }
    
}
