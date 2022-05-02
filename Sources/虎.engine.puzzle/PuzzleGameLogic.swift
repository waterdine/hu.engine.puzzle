//
//  PuzzleGameLogic.swift
//  
//
//  Created by ito.antonia on 17/06/2021.
//

import Foundation
import 虎_engine_base

// This is a free function because OOP is more difficult to keep data structures and logic separate, for GPU like kernels. ^_^/
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

public func LoadPuzzleGameModuleResourceBundle(bundles: inout [String:Bundle]) {
    bundles["虎.engine.puzzle"] = Bundle.init(url: Bundle.main.resourceURL!.appendingPathComponent("虎.engine.puzzle_虎.engine.puzzle.bundle"))!
}

public func RegisterPuzzleGameSettings(settings: inout [String])
{
    settings.append("EncodeFontScale");
}
