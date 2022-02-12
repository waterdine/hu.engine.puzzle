//
//  ZenPuzzleState.swift
//  虎.engine.puzzle iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import SpriteKit
import 虎_engine_base

/*enum EncAnimStage {
	case LiftingUp, FadingOut, Magic, FadingIn, DropingDown, Stamping, Hiding
}*/

#if os(OSX)
typealias UIColor = NSColor
typealias UIFont = NSFont
#endif

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class ZenPuzzleLogic: GameScene {

	var puzzleGridNode: SKNode?
	var flowerNode: SKNode?
	var selectedGridNode: SKNode?
	var selectedPetalNode: SKLabelNode?
	var puzzleGrid: [Int] = [0,0,0,0,0,0,0,0,0]
	var lockedNodes: [Bool] = [false,false,false,false,false,false,false,false,false]
	var puzzleComplete: Bool = false
	
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
	var stickyText: Bool = false
	var lastTextChange: TimeInterval = 0.0
	var lastAnimationCompleteTime: TimeInterval = 0.0
	var animatingText: Bool = false
	var stampSeal: Bool = false
	var fadeSeal: Bool = false
	var currentTextSpeed: Double = 0.0
	var speedingText: Bool = false
	var fixedText: String = ""
	var newText: String = ""
	var encrypting: Bool = false
	var nextEncAnim: Double = 0.0
	var encAnimStage: EncAnimStage = EncAnimStage.LiftingUp
	var encodeTextList: [Character] = ["月","火","日","土","金","水","木","犬","猫","虎","竜"]
	var cachedPosition: CGPoint = CGPoint()
	var animatingBG: Bool = false
	
	class func newScene(gameLogic: GameLogic) -> ZenPuzzleLogic {
        guard let scene = try! gameLogic.loadScene(scene: "Default.ZenPuzzle", classType: ZenPuzzleLogic.classForKeyedUnarchiver()) as? ZenPuzzleLogic else {
            print("Failed to load ZenPuzzle.sks")
            return ZenPuzzleLogic()
        }

		scene.requiresMusic = true
		scene.puzzleComplete = false
		let BG = scene.childNode(withName: "//BG")
		scene.removeChildren(in: [BG!])
		let BGTextCover = scene.childNode(withName: "//BGTextCover")
		scene.removeChildren(in: [BGTextCover!])
		
		let cropNode: SKCropNode = SKCropNode()
		cropNode.maskNode = scene.childNode(withName: "//BGMask")
		cropNode.addChild(BG!)
		let popupNode = scene.childNode(withName: "//Popup")
		popupNode?.addChild(cropNode)
		
		let cropNodeDescription: SKCropNode = SKCropNode()
		cropNodeDescription.maskNode = scene.childNode(withName: "//BGMaskTextCover")
		cropNodeDescription.addChild(BGTextCover!)
		let popupNodeDescription = scene.childNode(withName: "//DescriptionPopup")
		popupNodeDescription?.addChild(cropNodeDescription)
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		puzzleComplete = false
		
		flowerNode = self.childNode(withName: "//SelectionFlower")
		flowerNode?.isHidden = true
		puzzleGridNode = self.childNode(withName: "//PuzzleGrid")
		
		let squareListPlist = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "MagicSquares", ofType: "plist")!)
		let squareList: NSArray? = squareListPlist?["Squares"] as? NSArray
		assert(squareList!.count > 50)
		var chosenSquareIndex = Int.random(in: 0...squareList!.count - 1)
		
        let zenChoice = (data as! ZenPuzzleScene).ZenChoice
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
		
        let difficulty = (data as! ZenPuzzleScene).DifficultyLevel ?? 0
		
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
			let gridLabel = self.childNode(withName: gridIndexToLabel(index: gridIndex)) as! SKLabelNode
			// atode: image
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
		
        let characterFontName = gameLogic!.localizedString(forKey: "CharacterFontName", value: nil, table: "Story")
        let fontName = gameLogic!.localizedString(forKey: "FontName", value: nil, table: "Story")
        
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		textLabel!.text = ""
        textLabel!.fontName = characterFontName
		let stickyTextLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
		stickyTextLabel!.text = ""
        stickyTextLabel!.fontName = fontName
		currentTextIndex = -1
		stickyText = false
		fixedText = ""
		newText = ""
        if #available(iOS 11.0, *) {
            stickyTextLabel?.attributedText =  NSAttributedString()
        } else {
            // Fallback on earlier versions
        }
		lastTextChange = 0.0
		lastAnimationCompleteTime = 0.0
		animatingText = false
		currentTextSpeed = self.gameLogic!.textFadeTime
		speedingText = false
		stampSeal = false
		fadeSeal = false
		encrypting = false
		let seal = self.childNode(withName: "//Seal") as? SKSpriteNode
		seal?.isHidden = true
		
		let backgroundNode = self.childNode(withName: "//SKSpriteNode")
		let pos = backgroundNode?.userData!["OriginalPos"] as! Int
        let animate = (data as! ZenPuzzleScene).Animate
		if (pos != 0 && animate != nil && animate! == true) {
			backgroundNode?.position.x = CGFloat(pos)
			backgroundNode?.run(SKAction.moveTo(x: 0.0, duration: 5.0))
			animatingBG = true
		} else {
			backgroundNode?.position.x = 0
			if (hasMoreText()) {
				nextText(currentTime: 0.0)
				textShowing = true
			}
			animatingBG = false
		}
	}
	
	override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		if (puzzleComplete || textShowing || animatingBG) {
			if (stickyText) {
				if (animatingText) {
					speedingText = true
				}
			}
			return
		}

		for grid: SKNode in puzzleGridNode!.children {
			if (grid.name!.hasSuffix("_Label")) {
				continue
			}
			
			let gridIndex = gridNameToIndex(text: grid.name!)
			var gridSize: CGSize = grid.frame.size
			gridSize.width = gridSize.width * grid.parent!.xScale * grid.parent!.parent!.xScale
			gridSize.height = gridSize.height * grid.parent!.yScale * grid.parent!.parent!.yScale
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
		if (puzzleComplete || animatingBG) {
			return
		}
		
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
		if (handleToolbar(point)) {
			gameMenu?.isHidden = false
			return
		}
		
		if (gameMenu?.isHidden == false) {
			gameMenu!.interactionEnded(point, timestamp: timestamp)
			return
		}
		
		if (textShowing) {
			if (stickyText && speedingText) {
				speedingText = false
			} else if (hasMoreText()) {
				if (readyForMoreText(currentTime: timestamp, delay: self.gameLogic!.actionDelay)) {
					nextText(currentTime: timestamp)
				}
			} else {
				if (readyForMoreText(currentTime: timestamp, delay: self.gameLogic!.actionDelay)) {
					textShowing = false
					currentTextIndex = -1
					if (puzzleComplete) {
						super.interactionEnded(point, timestamp: timestamp)
					} else if (self.gameLogic!.skipPuzzles) {
						puzzleComplete = true
						if (hasMoreText()) {
							nextText(currentTime: timestamp)
							textShowing = true
						}
					}
				}
			}
		} else if (puzzleComplete) {
			super.interactionEnded(point, timestamp: timestamp)
		} else if (!animatingBG) {
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
					// atode: use images instead of text
					gridLabel.text = petalValuetoText(value: value)
					checkPuzleCompleted(currentTime: timestamp)
				}
			}
		}
		selectedPetalNode = nil
		selectedGridNode = nil
	}
	
	override func update(_ currentTime: TimeInterval) {
		let popupNode = self.childNode(withName: "//Popup")!
		let descriptionPopupNode = self.childNode(withName: "//DescriptionPopup")!
		
		if (textShowing) {
			popupNode.isHidden = !(stickyText || encrypting)
			descriptionPopupNode.isHidden = stickyText && encrypting
		} else {
			popupNode.isHidden = true
			descriptionPopupNode.isHidden = true
		}
		
		if (animatingBG) {
			let backgroundNode = self.childNode(withName: "//SKSpriteNode")
			if (!backgroundNode!.hasActions()) {
				if (hasMoreText()) {
					nextText(currentTime: 0.0)
					textShowing = true
					if (stickyText || encrypting) {
						popupNode.alpha = 0.0
						popupNode.run(SKAction.fadeIn(withDuration: 1.0))
						popupNode.isHidden = false
						descriptionPopupNode.isHidden = true
					} else {
						descriptionPopupNode.alpha = 0.0
						descriptionPopupNode.run(SKAction.fadeIn(withDuration: 1.0))
						descriptionPopupNode.isHidden = false
						popupNode.isHidden = true
					}
				}
				animatingBG = false
			} else {
				return
			}
		}
		// Timeout puzzle here
		
		if (stickyText) {
			if (speedingText) {
				currentTextSpeed = 0.01
			} else if (!speedingText && currentTextSpeed == 0.01) {
				updateCharactersForTextSpeed(currentTime: currentTime)
				currentTextSpeed = self.gameLogic!.textFadeTime
			}
			
			if (animatingText) {
				if (lastTextChange == 0.0) {
					lastTextChange = currentTime
				}
				let textLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
				let delta = (currentTime - lastTextChange)
				
				let mainColor = (textLabel?.fontColor!.cgColor.components)!
				let font = UIFont.init(name: (textLabel!.fontName!) as String, size: textLabel!.fontSize)
				let mainAttributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : textLabel?.fontColor as Any]
				let string: NSMutableAttributedString = NSMutableAttributedString(string: fixedText, attributes: mainAttributes)
				
				var remainingCharacters = newText.count
				if (remainingCharacters > 0) {
					let textFadeTime = currentTextSpeed
					let deltaFadeTime = delta / textFadeTime
					let fadingCharacterAlpha = deltaFadeTime - Double(Int(deltaFadeTime))
					
					var fakeIndex = 0
					for index: Int in 0 ... newText.count - 1 {
						let indexFadeStartTime = Double(fakeIndex) * textFadeTime
						let characterAlpha = (delta >= indexFadeStartTime + textFadeTime) ? 1.0 : (delta < indexFadeStartTime) ? 0.0 : fadingCharacterAlpha
						let color = UIColor.init(red: mainColor[0], green: mainColor[1], blue: mainColor[2], alpha: CGFloat(characterAlpha))
						
						let attributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : color]
						var characterIndex: String.Index = newText.startIndex
						newText.formIndex(&characterIndex, offsetBy: index)
						let character = newText[characterIndex]
						if (character == ",") {
							fakeIndex += 5
						} else {
							fakeIndex += 1
						}
						let attributedCharacterString: NSAttributedString = NSAttributedString(string: String(character), attributes: attributes)
						string.append(attributedCharacterString)
						
						if (characterAlpha == 1.0) {
							remainingCharacters -= 1
						}
					}
				}
				
                if #available(iOS 11.0, *) {
                    textLabel?.attributedText = string
                } else {
                    // Fallback on earlier versions
                }
				
				if (remainingCharacters == 0) {
					lastAnimationCompleteTime = currentTime
					animatingText = false
					if (fadeSeal) {
						let seal = self.childNode(withName: "//Seal") as? SKSpriteNode
						seal?.isHidden = false
						seal?.alpha = 0.0
						seal?.position = CGPoint(x: (textLabel?.frame.maxX)! - 20.0, y: (textLabel?.frame.minY)! + 20.0)
						seal?.run(SKAction.fadeIn(withDuration: 0.3))
						fadeSeal = false
					}
				}
			}
			
			if (readyForMoreText(currentTime: currentTime, delay: self.gameLogic!.textDelay) && canAutoProgress()) {
				if (hasMoreText()) {
					nextText(currentTime: currentTime)
				}
			}
			
			if (speedingText) {
				currentTextSpeed = 0.01
			}
		} else if (encrypting) {
			let stickyTextLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
			let stickyTextShadowLabel = self.childNode(withName: "//StickyTextShadowLabel") as? SKLabelNode
			if (nextEncAnim == -1.0) {
				nextEncAnim = currentTime + 0.7
				encAnimStage = EncAnimStage.LiftingUp
				cachedPosition = stickyTextLabel!.position
			} else if (currentTime >= nextEncAnim) {
                let encodeFontScale: CGFloat = CGFloat(Float.init(gameLogic!.localizedString(forKey: "EncodeFontScale", value: nil, table: "Story"))!)
				let delta = currentTime - nextEncAnim
				let textFadeTime = 1.5
				let deltaFadeTime = delta / textFadeTime
				let fadingCharacterAlpha = deltaFadeTime - Double(Int(deltaFadeTime))
				let totalOffset: CGFloat = 10.0
				switch encAnimStage {
				case .LiftingUp:
                    if #available(iOS 11.0, *) {
                        var offset: CGFloat = CGFloat(fadingCharacterAlpha) * totalOffset
                        if (deltaFadeTime >= 1) {
                            offset = CGFloat(1.0 * totalOffset)
                            nextEncAnim = nextEncAnim + 1.5
                            encAnimStage = .FadingOut
                        }
                        var attributes = stickyTextLabel?.attributedText?.attributes(at: 0, effectiveRange: nil)
                        attributes![.strokeWidth] = -1.0
                        stickyTextShadowLabel?.attributedText = NSAttributedString(string: (stickyTextLabel?.attributedText!.string)!, attributes: attributes)
                        stickyTextShadowLabel?.isHidden = false
                        stickyTextShadowLabel?.position = cachedPosition
                        stickyTextShadowLabel?.alpha = 0.5
                        stickyTextLabel?.position = CGPoint(x: cachedPosition.x + offset, y: cachedPosition.y + offset)
                    } else {
                        // Fallback on earlier versions
                    }
					break
				case .FadingOut:
					stickyTextLabel?.run(SKAction.fadeOut(withDuration: 0.3))
					stickyTextShadowLabel?.run(SKAction.fadeOut(withDuration: 0.3))
					nextEncAnim = nextEncAnim + 0.3
					encAnimStage = .Magic
					break
				case .Magic:
                    if #available(iOS 11.0, *) {
                        let string = stickyTextLabel?.attributedText?.string
                        var attributes = stickyTextLabel?.attributedText?.attributes(at: 0, effectiveRange: nil)
                        var output: String = String()
                        for index in 0 ... string!.count - 1 {
                            var characterIndex: String.Index = string!.startIndex
                            string!.formIndex(&characterIndex, offsetBy: index)
                            if (string![characterIndex] != " " && string![characterIndex] != "\n" && string![characterIndex] != "," && string![characterIndex] != ".") {
                                output.append(encodeTextList[index % encodeTextList.count])
                            } else {
                                output.append(string![characterIndex])
                            }
                        }
                        let font = UIFont.init(name: (stickyTextLabel!.fontName!) as String, size: stickyTextLabel!.fontSize / encodeFontScale)
                        attributes![.font] = font
                        stickyTextLabel?.attributedText? = NSAttributedString(string: output, attributes: attributes)
                        stickyTextLabel?.position = CGPoint(x: cachedPosition.x + totalOffset, y: cachedPosition.y + totalOffset)
                        var attributes2 = attributes
                        attributes2![.strokeWidth] = -1.0
                        stickyTextShadowLabel?.attributedText? = NSAttributedString(string: output, attributes: attributes2)
                        stickyTextShadowLabel?.position = cachedPosition
                        encAnimStage = .FadingIn
                    } else {
                        // Fallback on earlier versions
                    }
					break
				case .FadingIn:
					stickyTextLabel?.run(SKAction.fadeIn(withDuration: 0.3))
					stickyTextShadowLabel?.run(SKAction.fadeAlpha(to: 0.5, duration: 0.3))
					nextEncAnim = nextEncAnim + 0.3
					encAnimStage = .DropingDown
					break
				case .DropingDown:
					var offset: CGFloat = CGFloat(1 - fadingCharacterAlpha) * totalOffset
					if (deltaFadeTime >= 1) {
						offset = 0.0
                        if #available(iOS 11.0, *) {
                            stickyTextShadowLabel?.attributedText = NSAttributedString()
                        }
						stickyTextShadowLabel?.isHidden = true
						if (stampSeal) {
							encAnimStage = .Stamping
						} else {
							stickyTextLabel?.run(SKAction.fadeOut(withDuration: 1.0))
							encAnimStage = .Hiding
						}
					} else {
                        if #available(iOS 11.0, *) {
                            var attributes = stickyTextLabel?.attributedText?.attributes(at: 0, effectiveRange: nil)
                            attributes![.strokeWidth] = -1.0
                            stickyTextShadowLabel?.attributedText = NSAttributedString(string: (stickyTextLabel?.attributedText!.string)!, attributes: attributes)
                            stickyTextShadowLabel?.isHidden = false
                            stickyTextShadowLabel?.position = cachedPosition
                        }
					}
					stickyTextLabel?.position = CGPoint(x: cachedPosition.x + offset, y: cachedPosition.y + offset)
					break
				case .Stamping:
					let seal = self.childNode(withName: "//Seal") as? SKSpriteNode
					if (stampSeal) {
						seal?.run(SKAction.init(named: "Stamp")!)
						seal?.isHidden = false
						seal?.position = CGPoint(x: (stickyTextLabel?.frame.maxX)! - 20.0, y: (stickyTextLabel?.frame.minY)! + 20.0)
						stampSeal = false
					} else if (!seal!.hasActions()) {
						stickyTextLabel?.run(SKAction.fadeOut(withDuration: 1.0))
						encAnimStage = .Hiding
					}
					break
				case .Hiding:
					if (hasMoreText()) {
						nextText(currentTime: currentTime)
					}
					encrypting = false
					break
				}
			}
		}
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
	
	func checkPuzleCompleted(currentTime: TimeInterval) {
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
	
	func canAutoProgress() -> Bool {
		if (!hasMoreText()) {
			return true
		}
		
		var textList: [TextLine]?
		if (puzzleComplete) {
            textList = (data as! ZenPuzzleScene).SolvedText
		} else {
            textList = (data as! ZenPuzzleScene).Text
		}
        return (currentTextIndex == -1) || (stickyText && (textList![self.currentTextIndex + 1].textString != ""))
	}
	
	func hasMoreText() -> Bool {
		var textList: [TextLine]?
		if (puzzleComplete) {
            textList = (data as! ZenPuzzleScene).SolvedText
		} else {
            textList = (data as! ZenPuzzleScene).Text
		}
		return textList!.count > self.currentTextIndex + 1
	}
	
	func readyForMoreText(currentTime: TimeInterval, delay: Double) -> Bool {
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		let stickyTextLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
		let popup = self.childNode(withName: "//Popup")
		let descriptionPopup = self.childNode(withName: "//DescriptionPopup")
		return !(textLabel?.hasActions())! && !(stickyTextLabel?.hasActions())! && !(popup?.hasActions())! && !(descriptionPopup?.hasActions())! && !animatingText && !encrypting && currentTime >= (lastAnimationCompleteTime + delay)
	}
	
	func updateCharactersForTextSpeed(currentTime: TimeInterval) {
		let delta = currentTime - lastTextChange
		lastTextChange = currentTime

		let textFadeTime = currentTextSpeed
		var fixedCharacters = 0
		if (newText.count > 0) {
			var fakeIndex = 0
			for index: Int in 0 ... newText.count - 1 {
				let indexFadeStartTime = Double(fakeIndex) * textFadeTime
				if ((delta >= indexFadeStartTime + textFadeTime)) {
					fixedCharacters += 1
				}
				var characterIndex: String.Index = newText.startIndex
				newText.formIndex(&characterIndex, offsetBy: index)
				let character = newText[characterIndex]
				if (character == ",") {
					fakeIndex += 5
				} else {
					fakeIndex += 1
				}
			}

			var characterIndex: String.Index = newText.startIndex
			newText.formIndex(&characterIndex, offsetBy: fixedCharacters - 1)
			let substring = newText[newText.startIndex ... characterIndex]
			fixedText += substring
			newText.removeFirst(fixedCharacters)
		}
	}
	
	func nextText(currentTime: TimeInterval) {
		let seal = self.childNode(withName: "//Seal") as? SKSpriteNode
		seal?.isHidden = true
		
		currentTextIndex += 1
		
		var textList: [TextLine]?
		if (puzzleComplete) {
            textList = (data as! ZenPuzzleScene).SolvedText
		} else {
            textList = (data as! ZenPuzzleScene).Text
		}
		
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		let textCover = self.childNode(withName: "//TextCover") as? SKSpriteNode
		let stickyTextLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
		
		if (textList != nil && textList!.count > self.currentTextIndex && textList![self.currentTextIndex].textString == "") {
			stickyText = !stickyText
			textLabel?.text = ""
			if (stickyText) {
				stickyTextLabel?.text = ""
                if #available(iOS 11.0, *) {
                    stickyTextLabel?.attributedText = NSAttributedString()
                }
				stickyTextLabel?.alpha = 1.0
			}
			stickyTextLabel?.isHidden = !stickyText
			currentTextIndex += 1
			fixedText = ""
			newText = ""
			textCover?.isHidden = true
		} else if (!stickyText) {
			textLabel?.text = ""
			stickyTextLabel?.isHidden = true
			fixedText = ""
		}
		
		let BGMask = self.childNode(withName: "//BGMask") as? SKSpriteNode
		let BGMaskTextCover = self.childNode(withName: "//BGMaskTextCover") as? SKSpriteNode
		if (textList != nil && textList!.count > self.currentTextIndex && textList![self.currentTextIndex].textString == "[enc]") {
			textShowing = true
			encrypting = true
			nextEncAnim = -1.0
			textCover?.isHidden = true
			stickyTextLabel?.isHidden = false
			BGMask!.isHidden = false
			BGMaskTextCover!.isHidden = true
			return
		} else if (textList != nil && textList!.count > self.currentTextIndex && textList![self.currentTextIndex].textString == "[senc]") {
			textShowing = true
			encrypting = true
			stampSeal = true
			nextEncAnim = -1.0
			textCover?.isHidden = true
			stickyTextLabel?.isHidden = false
			BGMask!.isHidden = false
			BGMaskTextCover!.isHidden = true
			return
		}
		
		if (stickyText) {
			fixedText += newText
			newText = ""
			if (fixedText != "") {
				newText += "\n"
			}
			
			let genTextLabel = self.childNode(withName: "//GenTextLabel") as? SKLabelNode
			genTextLabel?.text! = fixedText
			var tempTextIndex = currentTextIndex
			repeat {
				let string = (textList?[tempTextIndex].textString)
				if (string != "[enc]") {
					if (genTextLabel?.text != "" && !(genTextLabel?.text?.hasSuffix("\n"))!) {
						genTextLabel?.text! += "\n"
					}
                    genTextLabel?.text! += gameLogic!.localizedString(forKey: string!, value: nil, table:  self.gameLogic!.getChapterTable())
					if (genTextLabel!.text!.hasSuffix(" (seal).")) {
						genTextLabel!.text! = (genTextLabel?.text!.replacingOccurrences(of: " (seal).", with: "."))!
					} else if (genTextLabel!.text!.hasSuffix(" (sseal).")) {
						genTextLabel!.text! = (genTextLabel?.text!.replacingOccurrences(of: " (sseal).", with: "."))!
					}
				}
				tempTextIndex += 1
			} while(tempTextIndex < textList!.count && textList![tempTextIndex].textString != "")
			
			let differenceInX = stickyTextLabel!.frame.minX - BGMask!.frame.minX
			let height = max(genTextLabel!.frame.height + (2 * differenceInX), (textCover?.frame.height)!)
			BGMask!.isHidden = false
			BGMaskTextCover!.isHidden = true
			BGMask!.size = CGSize(width: BGMask!.size.width, height: height)
			let pos = CGPoint(x: stickyTextLabel!.frame.minX, y: BGMask!.frame.maxY - differenceInX)
			stickyTextLabel!.position = pos
			if (textList != nil && textList!.count > self.currentTextIndex) {
				newText += gameLogic!.localizedString(forKey: (textList![self.currentTextIndex].textString), value: nil, table:  self.gameLogic!.getChapterTable())
				if (newText.hasSuffix(" (seal).")) {
					newText = newText.replacingOccurrences(of: " (seal).", with: ".")
					fadeSeal = true
				}
			}
			textCover?.isHidden = true
			animatingText = true
			lastTextChange = 0.0
		} else {
			if (textList != nil && textList!.count > self.currentTextIndex) {
				textLabel?.text! = gameLogic!.localizedString(forKey: (textList![self.currentTextIndex].textString), value: nil, table:  self.gameLogic!.getChapterTable())
				(textLabel!).alpha = 0.0
				(textLabel!).run(SKAction.fadeIn(withDuration: 1.0))
			}
			textCover?.isHidden = false
			BGMask!.isHidden = true
			BGMaskTextCover!.isHidden = false
			BGMaskTextCover!.size = textCover!.size
			lastTextChange = currentTime
		}
	}
}
