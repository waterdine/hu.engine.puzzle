//
//  ZenPuzzleState.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import SpriteKit
import Flat47Game

@available(iOS 11.0, *)
class ZenPuzzleLogic: PuzzleLogic {

	var puzzleGridNode: SKNode?
	var selectedGridNode: SKNode?
	var puzzleGrid: [Int] = [0,0,0,0,0,0,0,0,0]
	var lockedNodes: [Bool] = [false,false,false,false,false,false,false,false,false]
	
	class func newScene(gameLogic: GameLogic) -> ZenPuzzleLogic {
		guard let scene = ZenPuzzleLogic(fileNamed: "ZenPuzzle" + gameLogic.getAspectSuffix()) else {
			print("Failed to load ZenPuzzle.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic
		scene.puzzleComplete = false
		let BG = scene.childNode(withName: "//BG")
		scene.removeChildren(in: [BG!])
		
		let cropNode: SKCropNode = SKCropNode()
		cropNode.maskNode = scene.childNode(withName: "//BGMask")
		cropNode.addChild(BG!)
		let popupNode = scene.childNode(withName: "//Popup")
		popupNode?.addChild(cropNode)
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		puzzleGridNode = self.childNode(withName: "//PuzzleGrid")
		
		let squareListPlist = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "MagicSquares", ofType: "plist")!)
		let squareList: NSArray? = squareListPlist?["Squares"] as? NSArray
		assert(squareList!.count > 50)
		var chosenSquareIndex = Int.random(in: 0...squareList!.count - 1)
		
		let zenChoice = self.data?["ZenChoice"] as? Int
		if (zenChoice == nil) {
			while (((self.gameLogic?.usedSquares.contains(chosenSquareIndex))!)) {
				chosenSquareIndex = (chosenSquareIndex + 1) % squareList!.count
			}
			self.gameLogic?.usedSquares.append(chosenSquareIndex)
		} else {
			chosenSquareIndex = zenChoice!
		}
		let chosenSquare = squareList![chosenSquareIndex];
		
		let squareValues: String = chosenSquare as! String
		let puzzleGridValues: [Substring]? = squareValues.split(separator: ",")
		for index in 0 ... 8 {
			puzzleGrid[index] = gridStringToValue(text: String(puzzleGridValues![index]))
		}
		
		let difficulty = self.data?["DifficultyLevel"] as! Int
		
		if (difficulty == -1)
		{
			for index in 0 ... 8 {
				if (puzzleGrid[index] == 4 || puzzleGrid[index] == 9) {
					puzzleGrid[index] = 0
				}
			}
		} else {
			var gridsToRemove = 1 + difficulty
			if (gridsToRemove > 8) {
				gridsToRemove = 8
			}
			
			while (gridsToRemove > 0) {
				let chosenGridIndex = Int.random(in: 0...8)
				if (puzzleGrid[chosenGridIndex] != 0) {
					puzzleGrid[chosenGridIndex] = 0
					gridsToRemove -= 1
				}
			}
		}
		
		self.gameLogic?.usedSquares.append(chosenSquareIndex)
		
