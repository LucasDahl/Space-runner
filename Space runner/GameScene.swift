//
//  GameScene.swift
//  Space runner
//
//  Created by Lucas Dahl on 3/30/20.
//  Copyright © 2020 Lucas Dahl. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //=================
    // MARK: Properties
    //=================
    
    // Nodes
    var player:SKNode?
    var joystick:SKNode?
    var joystickKnob: SKNode?
    var cameraNode: SKCameraNode?
    var mountains1: SKNode?
    var mountains2: SKNode?
    var mountains3: SKNode?
    var moon: SKNode?
    var stars: SKNode?
    
    
    // Bool
    var joystickAction = false
    var rewardIsNotTouched = true
    var isHit = false
    
    // Measurements
    var knobRadius:CGFloat = 50.0
    
    // Score
    let scoreLabel = SKLabelNode()
    var score = 0
    
    // Hearts
    var heartsArry = [SKSpriteNode]()
    let heartContainer = SKSpriteNode()
    
    // Sprite Engine
    var previousTimeInterval:TimeInterval = 0
    var playerIsFacingRight = true
    var playerSpeed = 4.0
    
    // Player State
    var playerStateMachine: GKStateMachine!
    
    //================
    // MARK: - Methods
    //================
    
    // This method initalizes the the UI/Game
    override func didMove(to view: SKView) {
        
        // Setup the physics world
        physicsWorld.contactDelegate = self
        
        // Apply music - wont play sound correctly
//        let soundAction = SKAction.repeatForever(SKAction.playSoundFileNamed("music.wav", waitForCompletion: false))
//        run(soundAction)
        
        // Setup the nodes
        player = childNode(withName: "player")
        joystick = childNode(withName: "joystick")
        joystickKnob = joystick?.childNode(withName: "knob")
        cameraNode = childNode(withName: "cameraNode") as? SKCameraNode
        mountains1 = childNode(withName: "mountains1")
        mountains2 = childNode(withName: "mountains2")
        mountains3 = childNode(withName: "mountains3")
        moon = childNode(withName: "moon")
        stars = childNode(withName: "stars")
        
        // Add the p;ayer states (Animations)
        playerStateMachine = GKStateMachine(states:
            [JumpingState(playerNode: player!),
             WalkingState(playerNode: player!),
             IdleState(playerNode: player!),
             LandingState(playerNode: player!),
             StunnedState(playerNode: player!)
        ])
        
        // Set the player to idle
        playerStateMachine.enter(IdleState.self)
        
        // Hearts
        heartContainer.position = CGPoint(x: -300, y: 140)
        heartContainer.zPosition = 5
        cameraNode?.addChild(heartContainer)
        fillHearts(count: 3)
        
        // Setup the timer to spawn the meteor
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {(timer) in
            self.spawnMeteor()
        }
        
        // Set the score label
        scoreLabel.position = CGPoint(x: (cameraNode?.position.x)! + 310, y: 140)
        scoreLabel.fontColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        scoreLabel.fontSize = 24
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = String(score)
        
        // Add the scoreLabel to the camera node
        cameraNode?.addChild(scoreLabel)
        
        
    }
    
    
    
}

//==============
// MARK: Touches
//==============

extension GameScene {
    
    // Touches Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            if let joystickKnob = joystickKnob {
                let location = touch.location(in: joystick!)
                joystickAction = joystickKnob.frame.contains(location)
                
            }
            
            let location = touch.location(in: self)
            if !(joystick?.contains(location))! {
                playerStateMachine.enter(JumpingState.self)
                
                // Play the jump sound
                run(Sound.jump.action)
                
            }
            
        }
        
    }
    
    // Touches Moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Make sure the joystick and joystickKnob are not nil
        guard let joystick = joystick else { return }
        guard let joystickKnob = joystickKnob else { return }
        
        // Make sure the joystickAction is not nil
        if !joystickAction { return }
        
        // Distance of the knob
        for touch in touches {
            
            let position = touch.location(in: joystick)
            
            let length = sqrt(pow(position.y, 2) + pow(position.x, 2))
            let angle = atan2(position.y, position.x)
            
            if knobRadius > length {
                joystickKnob.position = position
            } else {
                joystickKnob.position = CGPoint(x: cos(angle) * knobRadius, y: sin(angle) * knobRadius)
            }
            
        }
        
    }
    
    // Touches End
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let xJoystickCoordinate = touch.location(in: joystick!).x
            let xLimit:CGFloat = 200.0
            
            if xJoystickCoordinate > -xLimit && xJoystickCoordinate < xLimit {
                resetKnobPosition()
            }
            
        }
        
    }
    
}// End touches

