//
//  QuestionLogic.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import SpriteKit
import GameplayKit
import Flat47Game

@available(iOS 11.0, *)
class DatePuzzleLogic: PuzzleLogic {

	var puzzleGridNode: SKNode?
	var selectedGridNode: SKNode?
	var puzzleGrid: [Int] = [0,0,0,0]
	var lockedNodes: [Bool] = [false,false,false,false]
	
	class func newScene(gameLogic: GameLogic) -> DatePuzzleLogic {
		guard let scene = DatePuzzleLogic(fileNamed: "DatePuzzle" + gameLogic.getAspectSuffix()) else {
			print("Failed to load DatePuzzle.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		puzzleGridNode = self.childNode(withName: "//PuzzleGrid")
		
		for index in 0 ... 3 {
			puzzleGrid[index] = 0
		}
		
		for grid: SKNode in puzzleGridNode!.children {
			let gridIndex = gridNameToIndex(text: grid.name!)
			let gridLabel = (grid.children[0]) as! SKLabelNode;
			// TODO image
			if (puzzleGrid[gridIndex] != 0)
			{
				gridLabel.text = String(puzzleGrid[gridIndex])
				lockedNodes[gridIndex] = true
			} else {
				gridLabel.text = ""
				lockedNodes[gridIndex] = false
			}
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (textShowing) {
			return
		}
		
		let point: CGPoint = (touches.first?.location(in: self))!
		for grid: SKNode in puzzleGridNode!.children {
			let gridIndex = gridNameToIndex(text: grid.name!)
			if (lockedNodes[gridIndex] == false && grid.frame.contains(point)) {
				flowerNode?.position = point
				flowerNode?.isHidden = false
				selectedGridNode = grid
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (selectedPetalNode != nil) {
			//selectedPetalNode!.fillColor = UIColor.systemYellow
			let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
			   centralFlowerLabel.text = ""
		}
		
		if (selectedGridNode != nil) {
			let point: CGPoint = (touches.first?.location(in: self))!
			let xDistance: Float = Float(point.x - (flowerNode?.position.x)!)
			let yDistance: Float = Float(point.y - (flowerNode?.position.y)!)
			let distance: Float = sqrtf(xDistance * xDistance + yDistance * yDistance)
			// distance from point to center of flower node.
		
			// must be an easier way to do this!
			if ((distance > centerSize) && (distance < centerSize + petalLength)) {
				var angle: Float = Float(calculateRotation(startingPoint: flowerNode!.position, currentPoint: point))
				if (angle < 0)
				{
					angle = 360 + angle;
				}
				for index in 0 ... 8 {
					let petalAngle: Float = petalAngles[index]
					let angleDiff1: Float = flattenAngle(value: (petalAngle - angle))
					let angleDiff2: Float = flattenAngle(value: (angle - petalAngle))
					if (angleDiff1 <= 20 || angleDiff2 <= 20)
					{
						selectedPetalNode = petalNodes[index]
						//selectedPetalNode!.fillColor = UIColor.systemRed
						let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
						centralFlowerLabel.text = petalValuetoText(value: petalNameToValue(text: (selectedPetalNode?.name)!))
						break
					}
				}
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let answerNode = self.childNode(withName: "//SayAnswer")
		let point: CGPoint = (touches.first?.location(in: self))!
		if (answerNode!.frame.contains(point)) {
			checkPuzleCompleted()
		}
		
		if (!textShowing && !puzzleComplete) {
			flowerNode?.isHidden = true
			if (selectedPetalNode != nil) {
				//selectedPetalNode!.fillColor = UIColor.systemYellow
				let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
				centralFlowerLabel.text = ""
				if (selectedGridNode != nil) {
					let gridLabel = (selectedGridNode!.children[0]) as! SKLabelNode;
					let value = petalNameToValue(text: (selectedPetalNode?.name)!)
					let gridIndex = gridNameToIndex(text: (selectedGridNode?.name)!)
					puzzleGrid[gridIndex] = value
					// TODO use images instead of text
					gridLabel.text = petalValuetoText(value: value)
				}
			}
		}
		selectedGridNode = nil
	}
	
	override func update(_ currentTime: TimeInterval) {
	}
	
	func gridStringToValue(text: String) -> Int
	{
		switch text {
		case "1":
			return 1
		case "2":
			return 2
		case "3":
			return 3
		case "4":
			return 4
		case "5":
			return 5
		case "6":
			return 6
		case "7":
			return 7
		case "8":
			return 8
		case "9":
			return 9
		default:
			return 0
		}
	}
	
	func gridNameToIndex(text: String) -> Int
	{
		switch text {
		case "Col1_Row1":
			return 0
		case "Col2_Row1":
			return 1
		case "Col3_Row1":
			return 2
		case "Col1_Row2":
			return 3
		default:
			return -1
		}
	}
	
	func checkPuzleCompleted() {
		let selectedDate: String = String.init(format: "%d%d%d%d", puzzleGrid[0], puzzleGrid[1], puzzleGrid[2], puzzleGrid[3])
		let expectedDate: String = Bundle.main.localizedString(forKey: (self.data?["Answer"] as! String), value: nil, table: "Story")
		if (selectedDate == expectedDate)
		{
			let skipToScene = self.data?["SkipTo"] as! Int
			self.gameLogic?.setScene(index: skipToScene)
		} else {
			self.gameLogic?.nextScene()
		}
	}
}
