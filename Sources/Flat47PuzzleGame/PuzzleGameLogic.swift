//
//  PuzzleGameLogic.swift
//  
//
//  Created by x414e54 on 17/06/2021.
//

import Foundation
import Flat47Game

// This is a free function because OOP sucks monkey ass and I am not perpetuating that BS any longer ^_^/
@available(OSX 10.13, *)
@available(iOS 11.0, *)
public func RegisterPuzzleGameScenes(gameLogic: GameLogic) {
	//RegisterGameLogicScenes()
	gameLogic.sceneTypes["DatePuzzle"] = DatePuzzleLogic.newScene(gameLogic: gameLogic)
	//gameLogic.sceneTypes["Janken"] = JankenLogic.newScene(gameLogic: gameLogic)
	//gameLogic.sceneTypes["PipePuzzle"] = PipePuzzleLogic.newScene(gameLogic: gameLogic)
	//gameLogic.sceneTypes["SearchPuzzle"] = SearchPuzzleLogic.newScene(gameLogic: gameLogic)
	//gameLogic.sceneTypes["TV"] = TVLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["ZenPuzzle"] = ZenPuzzleLogic.newScene(gameLogic: gameLogic)
}
