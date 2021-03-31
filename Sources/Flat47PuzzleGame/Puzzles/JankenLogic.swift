//
//  JankenLogic.swift
//  TheAmericat iOS
//
//  Created by x414e54 on 25/03/2021.
//

import SpriteKit
import GameplayKit
import Flat47Game

enum JankenChoice {
	case Rock, Paper, Scissors
}

enum RoundAnimationState {
	case Show, Text, Health, Finished
}

@available(iOS 11.0, *)
class JankenLogic: PuzzleLogic {
	
	var choicePopup: SKNode?
	var rockNode: SKSpriteNode?
	var paperNode: SKSpriteNode?
	var scissorsNode: SKSpriteNode?
	var combatTextNode: SKLabelNode?
	var playerOneHealthBar: SKSpriteNode?
	var playerTwoHealthBar: SKSpriteNode?
	var playerOneSelection: SKSpriteNode?
	var playerTwoSelection: SKSpriteNode?
	
	var playerOneHealth: Int = 100
	var playerTwoHealth: Int = 100
	var currentCountDown: Int = 3
	var waitingForChoice: Bool = false
	var animatingRound: RoundAnimationState = .Finished
	
	class func newScene(gameLogic: GameLogic) -> JankenLogic {
		guard let scene = JankenLogic(fileNamed: "Janken" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Janken.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic
		scene.puzzleComplete = false
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		choicePopup = self.childNode(withName: "//ChoicePopup")
		rockNode = choicePopup!.childNode(withName: "//Rock") as? SKSpriteNode
		paperNode = choicePopup!.childNode(withName: "//Paper") as? SKSpriteNode
		scissorsNode = choicePopup!.childNode(withName: "//Scissors") as? SKSpriteNode
		combatTextNode = self.childNode(withName: "//CombatText") as? SKLabelNode
		playerOneHealthBar = self.childNode(withName: "//PlayerOneHealthBar") as? SKSpriteNode
		playerTwoHealthBar = self.childNode(withName: "//PlayerTwoHealthBar") as? SKSpriteNode
		playerOneSelection = self.childNode(withName: "//PlayerOneSelection") as? SKSpriteNode
		playerTwoSelection = self.childNode(withName: "//PlayerTwoSelection") as? SKSpriteNode
		let playerOneName = self.childNode(withName: "//PlayerOneName") as? SKLabelNode
		let playerTwoName = self.childNode(withName: "//PlayerTwoName") as? SKLabelNode
		
		choicePopup?.isHidden = true
		combatTextNode?.isHidden = true
		playerOneHealthBar?.xScale = 1.0
		playerTwoHealthBar?.xScale = 1.0
		playerOneName?.text = self.gameLogic?.unwrapVariables(text: "$PlayerName")
		playerTwoName?.text = self.data?["Opponent"] as? String
		animatingRound = .Finished
		playerOneSelection?.isHidden = true
		playerTwoSelection?.isHidden = true
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)