//=============
// MARK: Action
//=============

extension GameScene {
    
    // Setup the action to return the knob to the center
    func resetKnobPosition() {
        
        // set the intial point and apply it to the action
        let initialPoint = CGPoint(x: 0, y: 0)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.1)
        moveBack.timingMode = .linear
        joystickKnob?.run(moveBack)
        joystickAction = false
        
    }
    
    // Update the score
    func rewardTouch() {
        
        score += 1
        scoreLabel.text = String(score)
        
    }
    
    // Adds the hearts to the container
    func fillHearts(count: Int) {
        
        
        for index in 1...count {
            
            let heart = SKSpriteNode(imageNamed: "heart")
            let xPosition = heart.size.width * CGFloat(index - 1)
            
            // Position the hearts
            heart.position = CGPoint(x: xPosition, y: 0)
            
            // Add the heart to the array
            heartsArry.append(heart)
            
            // Add the heart to the container
            heartContainer.addChild(heart)
            
        }
        
    }
    
    func loseHeart() {
        
        if isHit == true {
            
            // Get the last index of the array
            let lastElementIndex = heartsArry.count - 1
            
            // If there are still hearts to remove
            if heartsArry.indices.contains(lastElementIndex - 1) {
                
                let lastHeart = heartsArry[lastElementIndex]
                
                // Remove the last heart from the scene
                lastHeart.removeFromParent()
                
                // Remove the heart from the array
                heartsArry.remove(at: lastElementIndex)
                
                // Make the heart remove after a set time
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                    
                    // Reset the variable
                    self.isHit = false
                    
                }
                
            } else {
                
                // There are no hearts to remove
                dying()
                
                // Show the die scene
                showDieScence()
                
            }
            
            // Make th player invincible
            invincible()
            
        }
        
    }
    
    // Make the player invincible for a short time
    func invincible() {
        
        player?.physicsBody?.categoryBitMask = 0
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
            
            self.player?.physicsBody?.categoryBitMask = 2
            
        }
        
    }
    
    func dying() {
        
        // Create the die action
        let dieAction = SKAction.move(to: CGPoint(x: -300, y: 0), duration: 0.1)
        
        // Run the action to die
        player?.run(dieAction)
        
        // Remove all actions on the player
        self.removeAllActions()
        
        // Reset the hearts
        fillHearts(count: 3)
        
    }
    
    func showDieScence() {
        
        // Create the scene
        let gameOverScene = GameScene(fileNamed: "GameOver")
        
        // Present the scene
        self.view?.presentScene(gameOverScene)
        
    }
    
} // End actions

//===============
// Mark: Gameloop
//===============

extension GameScene {
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = currentTime - previousTimeInterval
        previousTimeInterval = currentTime
        
        rewardIsNotTouched = true
        
        // Camera
        cameraNode?.position.x = player!.position.x
        
        // Set the joystick to be relative to the camera so it stays on screen
        joystick?.position.y = (cameraNode!.position.y) - 100
        joystick?.position.x = (cameraNode!.position.x) - 300
        
               
        // Player movement
        guard let joystickKnob = joystickKnob else { return }
        let xPosition = Double(joystickKnob.position.x)
        let positivePosition = xPosition < 0 ? -xPosition : xPosition
        
        if floor(positivePosition) != 0 {
            playerStateMachine.enter(WalkingState.self)
        } else {
            playerStateMachine.enter(IdleState.self)
        }
        
        let displacement = CGVector(dx: deltaTime * xPosition * playerSpeed, dy: 0)
        let move = SKAction.move(by: displacement, duration: 0)
        let faceAction:SKAction!
        let movingRight = xPosition > 0
        let movingLeft = xPosition < 0
               
