//
//  SearchPuzzleLogic.swift
//  TheAmericat iOS
//
//  Created by x414e54 on 25/03/2021.
//

import SpriteKit
import Flat47Game

@available(OSX 10.12, *)
@available(iOS 11.0, *)
class SearchPuzzleLogic: PuzzleLogic {
	
	var accumulatedX: CGFloat = 0.0
	var accumulatedY: CGFloat = 0.0
	var handledPress: Bool = true
	
	class func newScene(gameLogic: GameLogic) -> SearchPuzzleLogic {
		guard let scene = SearchPuzzleLogic(fileNamed: "SearchPuzzle" + gameLogic.getAspectSuffix()) else {
			print("Failed to load SearchPuzzle.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic
		scene.puzzleComplete = false
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		let puzzleImage = self.childNode(withName: "//PuzzleImage") as! SKSpriteNode
		
		let image: String = self.data?["Image"] as! String
		let imagePath = Bundle.main.path(forResource: image, ofType: ".png")
		if (imagePath != nil) {
			puzzleImage.isHidden = false
			puzzleImage.texture = SKTexture(imageNamed: imagePath!)
		} else {
			puzzleImage.isHidden = true
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		handledPress = false
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		let puzzleImage = self.childNode(withName: "//PuzzleImage") as! SKSpriteNode
		let point: CGPoint = (touches.first?.location(in: self))!
		let lastPoint: CGPoint = (touches.first?.previousLocation(in: self))!
		if (distance(startingPoint: lastPoint, endingPoint: point) > 1.0) {
			puzzleImage.position.x -= lastPoint.x - point.x
			let minX = -(puzzleImage.size.width / 2.0) + (self.size.width / 2.0)
			let maxX = (puzzleImage.size.width / 2.0) - (self.size.width / 2.0)
			if (puzzleImage.position.x < minX) {
				puzzleImage.position.x = minX
			} else if (puzzleImage.position.x > maxX) {
				puzzleImage.position.x = maxX
			}
			puzzleImage.position.y -= lastPoint.y - point.y
			let minY = -(puzzleImage.size.height / 2.0) + (self.size.height / 2.0)
			let maxY = (puzzleImage.size.height / 2.0) - (self.size.height / 2.0)
			if (puzzleImage.position.y < minY) {
				puzzleImage.position.y = minY
			} else if (puzzleImage.position.y > maxY) {
				puzzleImage.position.y = maxY
			}
			handledPress = true
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		if (!handledPress) {
			let puzzleImage = self.childNode(withName: "//PuzzleImage") as! SKSpriteNode
			let point: CGPoint = (touches.first?.location(in: self))!
			if (puzzleImage.frame.contains(point)) {
				let offsetPoint: CGPoint = CGPoint(x: point.x - puzzleImage.position.x, y: point.y - puzzleImage.position.y)
				
				let hotSpots: [NSDictionary] = self.data?["HotSpots"] as! [NSDictionary]
				for hotSpot: NSDictionary in hotSpots {
					let radius: Int = hotSpot["Radius"] as! Int
					let center: CGPoint = CGPoint(x: hotSpot["X"] as! Int, y: hotSpot["Y"] as! Int)
					if (distance(startingPoint: offsetPoint, endingPoint: center) <= CGFloat(radius)) {
						puzzleComplete = true
						if (hasMoreText()) {
							nextText(currentTime: event!.timestamp)
							textShowing = true
						}
					}
				}
			}
			handledPress = true
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)
	}
	
	override func checkPuzleCompleted(currentTime: TimeInterval) {
		super.checkPuzleCompleted(currentTime: currentTime)
	}
}
