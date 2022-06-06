//
//  HanoiPuzzleLogic.swift
//
//
//  Created by ito.antonia on 25/03/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class HanoiPuzzleLogic: PuzzleLogic {
    
    var puzzleGridNode: SKNode?
    var selectedTowerNode: SKNode?
    var animatingGridNode: SKNode?
    var towerLevels: [SKNode] = []
    
    class func newScene(gameLogic: GameLogic) -> PipePuzzleLogic {
        guard let scene = gameLogic.loadScene(scene: "Default.PipePuzzle", resourceBundle: "虎.engine.puzzle", classType: PipePuzzleLogic.classForKeyedUnarchiver()) as? PipePuzzleLogic else {
            print("Failed to load PipePuzzle.sks")
            return PipePuzzleLogic()
        }

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
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        puzzleGridNode = self.childNode(withName: "//PuzzleGrid")

        for index in 0 ... 8 {
            let puzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: gridIndexToName(index: index)) as! SKSpriteNode
            if let towerLevel = puzzleGrid.childNode(withName: "Top") {
                let startPuzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: "Col1_Row1") as! SKSpriteNode
                if (puzzleGrid != startPuzzleGrid) {
                    puzzleGrid.removeChildren(in: [towerLevel])
                    startPuzzleGrid.addChild(towerLevel)
                }
            } else if let towerLevel = puzzleGrid.childNode(withName: "Middle") {
                let startPuzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: "Col1_Row2") as! SKSpriteNode
                if (puzzleGrid != startPuzzleGrid) {
                    puzzleGrid.removeChildren(in: [towerLevel])
                    startPuzzleGrid.addChild(towerLevel)
                }
            } else if let towerLevel = puzzleGrid.childNode(withName: "Botom") {
                let startPuzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: "Col1_Row3") as! SKSpriteNode
                if (puzzleGrid != startPuzzleGrid) {
                    puzzleGrid.removeChildren(in: [towerLevel])
                    startPuzzleGrid.addChild(towerLevel)
                }
            }
        }
    }
    
    override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
        super.interactionBegan(point, timestamp: timestamp)
        
        if (textShowing) {
            return
        }
        
        for towerLevel: SKNode in puzzleGridNode!.children {
            if (towerLevel.frame.contains(point) && isOnTop(a: towerLevel)) {
                selectedTowerNode = towerLevel
            }
        }
    }
    
    override func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
        super.interactionMoved(point, timestamp: timestamp)
        selectedTowerNode?.position = point;
    }
    
    override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
        super.interactionEnded(point, timestamp: timestamp)
        if (selectedTowerNode != nil) {
            selectedTowerNode = nil
            checkPuzleCompleted(currentTime: timestamp)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    
    override func checkPuzleCompleted(currentTime: TimeInterval) {
        var completed = false
        
        for index in 0 ... 8 {
            let puzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: gridIndexToName(index: index)) as! SKSpriteNode
            if puzzleGrid.childNode(withName: "Top") != nil {
                let startPuzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: "Col3_Row1") as! SKSpriteNode
                completed = completed && (puzzleGrid == startPuzzleGrid)
            } else if puzzleGrid.childNode(withName: "Middle") != nil {
                let startPuzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: "Col3_Row2") as! SKSpriteNode
                completed = completed && (puzzleGrid == startPuzzleGrid)
            } else if puzzleGrid.childNode(withName: "Botom") != nil {
                let startPuzzleGrid: SKSpriteNode = puzzleGridNode!.childNode(withName: "Col3_Row3") as! SKSpriteNode
                completed = completed && (puzzleGrid == startPuzzleGrid)
            }
        }
        
        if (completed) {
            puzzleComplete = true
            if (hasMoreText()) {
                nextText(currentTime: currentTime)
                textShowing = true
            }
        }
    }
    
    func gridIndexToName(index: Int) -> String {
        switch index {
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
        default:
            return ""
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
    
    func areSameColumn(a: SKNode, b: SKNode) -> Bool {
        let aIndex: Int = gridNameToIndex(text: a.name!)
        let bIndex: Int = gridNameToIndex(text: b.name!)
        return abs(aIndex - bIndex) == 3
    }
    
    func isOnTop(a: SKNode) -> Bool {
        return false//areSameColumn(a: a, b: b) &&
    }
    
    func isPlaceable(a: SKNode) -> Bool {
        return false//areSameColumn(a: a, b: b)
    }
}
