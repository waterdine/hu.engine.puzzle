//
//  TVLogic.swift
//  TheAmericat iOS
//
//  Created by x414e54 on 25/03/2021.
//

import SpriteKit
import Flat47Game

@available(iOS 11.0, *)
class TVLogic: PuzzleLogic {
	
	var channelUpButton: SKNode? = nil
	var channelDownButton: SKNode? = nil
	var offButton: SKNode? = nil
	var speechArea: SKNode? = nil
	var speaker: SKLabelNode? = nil
	
	var channelIndex: Int = 1
	
	class func newScene(gameLogic: GameLogic) -> TVLogic {
		guard let scene = TVLogic(fileNamed: "TV" + gameLogic.getAspectSuffix()) else {
			print("Failed to load TV.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic
		scene.puzzleComplete = false
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		
		channelUpButton = self.childNode(withName: "ChannelUpButton")
		channelDownButton = self.childNode(withName: "ChannelDownButton")
		offButton = self.childNode(withName: "OffButton")
		speechArea = self.childNode(withName: "Speech")
		speaker = speechArea!.childNode(withName: "Speaker") as? SKLabelNode
		updateChannel(currentTime: 0.0)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		//super.touchesBegan(touches, with: event)
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		//super.touchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		//super.touchesEnded(touches, with: event)

		let point: CGPoint = (touches.first?.location(in: self))!
		if (channelUpButton!.frame.contains(point)) {
			channelIndex += 1
			if (channelIndex > 99) {
				channelIndex = 99
			}
			updateChannel(currentTime: event!.timestamp)
		} else if (channelDownButton!.frame.contains(point)) {
			channelIndex -= 1
			if (channelIndex < 1) {
				channelIndex = 1
			}
			updateChannel(currentTime: event!.timestamp)
		} else if (offButton!.frame.contains(point)) {
			self.gameLogic?.nextScene()
		} else if (hasMoreText()) {
			if (readyForMoreText(currentTime: event!.timestamp, delay: self.gameLogic!.actionDelay)) {
				nextText(currentTime: event!.timestamp)
			}
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		super.update(currentTime)
	}
	
	override func checkPuzleCompleted(currentTime: TimeInterval) {
		super.checkPuzleCompleted(currentTime: currentTime)
	}
	
	func updateChannel(currentTime: TimeInterval) {
		currentTextIndex = -1
		speaker?.text = String.init(format: "Channel %d", channelIndex)
		if (hasMoreText()) {
			nextText(currentTime: currentTime)
		}
	}
	
	override func getTextList() -> [String] {
		var textList: [String]? = nil
		let tunedChannels = self.data?["TunedChannels"] as! [Int]
		var textIndex = tunedChannels.firstIndex(of: channelIndex)
		if (textIndex == nil || textIndex! < 0) {
			textIndex = 0
		} else {
			textIndex! += 1
		}
		let channels = self.data?["Channels"] as! [NSDictionary]
		textList = channels[textIndex!]["Text"] as? [String]
		return textList!
	}
}
