//
//  PuzzleGameLogic.swift
//  
//
//  Created by ito.antonia on 17/06/2021.
//

import Foundation
import 虎_engine_base

// This is a free function because OOP is more difficult to keep data structures and logic separate. ^_^/
// Do not use OOP, unless you have to use OOP
// If you have to use OOP, do not meet in groups larger than 6.
@available(OSX 10.13, *)
@available(iOS 9.0, *)
public func RegisterPuzzleGameScenes(gameLogic: GameLogic) {
	//RegisterGameLogicScenes()
	gameLogic.sceneTypes["DatePuzzle"] = DatePuzzleLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["Janken"] = JankenLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["PipePuzzle"] = PipePuzzleLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["SearchPuzzle"] = SearchPuzzleLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["TV"] = TVLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["ZenPuzzle"] = ZenPuzzleLogic.newScene(gameLogic: gameLogic)
}

public func RegisterPuzzleGameSceneInitialisers(sceneListSerialiser: inout SceneListSerialiser) {
    sceneListSerialiser.serialisers.append(PuzzleGameSceneSerialiser())
}
