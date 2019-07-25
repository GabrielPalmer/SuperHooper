//
//  GameScene.swift
//  SuperHooper
//
//  Created by Gabriel Palmer on 7/12/19.
//  Copyright © 2019 Gabriel Palmer. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    struct PhysicsCategory {
        static let none  : UInt32 = 0
        static let all   : UInt32 = UInt32.max
        static let ball  : UInt32 = 0x1 << 1
        static let basket: UInt32 = 0x1 << 2
        static let edge  : UInt32 = 0x1 << 3
        static let ground: UInt32 = 0x1 << 4
    }

    var scoreArea: UIView!
    let ball = SKSpriteNode(imageNamed: "ball")
    let basket = SKSpriteNode(imageNamed: "basket")
    var ground: SKSpriteNode!
    var timer: Timer?
    var timerSet: Bool = false
    var touchedGround: Bool = false

    @objc func timerFired() {
        timer?.invalidate()
        print("timer ended\n")

        //check that ball has stayed in valid zone
        if ball.position.x > scoreArea.frame.minX
            && ball.position.x < scoreArea.frame.maxX
            && ball.position.y > scoreArea.frame.minY
            && ball.position.y < scoreArea.frame.maxY
//            let ballPhyisics = ball.physicsBody,
//            ballPhyisics.velocity.dx < 25
//            && ballPhyisics.velocity.dx > -25
//            && ballPhyisics.velocity.dy < 25
//            && ballPhyisics.velocity.dy > -25
            {
            randomizePositions()
        }

        timerSet = false
    }

    func randomizePositions() {
        basket.position.x = CGFloat.random(in: 150...view!.frame.width - 150)
        basket.position.y = CGFloat.random(in: 125...view!.frame.height - 100)
        let rotation = CGFloat.pi / CGFloat.random(in: 4...16)
        basket.zRotation = Bool.random() ? rotation : rotation * -1
        scoreArea.frame = basket.frame
        ball.position.x = CGFloat.random(in: 100...view!.frame.width - 100)
        ball.position.y = 75
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.white
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.edge

        //ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: (ball.size.width / 2) - 4)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.collisionBitMask = PhysicsCategory.all
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.basket | PhysicsCategory.ground
        ball.physicsBody?.restitution = 0.75
        ball.physicsBody?.mass = 0.1
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.usesPreciseCollisionDetection = true

        //basket
        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint(x: -48, y: 53), CGPoint(x: -35, y: 53), CGPoint(x: -35, y: -45), CGPoint(x: 35, y: -45), CGPoint(x: 35, y: 53),
            CGPoint(x: 48, y: 53), CGPoint(x: 48, y: -56), CGPoint(x: -48, y: -56)
            ])
        path.closeSubpath()
        basket.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        basket.zRotation = CGFloat.pi / 4
        basket.physicsBody?.isDynamic = false
        basket.physicsBody?.categoryBitMask = PhysicsCategory.basket
        basket.physicsBody?.collisionBitMask = PhysicsCategory.ball
        basket.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        basket.physicsBody?.usesPreciseCollisionDetection = true

        let rectangle = UIView(frame: basket.frame)
        view.addSubview(rectangle)
        scoreArea = rectangle

        //ground
        ground = SKSpriteNode(color: .black, size: CGSize(width: view.frame.width, height: 6))
        ground.position = CGPoint(x: view.frame.width / 2, y: 3)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.frame.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground

        randomizePositions()

        addChild(ball)
        addChild(basket)
        addChild(ground)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touchedGround else { return }
        guard let view = view,
            let ballPhysics = ball.physicsBody,
            let touchLocation = touches.first?.location(in: view) else { return }

        var actualTouchLocation = touchLocation
        actualTouchLocation.y = view.frame.height - touchLocation.y

        var xDiff: CGFloat
        var yDiff: CGFloat

        if actualTouchLocation.x < ball.position.x {
            xDiff = (ball.position.x - actualTouchLocation.x) * -1
        } else {
            xDiff = actualTouchLocation.x - ball.position.x
        }

        if actualTouchLocation.y < ball.position.y {
            yDiff = (ball.position.y - actualTouchLocation.y) * -1
        } else {
            yDiff = actualTouchLocation.y - ball.position.y
        }

        if xDiff / 3 > 100 {
            xDiff = 100
        } else if xDiff / 3 < -100 {
            xDiff = -100
        }

        let xVector = xDiff / 3
        let yVector = yDiff / 2.5

        ballPhysics.velocity = CGVector(dx: 0, dy: 0)
        ballPhysics.applyImpulse(CGVector(dx: xVector, dy: yVector))

        touchedGround = false
    }

    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    }
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    }
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //    }
//        override func update(_ currentTime: TimeInterval) {
//                print(ball.position)
//        }

}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {

        if contact.bodyA.categoryBitMask == PhysicsCategory.ground || contact.bodyB.categoryBitMask == PhysicsCategory.ground {
            touchedGround = true
        } else {
            if !timerSet
                && ball.position.x > scoreArea.frame.minX
                && ball.position.x < scoreArea.frame.maxX
                && ball.position.y > scoreArea.frame.minY
                && ball.position.y < scoreArea.frame.maxY {
                timerSet = true
                timer = Timer(timeInterval: 3, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
                RunLoop.current.add(timer!, forMode: .common)
                print("timer started")
            }
        }
    }
}
