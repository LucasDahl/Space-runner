//
//  Sound.swift
//  Space runner
//
//  Created by Lucas Dahl on 6/18/20.
//  Copyright © 2020 Lucas Dahl. All rights reserved.
//

import Foundation
import SpriteKit

enum Sound: String {
    
    case hit, jump, levelUp, meteorFalling, reward
    
    var action: SKAction {
        
        // RawValue is the order of the enum
        return SKAction.playSoundFileNamed(rawValue + "Sound.wav", waitForCompletion: false)
    }
    
}

extension SKAction {
    static let playGameMusic: SKAction = repeatForever(playSoundFileNamed("music.wav", waitForCompletion: false))
}
