//
//  SearchPuzzleLogic.swift
//  TheAmericat iOS
//
//  Created by A. A. Bills on 25/03/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class SearchPuzzleLogic: PuzzleLogic {
	
	var accumulatedX: CGFloat = 0.0
	var accumulatedY: CGFloat = 0.0
	var handledPress: Bool = true
	
	class func newScene(gameLogic: GameLogic) -> SearchPuzzleLogic {
		guard let scene = SearchPuzzleLogic(fileNamed: "SearchPuzzle" + gameLogic.getAspectSuffix()) else {
			print("Failed to load SearchPuzzle.sks")
			return SearchPuzzleLogic()
		}

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		scene.puzzleComplete = false
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		let puzzleImage = self.childNode(withName: "//PuzzleImage") as! SKSpriteNode
		
		let image: String = ""//self.data?["Image"] as! String
		let imagePath = Bundle.main.path(forResource: image, ofType: ".png")
		if (imagePath != nil) {
			puzzleImage.isHidden = false
			puzzleImage.texture = SKTexture(imageNamed: imagePath!)
		} else {
			puzzleImage.isHidden = true
		}
	}
	
	override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		super.interactionBegan(point, timestamp: timestamp)
		handledPress = false
	}
	
	override func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
		super.interactionMoved(point, timestamp: timestamp)
		let puzzleImage = self.childNode(withName: "//PuzzleImage") as! SKSpriteNode
		let lastPoint: CGPoint = point//(touches.first?.previousLocation(in: self))!
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
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		super.interactionEnded(point, timestamp: timestamp)
		if (!handledPress) {
			let puzzleImage = self.childNode(withName: "//PuzzleImage") as! SKSpriteNode
			if (puzzleImage.frame.contains(point)) {
				let offsetPoint: CGPoint = CGPoint(x: point.x - puzzleImage.position.x, y: point.y - puzzleImage.position.y)
				
				let hotSpots: [NSDictionary] = []//self.data?["HotSpots"] as! [NSDictionary]
				for hotSpot: NSDictionary in hotSpots {
					let radius: Int = hotSpot["Radius"] as! Int
					let center: CGPoint = CGPoint(x: hotSpot["X"] as! Int, y: hotSpot["Y"] as! Int)
					if (distance(startingPoint: offsetPoint, endingPoint: center) <= CGFloat(radius)) {
						puzzleComplete = true
						if (hasMoreText()) {
							nextText(currentTime: timestamp)
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