		for grid: SKNode in puzzleGridNode!.children {
			if (grid.name!.hasSuffix("_Label")) {
				continue
			}
			let gridIndex = gridNameToIndex(text: grid.name!)
			let gridLabel = self.childNode(withName: gridIndexToLabel(index: gridIndex)) as! SKLabelNode;
			// TODO image
			if (puzzleGrid[gridIndex] != 0)
			{
				gridLabel.text = String(puzzleGrid[gridIndex])
				gridLabel.fontColor = UIColor.black
				lockedNodes[gridIndex] = true
			} else {
				gridLabel.fontColor = UIColor.purple
				gridLabel.text = ""
				lockedNodes[gridIndex] = false
			}
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		let point: CGPoint = (touches.first?.location(in: self))!
		for grid: SKNode in puzzleGridNode!.children {
			if (grid.name!.hasSuffix("_Label")) {
				continue
			}
			
			let gridIndex = gridNameToIndex(text: grid.name!)
			if (lockedNodes[gridIndex] == false && grid.frame.contains(point)) {
				flowerNode?.position = point
				flowerNode?.isHidden = false
				flowerNode?.setScale(0.0)
				flowerNode?.run(SKAction.scale(to: 5.0, duration: TimeInterval(flowerScaleTime)))
				flowerNode?.run(SKAction.rotate(toAngle: CGFloat((360.0 / 180.0) * Double.pi), duration: TimeInterval(flowerRotateTime)))
				selectedGridNode = grid
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		
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
						let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
						centralFlowerLabel.text = petalValuetoText(value: petalNameToValue(text: (selectedPetalNode?.name)!))
						selectedPetalNode!.fontColor = centralFlowerLabel.fontColor
						break
					}
				}
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		if (!textShowing && !puzzleComplete) {
			//flowerNode?.isHidden = true
			flowerNode?.run(SKAction.scale(to: 0.0, duration: TimeInterval(flowerScaleTime)))
			flowerNode?.run(SKAction.rotate(toAngle: 0, duration: TimeInterval(flowerRotateTime)))
			if (selectedPetalNode != nil) {
				selectedPetalNode!.fontColor = UIColor.white
				let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
				centralFlowerLabel.text = ""
				if (selectedGridNode != nil) {
					let value = petalNameToValue(text: (selectedPetalNode?.name)!)
					let gridIndex = gridNameToIndex(text: (selectedGridNode?.name)!)
					let gridLabel = self.childNode(withName: gridIndexToLabel(index: gridIndex)) as! SKLabelNode;
					puzzleGrid[gridIndex] = value
					// TODO use images instead of text
					gridLabel.text = petalValuetoText(value: value)
					checkPuzleCompleted(currentTime: event!.timestamp)
				}
			}
		}
		
		selectedGridNode = nil
	}
	
	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)
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
		case "Col2_Row2":
			return 4
		case "Col3_Row2":
			return 5
		case "Col1_Row3":
			return 6
		case "Col2_Row3":
			return 7
		case "Col3_Row3":
			return 8
		default:
			return -1
		}
	}
	
	func gridIndexToLabel(index: Int) -> String
	{
		switch index {
		case 0:
			return "//Col1_Row1_Label"
		case 1:
			return "//Col2_Row1_Label"
		case 2:
			return "//Col3_Row1_Label"
		case 3:
			return "//Col1_Row2_Label"
		case 4:
			return "//Col2_Row2_Label"
		case 5:
			return "//Col3_Row2_Label"
		case 6:
			return "//Col1_Row3_Label"
		case 7:
			return "//Col2_Row3_Label"
		case 8:
			return "//Col3_Row3_Label"
		default:
			return ""
		}
	}
	
	override func checkPuzleCompleted(currentTime: TimeInterval) {
		let row1Sum = puzzleGrid[0] + puzzleGrid[1] + puzzleGrid[2]
		let row2Sum = puzzleGrid[3] + puzzleGrid[4] + puzzleGrid[5]
		let row3Sum = puzzleGrid[6] + puzzleGrid[7] + puzzleGrid[8]
		
		let col1Sum = puzzleGrid[0] + puzzleGrid[3] + puzzleGrid[6]
		let col2Sum = puzzleGrid[1] + puzzleGrid[4] + puzzleGrid[7]
		let col3Sum = puzzleGrid[2] + puzzleGrid[5] + puzzleGrid[8]
		
		var duplicates = false
		for a in 0 ... 8 {
			for b in 0 ... 8 {
				if (a != b && puzzleGrid[a] == puzzleGrid[b]) {
					duplicates = true
				}
			}
		}
		
		let rowSumsEqual = (row1Sum == row2Sum) && (row1Sum == row3Sum)
		let colSumsEqual = (col1Sum == col2Sum) && (col1Sum == col3Sum)
		let rowAndColSumsEqual = row1Sum == col1Sum
		if (!duplicates && rowSumsEqual && colSumsEqual && rowAndColSumsEqual)
		{
			puzzleComplete = true
			if (hasMoreText()) {
				nextText(currentTime: currentTime)
				textShowing = true
			}
		}
	}
}