		let point: CGPoint = (touches.first?.location(in: self))!
		if (waitingForChoice) {
			if (rockNode!.frame.contains(point)) {
				makeChoice(playerOneChoice: .Rock)
			} else if (paperNode!.frame.contains(point)) {
				makeChoice(playerOneChoice: .Paper)
			} else if (scissorsNode!.frame.contains(point)) {
				makeChoice(playerOneChoice: .Scissors)
			}
			choicePopup?.isHidden = true
			waitingForChoice = false
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)
		if (!textShowing) {
			if (animatingRound != .Finished) {
				if (animatingRound == .Show && !playerOneSelection!.hasActions() && !playerTwoSelection!.hasActions()) {
					combatTextNode?.isHidden = false
					combatTextNode?.setScale(1.0)
					combatTextNode?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.3), SKAction.scale(to: 1, duration: 0.7)]))
					animatingRound = .Text
				} else if (animatingRound == .Text && !combatTextNode!.hasActions()) {
					playerTwoHealthBar?.run(SKAction.scaleX(to: CGFloat(playerTwoHealth) / 100, duration: 0.3))
					playerOneHealthBar?.run(SKAction.scaleX(to: CGFloat(playerOneHealth) / 100, duration: 0.3))
					animatingRound = .Health
					playerOneSelection?.isHidden = true
					playerTwoSelection?.isHidden = true
				} else if (animatingRound == .Health && !playerTwoHealthBar!.hasActions() && !playerOneHealthBar!.hasActions()) {
					currentCountDown = 3
					animatingRound = .Finished
					checkPuzleCompleted(currentTime: currentTime)
				}
			} else if (!combatTextNode!.hasActions()) {
				if (currentCountDown > 1) {
					combatTextNode?.isHidden = false
					combatTextNode!.text = String.init(format: "%d", currentCountDown)
					combatTextNode?.setScale(1.0)
					combatTextNode?.run(SKAction.sequence([SKAction.scale(to: 1.5, duration: 0.3), SKAction.scale(to: 1, duration: 0.7)]))
					currentCountDown -= 1
				} else {
					combatTextNode?.isHidden = true
					waitingForChoice = true
					choicePopup?.isHidden = false
				}
			}
		}
	}
	
	override func checkPuzleCompleted(currentTime: TimeInterval) {
		super.checkPuzleCompleted(currentTime: currentTime)
		
		if (playerOneHealth == 0) {
			self.gameLogic?.gameOver()
		} else if (playerTwoHealth == 0) {
			puzzleComplete = true
			if (hasMoreText()) {
				nextText(currentTime: currentTime)
				textShowing = true
			}
		}
	}
	
	func AnimateSelection() {
		animatingRound = .Show
		
		var originalScaleX = playerOneSelection!.xScale
		var originalScaleY = playerOneSelection!.yScale
		playerOneSelection?.xScale = 0.0
		playerOneSelection?.yScale = 0.0
		playerOneSelection?.isHidden = false
		playerOneSelection?.run(SKAction.scaleX(to: originalScaleX, y: originalScaleY, duration: 0.3))
		
		originalScaleX = playerTwoSelection!.xScale
		originalScaleY = playerTwoSelection!.yScale
		playerTwoSelection?.xScale = 0.0
		playerTwoSelection?.yScale = 0.0
		playerTwoSelection?.isHidden = false
		playerTwoSelection?.run(SKAction.scaleX(to: originalScaleX, y: originalScaleY, duration: 0.3))
	}
	
	func WinRound() {
		playerTwoHealth -= 10
		combatTextNode?.text = "Win"
		AnimateSelection()
	}
	
	func DrawRound() {
		combatTextNode?.text = "Draw"
		AnimateSelection()
	}
	
	func LooseRound() {
		playerOneHealth -= 10
		combatTextNode?.text = "Loose"
		AnimateSelection()
	}
	
	func makeChoice(playerOneChoice: JankenChoice) {
		var playerTwoChoices: [JankenChoice] = [.Rock, .Paper, .Scissors]
		let forceWin = self.data?["ForceWin"] as? Bool
		if (forceWin != nil && forceWin! && playerOneHealth <= playerTwoHealth) {
			switch playerOneChoice {
			case .Rock:
				playerTwoChoices.removeAll(where: { $0 == .Paper })
				break
			case .Paper:
				playerTwoChoices.removeAll(where: { $0 == .Scissors })
				break
			case .Scissors:
				playerTwoChoices.removeAll(where: { $0 == .Rock })
				break
			}
		}
		let playerTwoChoice: JankenChoice = playerTwoChoices.randomElement()!
		
		switch playerOneChoice {
		case .Rock:
			playerOneSelection?.texture = rockNode?.texture
			switch playerTwoChoice {
			case .Rock:
				playerTwoSelection?.texture = rockNode?.texture
				DrawRound()
				break
			case .Paper:
				playerTwoSelection?.texture = paperNode?.texture
				LooseRound()
				break
			case .Scissors:
				playerTwoSelection?.texture = scissorsNode?.texture
				WinRound()
				break
			}
			break
		case .Paper:
			playerOneSelection?.texture = paperNode?.texture
			switch playerTwoChoice {
			case .Rock:
				playerTwoSelection?.texture = rockNode?.texture
				WinRound()
				break
			case .Paper:
				playerTwoSelection?.texture = paperNode?.texture
				DrawRound()
				break
			case .Scissors:
				playerTwoSelection?.texture = scissorsNode?.texture
				LooseRound()
				break
			}
			break
		case .Scissors:
			playerOneSelection?.texture = scissorsNode?.texture
			switch playerTwoChoice {
			case .Rock:
				playerTwoSelection?.texture = rockNode?.texture
				LooseRound()
				break
			case .Paper:
				playerTwoSelection?.texture = paperNode?.texture
				WinRound()
				break
			case .Scissors:
				playerTwoSelection?.texture = scissorsNode?.texture
				DrawRound()
				break
			}
			break
		}
		
	}
}
