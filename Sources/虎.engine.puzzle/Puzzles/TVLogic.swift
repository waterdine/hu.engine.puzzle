//
//  TVLogic.swift
//  TheAmericat iOS
//
//  Created by ito.antonia on 25/03/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class TVLogic: PuzzleLogic {
	
	var channelUpButton: SKNode? = nil
	var channelDownButton: SKNode? = nil
	var offButton: SKNode? = nil
	var speechArea: SKNode? = nil
	var speaker: SKLabelNode? = nil
	
	var channelIndex: Int = 1
	
	class func newScene(gameLogic: GameLogic) -> TVLogic {
        guard let scene = gameLogic.loadScene(scene: "Default.TV", classType: TVLogic.classForKeyedUnarchiver()) as? TVLogic else {
            print("Failed to load TV.sks")
            return TVLogic()
        }

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
	
	override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		//super.touchesBegan(touches, with: event)
	}
		
	override func interactionMoved(_ point: CGPoint, timestamp: TimeInterval) {
		//super.touchesMoved(touches, with: event)
	}

	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		//super.touchesEnded(touches, with: event)

		if (channelUpButton!.frame.contains(point)) {
			channelIndex += 1
			if (channelIndex > 99) {
				channelIndex = 99
			}
			updateChannel(currentTime: timestamp)
		} else if (channelDownButton!.frame.contains(point)) {
			channelIndex -= 1
			if (channelIndex < 1) {
				channelIndex = 1
			}
			updateChannel(currentTime: timestamp)
		} else if (offButton!.frame.contains(point)) {
			self.gameLogic?.nextScene()
		} else if (hasMoreText()) {
			if (readyForMoreText(currentTime: timestamp, delay: self.gameLogic!.actionDelay)) {
				nextText(currentTime: timestamp)
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
        let tunedChannels = (self.data as! TVScene).TunedChannels!
		var textIndex = tunedChannels.firstIndex(of: channelIndex)
		if (textIndex == nil || textIndex! < 0) {
			textIndex = 0
		} else {
			textIndex! += 1
		}
        let channels = (self.data as! TVScene).Channels
        textList = channels![textIndex!].Text
		return textList!
	}
}
