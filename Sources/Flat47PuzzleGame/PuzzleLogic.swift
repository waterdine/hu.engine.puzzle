//
//  PuzzleLogic.swift
//  TheAmericat iOS
//
//  Created by x414e54 on 25/03/2021.
//

import Foundation

import SpriteKit
import Flat47Game

enum EncAnimStage {
	case LiftingUp, FadingOut, Magic, FadingIn, DropingDown, Stamping, Hiding
}

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class PuzzleLogic: GameScene {

	var flowerNode: SKNode?
	var selectedPetalNode: SKLabelNode?
	var puzzleComplete: Bool = false
	
	// Petal shapes/data
	var petalNodes: [SKLabelNode?] = [nil,nil,nil,nil,nil,nil,nil,nil,nil]
	var centerSize: Float = 0.0
	var petalLength: Float = 0.0
	var petalAngles: [Float] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
	var flowerScaleTime: Float = 0.2
	var flowerRotateTime: Float = 0.3
	
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
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		puzzleComplete = false
		
		flowerNode = self.childNode(withName: "//SelectionFlower")
		if (flowerNode != nil) {
			flowerNode?.isHidden = true
					
			centerSize = flowerNode?.userData?.value(forKey: "centerSize") as! Float
			petalLength = flowerNode?.userData?.value(forKey: "petalLength") as! Float
			
			let flowerImage = flowerNode?.childNode(withName: "//Flower") as? SKSpriteNode
			for index in 0 ... 8 {
				petalNodes[index] = flowerImage!.children[index] as? SKLabelNode
				petalAngles[index] = flowerNode?.userData?.value(forKey: petalNameToAngleString(name: (petalNodes[index]?.name)!)) as! Float
			}
			
			let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
			centralFlowerLabel.text = ""
		}
		selectedPetalNode = nil
		
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		textLabel!.text = ""
		let stickyTextLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
		stickyTextLabel!.text = ""
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
		
		if (hasMoreText()) {
			nextText(currentTime: 0.0)
			textShowing = true
		}
	}
	
	override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		if (puzzleComplete || textShowing) {
			if (stickyText) {
				if (animatingText) {
					speedingText = true
				}
			}
			return
		}
	}

	override func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
		if (puzzleComplete) {
			return
		}
		
		if (selectedPetalNode != nil) {
			selectedPetalNode!.fontColor = UIColor.white
			let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
			centralFlowerLabel.text = ""
			selectedPetalNode = nil
		}
	}
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
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
		} else {
			//flowerNode?.isHidden = true
			flowerNode?.run(SKAction.scale(to: 0.0, duration: TimeInterval(flowerScaleTime)))
			flowerNode?.run(SKAction.rotate(toAngle: 0, duration: TimeInterval(flowerRotateTime)))
			if (selectedPetalNode != nil) {
				selectedPetalNode!.fontColor = UIColor.white
				let centralFlowerLabel = self.childNode(withName: "//CentralFlowerLabel") as! SKLabelNode
				centralFlowerLabel.text = ""
			}
		}
		selectedPetalNode = nil
	}
	
	override func update(_ currentTime: TimeInterval) {
		let popupNode = self.childNode(withName: "//Popup")
		if (textShowing) {
			popupNode?.isHidden = false
		} else {
			popupNode?.isHidden = true
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
				let delta = currentTime - nextEncAnim
				let textFadeTime = 1.5
				let deltaFadeTime = delta / textFadeTime
				let fadingCharacterAlpha = deltaFadeTime - Double(Int(deltaFadeTime))
				let totalOffset: CGFloat = 10.0
				switch encAnimStage {
				case .LiftingUp:
					var offset: CGFloat = CGFloat(fadingCharacterAlpha) * totalOffset
					if (deltaFadeTime >= 1) {
						offset = CGFloat(1.0 * totalOffset)
						nextEncAnim = nextEncAnim + 1.5
						encAnimStage = .FadingOut
					}
                    if #available(iOS 11.0, *) {
                        var attributes = stickyTextLabel?.attributedText?.attributes(at: 0, effectiveRange: nil)
                        attributes![.strokeWidth] = -1.0
                        stickyTextShadowLabel?.attributedText = NSAttributedString(string: (stickyTextLabel?.attributedText!.string)!, attributes: attributes)
                    } else {
                        // Fallback on earlier versions
                    }
					stickyTextShadowLabel?.isHidden = false
					stickyTextShadowLabel?.position = cachedPosition
					stickyTextShadowLabel?.alpha = 0.5
					stickyTextLabel?.position = CGPoint(x: cachedPosition.x + offset, y: cachedPosition.y + offset)
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
                        let font = UIFont.init(name: (stickyTextLabel!.fontName!) as String, size: stickyTextLabel!.fontSize / 1.5)
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
                        } else {
                            // Fallback on earlier versions
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
                        } else {
                            // Fallback on earlier versions
                        }
						stickyTextShadowLabel?.isHidden = false
						stickyTextShadowLabel?.position = cachedPosition
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
	
	func toRad(value: CGFloat) -> CGFloat {
		return CGFloat((Double(value) / 180.0) * Double.pi)
	}
	
	func toDegrees(value: CGFloat) -> CGFloat {
		return value * CGFloat((180.0 / Double.pi))
	}
	
	func calculateRotation(startingPoint: CGPoint, currentPoint: CGPoint) -> CGFloat {
		let dY: CGFloat = currentPoint.y - startingPoint.y
		let dX: CGFloat = currentPoint.x - startingPoint.x
		let angleFromStart: CGFloat = atan2(dY, dX) * CGFloat((180.0 / Double.pi))
		return angleFromStart
	}

	func distance(startingPoint: CGPoint, endingPoint: CGPoint) -> CGFloat {
		let xDistance: Float = Float(startingPoint.x - endingPoint.x)
		let yDistance: Float = Float(startingPoint.y - endingPoint.y)
		let distance: Float = sqrtf(xDistance * xDistance + yDistance * yDistance)
		return CGFloat(distance)
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

	func checkPuzleCompleted(currentTime: TimeInterval) {
	}
	
	func canAutoProgress() -> Bool {
		if (!hasMoreText()) {
			return true
		}
		
		let textList = getTextList()
		return (currentTextIndex == -1) || (stickyText && (textList[self.currentTextIndex + 1] != ""))
	}
	
	func hasMoreText() -> Bool {
		let textList = getTextList()
		return textList.count > self.currentTextIndex + 1
	}
	
	func readyForMoreText(currentTime: TimeInterval, delay: Double) -> Bool {
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		let stickyTextLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
		let popup = self.childNode(withName: "//Popup")
		return !(textLabel?.hasActions())! && !(stickyTextLabel?.hasActions())! && !(popup != nil && popup!.hasActions()) && !animatingText && !encrypting && currentTime >= (lastAnimationCompleteTime + delay)
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
		
		let textList = getTextList()
		
		let textLabel = self.childNode(withName: "//TextLabel") as? SKLabelNode
		let textCover = self.childNode(withName: "//TextCover") as? SKSpriteNode
		let stickyTextLabel = self.childNode(withName: "//StickyTextLabel") as? SKLabelNode
		
		if (textList.count > self.currentTextIndex && textList[self.currentTextIndex] == "") {
			stickyText = !stickyText
			textLabel?.text = ""
			if (stickyText) {
				stickyTextLabel?.text = ""
                if #available(iOS 11.0, *) {
                    stickyTextLabel?.attributedText = NSAttributedString()
                } else {
                    // Fallback on earlier versions
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
		
		if (textList.count > self.currentTextIndex && textList[self.currentTextIndex] == "[enc]") {
			textShowing = true
			encrypting = true
			nextEncAnim = -1.0
			textCover?.isHidden = true
			stickyTextLabel?.isHidden = false
			return
		} else if (textList.count > self.currentTextIndex && textList[self.currentTextIndex] == "[senc]") {
			textShowing = true
			encrypting = true
			stampSeal = true
			nextEncAnim = -1.0
			textCover?.isHidden = true
			stickyTextLabel?.isHidden = false
			return
		}
		
		let BGMask = self.childNode(withName: "//BGMask") as? SKSpriteNode
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
				let string = textList[tempTextIndex]
				if (string != "[enc]") {
					if (genTextLabel?.text != "" && !(genTextLabel?.text?.hasSuffix("\n"))!) {
						genTextLabel?.text! += "\n"
					}
					genTextLabel?.text! += Bundle.main.localizedString(forKey: string, value: nil, table: self.gameLogic!.getChapterTable())
					if (genTextLabel!.text!.hasSuffix(" (seal).")) {
						genTextLabel!.text! = (genTextLabel?.text!.replacingOccurrences(of: " (seal).", with: "."))!
					} else if (genTextLabel!.text!.hasSuffix(" (sseal).")) {
						genTextLabel!.text! = (genTextLabel?.text!.replacingOccurrences(of: " (sseal).", with: "."))!
					}
				}
				tempTextIndex += 1
			} while(tempTextIndex < textList.count && textList[tempTextIndex] != "")
			
			let differenceInX = stickyTextLabel!.frame.minX - BGMask!.frame.minX
			BGMask!.size = CGSize(width: BGMask!.size.width, height: genTextLabel!.frame.height + differenceInX + (differenceInX / 2.0))
			let pos = CGPoint(x: stickyTextLabel!.frame.minX, y: BGMask!.frame.maxY - differenceInX)
			stickyTextLabel!.position = pos
			if (textList.count > self.currentTextIndex) {
				newText += Bundle.main.localizedString(forKey: textList[self.currentTextIndex], value: nil, table: self.gameLogic!.getChapterTable())
				if (newText.hasSuffix(" (seal).")) {
					newText = newText.replacingOccurrences(of: " (seal).", with: ".")
					fadeSeal = true
				}
			}
			textCover?.isHidden = true
			animatingText = true
			lastTextChange = 0.0
		} else {
			if (textList.count > self.currentTextIndex) {
				textLabel?.text! = Bundle.main.localizedString(forKey: textList[self.currentTextIndex], value: nil, table: self.gameLogic!.getChapterTable())
				(textLabel!).alpha = 0.0
				(textLabel!).run(SKAction.fadeIn(withDuration: 1.0))
			}
			if (textCover != nil) {
				textCover?.isHidden = false
				BGMask!.size = textCover!.size
			}
			lastTextChange = currentTime
		}
	}
	
	func getTextList() -> [String] {
		var textList: [String]? = nil
		if (puzzleComplete) {
			textList = self.data?["SolvedText"] as? [String]
		} else {
			textList = self.data?["Text"] as? [String]
		}
		return textList!
	}
}
