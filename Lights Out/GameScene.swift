//
//  GameScene.swift
//  Lights Out
//
//  Created by Henrik Panhans on 03.02.18.
//  Copyright © 2018 Henrik Panhans. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

let bgColor = UIColor(red: 172/255, green: 40/255, blue: 28/255, alpha: 1)

class GameScene: SKScene {
    
    let pulse = SKAction(named: "Pulse")!
//    var verticalTextures = [SKTexture]()
//    var horizontalTextures = [SKTexture]()
    var xSpacing: CGFloat = 200
    var ySpacing: CGFloat = 200
    var turns = 0 {
        didSet {
            turnLabel.text = "Turns: \(turns)"
        }
    }
    
    var turnLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    var nodes = [Int:SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        setupGame(size: 3)
        self.scene?.backgroundColor = bgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let positionInScene = touch.location(in: self)
            if let touchedNode = self.atPoint(positionInScene) as? SKSpriteNode {
                turns += 1
                touchedNode.run(pulse)
                touchedNode.switchColor()
                
                for entry in nodes {
                    let node = entry.value
                    if node.position.x == touchedNode.position.x {
                        if Int(node.position.y) == Int(touchedNode.position.y - ySpacing) {
                            node.animate(.down)
                        } else if Int(node.position.y) == Int(touchedNode.position.y + ySpacing) {
                            node.animate(.up)
                        }
                    } else if Int(node.position.y) == Int(touchedNode.position.y) {
                        if Int(node.position.x) == Int(touchedNode.position.x - xSpacing) {
                            node.animate(.left)
                        } else if Int(node.position.x) == Int(touchedNode.position.x + xSpacing) {
                            node.animate(.right)
                        }
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func setupGame(size: Int = 3) {
        turnLabel.text = "Turns: \(turns)"
        turnLabel.fontSize = 100
        turnLabel.color = .white
        turnLabel.position = CGPoint(x: 0, y: 500)
        self.addChild(turnLabel)
        
        let boxSize = (self.scene!.size.width - 150) / CGFloat(size)
        xSpacing = boxSize
        ySpacing = boxSize
        
        for x in 0...(size - 1) {
            for y in 0...(size - 1) {
                
                let node = SKSpriteNode(color: UIColor.randomColor, size: CGSize(width: boxSize - 4, height: boxSize - 4))
                
                let function = CGFloat(0.5 * CGFloat(size) - 0.5)
                print("function factor ", function)
                let factor = -boxSize * function
                let yCoord = factor + (boxSize * CGFloat(y))
                let xCoord = factor + (boxSize * CGFloat(x))
                
                node.position = CGPoint(x: xCoord, y: yCoord)
                
                let tag = ((size * 2) - y * size) + x
                node.name = "\(tag)"
                self.addChild(node)
                nodes[tag] = node
            }
        }
    }
    
}

enum AnimationDirection {
    case down;
    case up;
    case left;
    case right;
}

enum SpriteState {
    case black;
    case white;
}

extension SKSpriteNode {
    func animate(_ direction: AnimationDirection) {
        let newNode = SKSpriteNode(color: self.color, size: self.size)
        let pulse = SKAction(named: "Pulse")!
        self.parent!.addChild(newNode)
        self.run(pulse)
        newNode.run(pulse)
        self.switchColor()
        
        switch direction {
        case .up:
            newNode.anchorPoint = CGPoint(x: 0.5, y: 1)
            newNode.position = CGPoint(x: self.position.x, y: self.position.y + self.size.height / 2)
            newNode.run(SKAction.resize(toHeight: 0, duration: pulse.duration), completion: {
                newNode.removeFromParent()
            })
        case .down:
            newNode.anchorPoint = CGPoint(x: 0.5, y: 0)
            newNode.position = CGPoint(x: self.position.x, y: self.position.y - self.size.height / 2)
            newNode.run(SKAction.resize(toHeight: 0, duration: pulse.duration), completion: {
                newNode.removeFromParent()
            })
        case .left:
            newNode.anchorPoint = CGPoint(x: 0, y: 0.5)
            newNode.position = CGPoint(x: self.position.x - self.size.width / 2, y: self.position.y)
            newNode.run(SKAction.resize(toWidth: 0, duration: pulse.duration), completion: {
                newNode.removeFromParent()
            })
        case .right:
            newNode.anchorPoint = CGPoint(x: 1, y: 0.5)
            newNode.position = CGPoint(x: self.position.x + self.size.width / 2, y: self.position.y)
            newNode.run(SKAction.resize(toWidth: 0, duration: pulse.duration), completion: {
                newNode.removeFromParent()
            })
        }
    }
    
    func switchColor() {
        if self.color.brightness == 1 {
            self.run(SKAction.colorize(with: .black, colorBlendFactor: 1, duration: SKAction(named: "Pulse")!.duration), completion: {
                self.color = .black
            })
        } else if self.color.brightness == 0 {
            self.run(SKAction.colorize(with: .white, colorBlendFactor: 1, duration: SKAction(named: "Pulse")!.duration), completion: {
                self.color = .white
            })
        }
    }
    
    var state: SpriteState {
        if self.color == .white {
            return SpriteState.white
        } else {
            return SpriteState.black
        }
    }
}

extension UIColor {
    class var randomColor: UIColor {
        if arc4random_uniform(20) < 10 {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
    var oppositeColor: UIColor {
        if self == UIColor.black {
            return .white
        } else if self == UIColor.white {
            return .black
        } else {
            return .red
        }
    }
    
    var brightness: CGFloat {
        let color = CIColor(color: self)
        let brightnessValue = color.red * (1/3) + color.green * (1/3) + color.blue * (1/3)
        return brightnessValue
    }
}
