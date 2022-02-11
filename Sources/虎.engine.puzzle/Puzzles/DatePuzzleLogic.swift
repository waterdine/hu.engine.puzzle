//
//  QuestionLogic.swift
//  虎.engine.puzzle iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class DatePuzzleLogic: GameScene {

	var puzzleGridNode: SKNode?
	var flowerNode: SKNode?
	var selectedGridNode: SKNode?
	var selectedPetalNode: SKLabelNode?
	var puzzleGrid: [Int] = [0,0,0,0]
	var lockedNodes: [Bool] = [false,false,false,false]
	
	// Petal shapes/data
	var petalNodes: [SKLabelNode?] = [nil,nil,nil,nil,nil,nil,nil,nil,nil]
	var centerSize: Float = 0.0
	var petalLength: Float = 0.0
	var petalAngles: [Float] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
	var flowerScaleTime: Float = 0.2
	var flowerRotateTime: Float = 0.3
	var flowerScale: Float = 5.0
	
	var textShowing: Bool = false
	var currentTextIndex: Int = 0
	
	class func newScene(gameLogic: GameLogic) -> DatePuzzleLogic {
		guard let scene = DatePuzzleLogic(fileNamed: gameLogic.loadUrl(forResource: gameLogic.appendAspectSuffix(scene: "Default.DatePuzzle"), withExtension: ".sks", subdirectory: "Scenes/" + gameLogic.getAspectSuffix())!.path) else {
			print("Failed to load DatePuzzle.sks")
			abort()
		}

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		scene.requiresMusic = true
		let BGTextCover = scene.childNode(withName: "//BGTextCover")
		scene.removeChildren(in: [BGTextCover!])
		
		let cropNodeDescription: SKCropNode = SKCropNode()
		cropNodeDescription.maskNode = scene.childNode(withName: "//BGMaskTextCover")
		cropNodeDescription.addChild(BGTextCover!)
		let popupNodeDescription = scene.childNode(withName: "//Popup")
		popupNodeDescription?.addChild(cropNodeDescription)
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		flowerNode = self.childNode(withName: "//SelectionFlower")
		flowerNode?.isHidden = true
		puzzleGridNode = self.childNode(withName: "//PuzzleGrid")
        
        let sayAnswer = gameLogic!.localizedString(forKey: "Check answer.", value: nil, table: "Story")
        let answerLabel = self.childNode(withName: "//Choice2Label") as? SKLabelNode
        answerLabel?.text = sayAnswer
        
		for index in 0 ... 3 {
			puzzleGrid[index] = 0
		}
		
		for grid: SKNode in puzzleGridNode!.children {
			let gridIndex = gridNameToIndex(text: grid.name!)
			let gridLabel = (grid.children[0]) as! SKLabelNode;
			// atode: image
			if (puzzleGrid[gridIndex] != 0)
			{
				gridLabel.text = String(puzzleGrid[gridIndex])
				lockedNodes[gridIndex] = true
			} else {
				gridLabel.text = ""
				lockedNodes[gridIndex] = false
			}
		}
		
		centerSize = flowerNode?.userData?.value(forKey: "centerSize") as! Float
		petalLength = flowerNode?.userData?.value(forKey: "petalLength") as! Float
		if (flowerNode?.userData?.value(forKey: "scale") != nil) {
			flowerScale = flowerNode?.userData?.value(forKey: "scale") as! Float
			petalLength *= flowerScale / 5.0
		}
		
		let flowerImage = flowerNode?.childNode(withName: "//Flower") as? SKSpriteNode
		for index in 0 ... 8 {
			petalNodes[index] = flowerImage!.children[index] as? SKLabelNode
			petalAngles[index] = flowerNode?.userData?.value(forKey: petalNameToAngleString(name: (petalNodes[index]?.name)!)) as! Float
		}
		
		let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
		centralFlowerLabel.text = ""
		selectedPetalNode = nil
		
		let questionLabel = self.childNode(withName: "//QuestionLabel") as? SKLabelNode
        questionLabel!.text = gameLogic!.localizedString(forKey: (data as! DatePuzzleScene).Question, value: nil, table:  self.gameLogic!.getChapterTable())
		
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		textLabel!.text = ""
		currentTextIndex = -1
		if (hasMoreText()) {
			nextText()
			textShowing = true
		}
	}
	
	override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		if (textShowing) {
			return
		}
		
		for grid: SKNode in puzzleGridNode!.children {
			let gridIndex = gridNameToIndex(text: grid.name!)
			var gridSize: CGSize = grid.frame.size
			gridSize.width = gridSize.width * grid.parent!.xScale
			gridSize.height = gridSize.height * grid.parent!.yScale
			var gridOrigin: CGPoint = grid.convert(CGPoint(x: 0.0, y: 0.0), to: self)
			gridOrigin.x -= gridSize.width / 2.0
			gridOrigin.y -= gridSize.height / 2.0
			let gridFrame = CGRect(origin: gridOrigin, size: gridSize)
			if (lockedNodes[gridIndex] == false && gridFrame.contains(point)) {
				flowerNode?.position = point
				flowerNode?.isHidden = false
				flowerNode?.setScale(0.0)
				flowerNode?.run(SKAction.scale(to: CGFloat(flowerScale), duration: TimeInterval(flowerScaleTime)))
				flowerNode?.run(SKAction.rotate(toAngle: CGFloat((360.0 / 180.0) * Double.pi), duration: TimeInterval(flowerRotateTime)))
				selectedGridNode = grid
			}
		}
	}
	
	func flattenAngle(value: Float) -> Float
	{
		// Assumes only over by one amount
		if (value >= 360.0 && value < 360.0 * 2) {
			return value - 360.0
		}
		
		// Assumes only under by one amount
		if (value < 0 && value >= -360.0) {
			return value + 360.0
		}
		
		return value
	}
	
	func calculateRotation(startingPoint: CGPoint, currentPoint:CGPoint) -> CGFloat {
		let dY: CGFloat = currentPoint.y - startingPoint.y
		let dX: CGFloat = currentPoint.x - startingPoint.x
		let angleFromStart: CGFloat = atan2(dY, dX) * CGFloat((180.0 / Double.pi))
		return angleFromStart
	}
	
	override func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
		if (selectedPetalNode != nil) {
			selectedPetalNode!.fontColor = UIColor.white
			let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
			centralFlowerLabel.text = ""
			selectedPetalNode = nil
		}
		
		if (selectedGridNode != nil) {
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
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		let answerNode = self.childNode(withName: "//SayAnswer")
		if (textShowing) {
			if (hasMoreText()) {
				nextText()
			} else {
				textShowing = false
				currentTextIndex = -1
			}
		} else if (answerNode!.frame.contains(point)) {
			checkPuzleCompleted()
		} else {
			//flowerNode?.isHidden = true
			flowerNode?.run(SKAction.scale(to: 0.0, duration: TimeInterval(flowerScaleTime)))
			flowerNode?.run(SKAction.rotate(toAngle: 0, duration: TimeInterval(flowerRotateTime)))
			if (selectedPetalNode != nil) {
				selectedPetalNode!.fontColor = UIColor.white
				let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
				centralFlowerLabel.text = ""
				if (selectedGridNode != nil) {
					let gridLabel = (selectedGridNode!.children[0]) as! SKLabelNode;
					let value = petalNameToValue(text: (selectedPetalNode?.name)!)
					let gridIndex = gridNameToIndex(text: (selectedGridNode?.name)!)
					puzzleGrid[gridIndex] = value
					// atode: use images instead of text
					gridLabel.text = petalValuetoText(value: value)
				}
			}
		}
		selectedPetalNode = nil
		selectedGridNode = nil
	}
	
	override func update(_ currentTime: TimeInterval) {
		let popupNode = self.childNode(withName: "//Popup")!
		if (textShowing) {
			popupNode.isHidden = false
		} else {
			popupNode.isHidden = true
		}
		// Timeout puzzle here
	}
	
	func petalNameToAngleString(name: String) -> String
	{
		switch name {
		case "Petal_1":
			return "petalAngle_1"
		case "Petal_2":
			return "petalAngle_2"
		case "Petal_3":
			return "petalAngle_3"
		case "Petal_4":
			return "petalAngle_4"
		case "Petal_5":
			return "petalAngle_5"
		case "Petal_6":
			return "petalAngle_6"
		case "Petal_7":
			return "petalAngle_7"
		case "Petal_8":
			return "petalAngle_8"
		case "Petal_9":
			return "petalAngle_9"
		default:
			return ""
		}
	}
	
	func petalValuetoText(value: Int) -> String
	{
		switch value {
		case 1:
			return "1"
		case 2:
			return "2"
		case 3:
			return "3"
		case 4:
			return "4"
		case 5:
			return "5"
		case 6:
			return "6"
		case 7:
			return "7"
		case 8:
			return "8"
		case 9:
			return "9"
		default:
			return "0"
		}
	}
	
	func petalNameToValue(text: String) -> Int
	{
		switch text {
		case "Petal_1":
			return 1
		case "Petal_2":
			return 2
		case "Petal_3":
			return 3
		case "Petal_4":
			return 4
		case "Petal_5":
			return 5
		case "Petal_6":
			return 6
		case "Petal_7":
			return 7
		case "Petal_8":
			return 8
		case "Petal_9":
			return 9
		default:
			return 0
		}
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
        let expectedDate: String = gameLogic!.localizedString(forKey: (data as! DatePuzzleScene).Answer, value: nil, table:  self.gameLogic!.getChapterTable())
		if (selectedDate == expectedDate)
		{
            let skipToScene = (data as! DatePuzzleScene).SkipTo
            self.gameLogic?.setScene(sceneIndex: skipToScene, chapterIndex: self.gameLogic!.currentChapterIndex!)
		} else {
			self.gameLogic?.nextScene()
		}
	}
	
	func hasMoreText() -> Bool {
		var textList: [TextLine]?
        textList = (data as! DatePuzzleScene).Text
		return textList!.count > self.currentTextIndex + 1
	}
	
	func nextText() {
		currentTextIndex += 1
		
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		
		(textLabel!).alpha = 0.0
		(textLabel!).run(SKAction.fadeIn(withDuration: 1.0))
		
		var textList: [TextLine]?
        textList = (data as! DatePuzzleScene).Text
		
		if (textList != nil && textList!.count > self.currentTextIndex) {
            textLabel?.text = gameLogic!.localizedString(forKey: textList![self.currentTextIndex].textString, value: nil, table:  self.gameLogic!.getChapterTable())
		}
		// fade text in
	}
}