        if movingLeft && playerIsFacingRight  {
            playerIsFacingRight = false
            let faceMovement = SKAction.scaleX(to: -1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
        } else if movingRight && !playerIsFacingRight {
            playerIsFacingRight = true
            let faceMovement = SKAction.scaleX(to: 1, duration: 0.0)
            faceAction = SKAction.sequence([move, faceMovement])
                   
            } else {
                faceAction = move
            }
               
        player?.run(faceAction)
        
        // Background Parallax effects
        let parallax1 = SKAction.moveTo(x: (player?.position.x)!/(-10), duration: 0.0)
        mountains1?.run(parallax1)
        
        let parallax2 = SKAction.moveTo(x: (player?.position.x)!/(-20), duration: 0.0)
        mountains2?.run(parallax2)
        
        let parallax3 = SKAction.moveTo(x: (player?.position.x)!/(-40), duration: 0.0)
        mountains3?.run(parallax3)
        
        let parallaxMoon = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
        moon?.run(parallaxMoon)
        
        let parallaxStars = SKAction.moveTo(x: (cameraNode?.position.x)!, duration: 0.0)
        stars?.run(parallaxStars)
        
        
    }
    
}

//================
// MARK: Collision
//================

extension GameScene: SKPhysicsContactDelegate {
    
    // Setup the collision bitmasks
    struct Collision {
        
        enum Masks: Int {
            
            case killing, player, reward, ground
            var bitmask: UInt32 { return 1 << self.rawValue }
            
        }
        
        let masks: (first: UInt32, second: UInt32)
        
        func matches(_ first: Masks, _ second: Masks) -> Bool {
            return (first.bitmask == masks.first && second.bitmask == masks.second) || (first.bitmask == masks.second && second.bitmask == masks.first)
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let collision = Collision(masks: (first: contact.bodyA.categoryBitMask, second: contact.bodyB.categoryBitMask))
        
        if collision.matches(.player, .killing) {
            
            loseHeart()
            isHit = true
            
            // Play the hit sound
            run(Sound.hit.action)
            
            playerStateMachine.enter(StunnedState.self)
            
        }
        
        if collision.matches(.player, .ground) {
            playerStateMachine.enter(LandingState.self)
        }
        
        if collision.matches(.player, .reward) {
            
            if contact.bodyA.node?.name == "jewel" {
                contact.bodyA.node?.physicsBody?.categoryBitMask = 0
                contact.bodyA.node?.removeFromParent()
            } else if contact.bodyB.node?.name == "jewel" {
                contact.bodyB.node?.physicsBody?.categoryBitMask = 0
                contact.bodyB.node?.removeFromParent()
            }
            
            // If reward is true
            if rewardIsNotTouched {
                rewardTouch()
                rewardIsNotTouched = false
            }
            
            // play the reward sound
            run(Sound.reward.action)
            
        }
        
        // Check when a meteor hits the ground
        if collision.matches(.ground, .killing) {
            if contact.bodyA.node?.name == "Meteor", let meteor = contact.bodyA.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
            if contact.bodyB.node?.name == "Meteor", let meteor = contact.bodyB.node {
                createMolten(at: meteor.position)
                meteor.removeFromParent()
            }
            
            // Play the meteor falling sound
            run(Sound.meteorFalling.action)
            
        }
        
    }
    
}

//=============
// MARK: Meteor
//=============

extension GameScene {
    
    func spawnMeteor() {
        
        // Setup the meteor node
        let node = SKSpriteNode(imageNamed: "meteor")
        node.name = "Meteor"
        let randomXPosition = Int(arc4random_uniform(UInt32(self.size.width)))
        
        // Setup the node positioon
        node.position = CGPoint(x: randomXPosition, y: 270)
        node.anchorPoint = CGPoint(x: 0.5, y: 1)
        node.zPosition = 5
        
        // Setup the physics body
        let physicsBody = SKPhysicsBody(circleOfRadius: 30)
        node.physicsBody = physicsBody
        
        // Setup the bitmask and enable collision
        physicsBody.categoryBitMask = Collision.Masks.killing.bitmask
        physicsBody.collisionBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physicsBody.contactTestBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        physicsBody.fieldBitMask = Collision.Masks.player.bitmask | Collision.Masks.ground.bitmask
        
        // Setup the physics
        physicsBody.affectedByGravity = true
        physicsBody.allowsRotation = false
        physicsBody.restitution = 0.2
        physicsBody.friction = 10
        
        // Add the node
        addChild(node)
        
    }
    
    func createMolten(at position: CGPoint) {
        
        // Setup the node
        let node = SKSpriteNode(imageNamed: "molten")
        node.position.x = position.x
        node.position.y = position.y - 60
        node.zPosition = 4
        
        // Add the node
        addChild(node)
        
        // Add a fade action
        let action = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
            ])
        
        // Run the action
        node.run(action)
        
        
    }
    
}
