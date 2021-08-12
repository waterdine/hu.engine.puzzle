//
//  PipePuzzleLogic.swift
//  TheAmericat iOS
//
//  Created by x414e54 on 25/03/2021.
//

import SpriteKit
import Flat47Game

@available(OSX 10.13, *)
@available(iOS 11.0, *)
class PipePuzzleLogic: PuzzleLogic {
	
	var puzzleGridNode: SKNode?
	var selectedGridNode: SKNode?
	var animatingGridNode: SKNode?
	var emptyGridNode: SKSpriteNode?
	var startGridNode: SKSpriteNode?
	var endGridNode: SKSpriteNode?
	var straightTexture: SKTexture?
	var curveTexture: SKTexture?
	
	class func newScene(gameLogic: GameLogic) -> PipePuzzleLogic {
		guard let scene = PipePuzzleLogic(fileNamed: "PipePuzzle" + gameLogic.getAspectSuffix()) else {
			print("Failed to load PipePuzzle.sks")
			return PipePuzzleLogic()
		}

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		scene.puzzleComplete = false
		let BG = scene.childNode(withName: "//BG")
		if (BG != nil) {
			scene.removeChildren(in: [BG!])
			
			let cropNode: SKCropNode = SKCropNode()
			cropNode.maskNode = scene.childNode(withName: "//BGMask")
			cropNode.addChild(BG!)
			let popupNode = scene.childNode(withName: "//Popup")
			popupNode?.addChild(cropNode)
		}
		
		return scene
	}
	
	// Animate pipe fluid or gas with particle effects.
	// Add one emitter to the top, point along the pipe, then a second one in the middle for curved.
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		puzzleGridNode = self.childNode(withName: "//PuzzleGrid")
		
		var imagePath = Bundle.main.path(forResource: "PipeStraight", ofType: ".png")
		straightTexture = SKTexture(imageNamed: imagePath!)
		imagePath = Bundle.main.path(forResource: "PipeCurved", ofType: ".png")
		curveTexture = SKTexture(imageNamed: imagePath!)
		
