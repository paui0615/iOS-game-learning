//
//  GameScene.swift
//  ios-game-learning
//
//  Created by 黃勁堯 on 2025/3/30.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 游戏元素
    private var ball: SKSpriteNode?
    private var hoop: SKSpriteNode?
    private var backboard: SKSpriteNode?
    private var scoreLabel: SKLabelNode?
    private var highScoreLabel: SKLabelNode?
    private var score: Int = 0
    private var highScore: Int = 0
    
    // 物理类别
    private let ballCategory: UInt32 = 0x1 << 0
    private let hoopCategory: UInt32 = 0x1 << 1
    private let backboardCategory: UInt32 = 0x1 << 2
    
    // 音效
    private var shootSound: SKAction?
    private var scoreSound: SKAction?
    private var backgroundMusic: SKAudioNode?
    
    // 游戏状态
    private var isGameActive = true
    
    override func didMove(to view: SKView) {
        // 设置物理世界
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        
        // 设置背景
        setupBackground()
        
        // 创建游戏元素
        createBackboard()
        createHoop()
        createBall()
        createScoreLabels()
        
        // 加载音效
        loadSounds()
        
        // 添加背景音乐
        if let musicURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic!)
        }
        
        // 添加开始提示
        showStartMessage()
    }
    
    private func setupBackground() {
        backgroundColor = .white
        
        // 添加地板
        let floor = SKSpriteNode(color: .gray, size: CGSize(width: frame.width, height: 20))
        floor.position = CGPoint(x: frame.midX, y: 10)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        addChild(floor)
    }
    
    private func createBackboard() {
        backboard = SKSpriteNode(color: .white, size: CGSize(width: 20, height: 120))
        backboard?.position = CGPoint(x: frame.maxX - 60, y: frame.maxY - 100)
        backboard?.physicsBody = SKPhysicsBody(rectangleOf: (backboard?.size)!)
        backboard?.physicsBody?.isDynamic = false
        backboard?.physicsBody?.categoryBitMask = backboardCategory
        addChild(backboard!)
    }
    
    private func createHoop() {
        hoop = SKSpriteNode(color: .orange, size: CGSize(width: 100, height: 10))
        hoop?.position = CGPoint(x: frame.maxX - 110, y: frame.maxY - 100)
        hoop?.physicsBody = SKPhysicsBody(rectangleOf: (hoop?.size)!)
        hoop?.physicsBody?.isDynamic = false
        hoop?.physicsBody?.categoryBitMask = hoopCategory
        hoop?.physicsBody?.contactTestBitMask = ballCategory
        addChild(hoop!)
    }
    
    private func createBall() {
        ball = SKSpriteNode(imageNamed: "basketball")
        ball?.size = CGSize(width: 40, height: 40)
        ball?.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        ball?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        ball?.physicsBody?.categoryBitMask = ballCategory
        ball?.physicsBody?.contactTestBitMask = hoopCategory
        ball?.physicsBody?.allowsRotation = true
        ball?.physicsBody?.restitution = 0.5
        addChild(ball!)
    }
    
    private func createScoreLabels() {
        scoreLabel = SKLabelNode(fontNamed: "Arial-Bold")
        scoreLabel?.text = "得分: 0"
        scoreLabel?.fontSize = 30
        scoreLabel?.fontColor = .black
        scoreLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        addChild(scoreLabel!)
        
        highScoreLabel = SKLabelNode(fontNamed: "Arial-Bold")
        highScoreLabel?.text = "最高分: 0"
        highScoreLabel?.fontSize = 20
        highScoreLabel?.fontColor = .black
        highScoreLabel?.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        addChild(highScoreLabel!)
    }
    
    private func showStartMessage() {
        let message = SKLabelNode(fontNamed: "Arial-Bold")
        message.text = "点击屏幕开始投篮"
        message.fontSize = 24
        message.fontColor = .black
        message.position = CGPoint(x: frame.midX, y: frame.midY)
        message.name = "startMessage"
        addChild(message)
    }
    
    private func loadSounds() {
        shootSound = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)
        scoreSound = SKAction.playSoundFileNamed("score.mp3", waitForCompletion: false)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameActive {
            isGameActive = true
            if let message = childNode(withName: "startMessage") {
                message.removeFromParent()
            }
            return
        }
        
        guard let ball = ball else { return }
        
        // 重置球的位置
        ball.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        ball.physicsBody?.velocity = CGVector.zero
        
        // 添加投篮动作
        let shoot = SKAction.run { [weak self] in
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 400))
            self?.run(self?.shootSound ?? SKAction())
        }
        
        run(shoot)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (ballCategory | hoopCategory) {
            // 进球
            score += 1
            scoreLabel?.text = "得分: \(score)"
            if score > highScore {
                highScore = score
                highScoreLabel?.text = "最高分: \(highScore)"
            }
            run(scoreSound ?? SKAction())
            
            // 添加进球特效
            addScoreEffect()
        }
    }
    
    private func addScoreEffect() {
        let effect = SKEmitterNode()
        effect.particleTexture = SKTexture(imageNamed: "spark")
        effect.position = ball?.position ?? CGPoint.zero
        effect.particleBirthRate = 100
        effect.numParticlesToEmit = 20
        effect.particleLifetime = 0.5
        effect.particleSpeed = 100
        effect.particleSpeedRange = 50
        effect.particleAlpha = 0.8
        effect.particleAlphaRange = 0.2
        effect.particleScale = 0.5
        effect.particleScaleRange = 0.25
        effect.particleColorBlendFactor = 0.5
        effect.particleColor = .orange
        addChild(effect)
        
        let wait = SKAction.wait(forDuration: 0.5)
        let remove = SKAction.removeFromParent()
        effect.run(SKAction.sequence([wait, remove]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let ball = ball else { return }
        
        // 检查球是否掉出屏幕
        if ball.position.y < frame.minY {
            resetBall()
        }
    }
    
    private func resetBall() {
        guard let ball = ball else { return }
        ball.position = CGPoint(x: frame.midX, y: frame.minY + 100)
        ball.physicsBody?.velocity = CGVector.zero
    }
}