		let layoutListPlist = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "PipePuzzles", ofType: "plist")!)
		let layoutList: NSArray? = layoutListPlist?["Layouts"] as? NSArray
		assert(layoutList!.count > 0)
		let chosenLayoutIndex = Int.random(in: 0...layoutList!.count - 1)
		
		let chosenLayout = layoutList![chosenLayoutIndex];
		let layoutValues: String = chosenLayout as! String
		let puzzleGridValues: [Substring]? = layoutValues.split(separator: ",")
		for index in 0 ... 8 {
			let puzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: gridIndexToName(index: index)) as! SKSpriteNode
			switch puzzleGridValues![index] {
			case "0":
				emptyGridNode = puzzleGrid
				puzzleGrid.texture = nil
				break
			case "1":
				puzzleGrid.texture = straightTexture
				puzzleGrid.zRotation = 0.0
				break
			case "2":
				puzzleGrid.texture = straightTexture
				puzzleGrid.zRotation = toRad(value: 90.0)
				break
			case "3":
				puzzleGrid.texture = curveTexture
				puzzleGrid.zRotation = 0.0
				break
			case "4":
				puzzleGrid.texture = curveTexture
				puzzleGrid.zRotation = toRad(value: 90.0)
				break
			case "5":
				puzzleGrid.texture = curveTexture
				puzzleGrid.zRotation = toRad(value: 180.0)
				break
			case "6":
				puzzleGrid.texture = curveTexture
				puzzleGrid.zRotation = toRad(value: 270.0)
				break
			default:
				break
			}
		}
		
		startGridNode = puzzleGridNode!.childNode(withName: "PipeStart") as? SKSpriteNode
		startGridNode?.texture = straightTexture
		endGridNode = puzzleGridNode!.childNode(withName: "PipeEnd") as? SKSpriteNode
		endGridNode?.texture = straightTexture
	}
	
	override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		super.interactionBegan(point, timestamp: timestamp)
		
		if (textShowing) {
			return
		}
		
		if (animatingGridNode == nil) {
			for grid: SKNode in puzzleGridNode!.children {
				if (grid != emptyGridNode && grid != startGridNode && grid != endGridNode && grid.frame.contains(point) && isNextTo(a: grid, b: emptyGridNode!)) {
					selectedGridNode = grid
				}
			}
		}
	}
	
	override func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
		super.interactionMoved(point, timestamp: timestamp)
	}
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		super.interactionEnded(point, timestamp: timestamp)
		if (selectedGridNode != nil) {
			let lastPos = selectedGridNode!.position
			let lastName = selectedGridNode!.name
			animatingGridNode = selectedGridNode
			selectedGridNode = nil
			animatingGridNode!.run(SKAction.move(to: emptyGridNode!.position, duration: 0.3))
			animatingGridNode!.name = emptyGridNode!.name
			emptyGridNode!.position = lastPos
			emptyGridNode!.name = lastName
			checkPuzleCompleted(currentTime: timestamp)
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)
		if (animatingGridNode != nil && !animatingGridNode!.hasActions()) {
			animatingGridNode = nil
		}
	}
	
	func getNodeJoins(node: SKSpriteNode) -> [Int] {
		var joins: [Int] = []
		if (node.texture == straightTexture) {
			if (node.zRotation == 0) {
				joins.append(0)
				joins.append(2)
			} else {
				joins.append(1)
				joins.append(3)
			}
		} else if (node.texture == curveTexture) {
			if (node.zRotation == 0) {
				joins.append(0)
				joins.append(1)
			} else if (node.zRotation == toRad(value: 90)) {
				joins.append(1)
				joins.append(2)
			} else if (node.zRotation == toRad(value: 180)) {
				joins.append(2)
				joins.append(3)
			} else if (node.zRotation == toRad(value: 270)) {
				joins.append(0)
				joins.append(3)
			}
		}
		return joins
	}
		
	func doNodesJoin(fromNode: SKSpriteNode, toNode: SKSpriteNode) -> Bool {
		var nodesJoin: Bool = false
		let fromNodeIndex = gridNameToIndex(text: fromNode.name!)
		let toNodeIndex = gridNameToIndex(text: toNode.name!)
		let fromNodeJoins = getNodeJoins(node: fromNode)
		let toNodeJoins = getNodeJoins(node: toNode)
		if (areSameRow(a: fromNode, b: toNode)) {
			if (toNodeIndex > fromNodeIndex) {
				nodesJoin = fromNodeJoins.contains(1) && toNodeJoins.contains(3)
			} else {
				nodesJoin = fromNodeJoins.contains(3) && toNodeJoins.contains(1)
			}
		} else if (areSameColumn(a: fromNode, b: toNode)) {
			if (toNodeIndex > fromNodeIndex) {
				nodesJoin = fromNodeJoins.contains(2) && toNodeJoins.contains(0)
			} else {
				nodesJoin = fromNodeJoins.contains(0) && toNodeJoins.contains(2)
			}
		}
		return nodesJoin
	}
	
	func followPath(node: SKSpriteNode, fromNode: SKSpriteNode) -> SKSpriteNode {
		var nextNode: SKSpriteNode? = node
		let currentNodeIndex = gridNameToIndex(text: node.name!)
		let candidateNodeIndexes = [currentNodeIndex - 3, currentNodeIndex + 1, currentNodeIndex + 3, currentNodeIndex - 1]
		
		var index = 0
		while nextNode == node && index < 4 {
			var possibleNextNode: SKSpriteNode? = nil
			let nextNodeName = gridIndexToName(index: candidateNodeIndexes[index])
			if (nextNodeName != "") {
				possibleNextNode = puzzleGridNode!.childNode(withName: nextNodeName) as? SKSpriteNode
			}
			if (possibleNextNode != nil && possibleNextNode != fromNode && doNodesJoin(fromNode: node, toNode: possibleNextNode!)) {
				   nextNode = possibleNextNode
			}
			index += 1
		}
		return nextNode!
	}
	
	override func checkPuzleCompleted(currentTime: TimeInterval) {
		var previousNode: SKSpriteNode? = startGridNode
		var currentNode: SKSpriteNode? = puzzleGridNode!.childNode(withName: gridIndexToName(index: 1)) as? SKSpriteNode
		if (doNodesJoin(fromNode: previousNode!, toNode: currentNode!)) {
			while (currentNode != previousNode) {
				let nextNode = followPath(node: currentNode!, fromNode: previousNode!)
				previousNode = currentNode
				currentNode = nextNode
			}
		}
		
		if (currentNode == endGridNode) {
			puzzleComplete = true
			if (hasMoreText()) {
				nextText(currentTime: currentTime)
				textShowing = true
			}
		}
	}
	
	func gridIndexToName(index: Int) -> String {
		switch index {
		case -2:
			return "PipeStart"
		case 0:
			return "Col1_Row1"
		case 1:
			return "Col2_Row1"
		case 2:
			return "Col3_Row1"
		case 3:
			return "Col1_Row2"
		case 4:
			return "Col2_Row2"
		case 5:
			return "Col3_Row2"
		case 6:
			return "Col1_Row3"
		case 7:
			return "Col2_Row3"
		case 8:
			return "Col3_Row3"
		case 10:
			return "PipeEnd"
		default:
			return ""
		}
	}
	
	func gridNameToIndex(text: String) -> Int
	{
		switch text {
		case "PipeStart":
			return -2
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
		case "PipeEnd":
			return 10
		default:
			return -1
		}
	}
	
	func areSameRow(a: SKNode, b: SKNode) -> Bool {
		let aIndex: Int = gridNameToIndex(text: a.name!)
		let bIndex: Int = gridNameToIndex(text: b.name!)
		return (abs(aIndex - bIndex) == 1) && (aIndex / 3 == bIndex / 3)
	}
	
	func areSameColumn(a: SKNode, b: SKNode) -> Bool {
		let aIndex: Int = gridNameToIndex(text: a.name!)
		let bIndex: Int = gridNameToIndex(text: b.name!)
		return abs(aIndex - bIndex) == 3
	}
	
	func isNextTo(a: SKNode, b: SKNode) -> Bool {
		return areSameRow(a: a, b: b) || areSameColumn(a: a, b: b)
	}
}
