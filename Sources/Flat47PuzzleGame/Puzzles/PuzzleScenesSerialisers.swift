//
//  File.swift
//
//
//  Created by Sen on 05/01/2022.
//

import Foundation
import Flat47Game

class PuzzleGameSceneSerialiser: BaseSceneSerialiser {
    public override init() {
        super.init()
    }
    
    open override func create(from scriptParameters: [String : String], strings: inout [String : String]) -> BaseScene? {
        return nil
    }

    open override func decode(from scriptParameters: [String : String], strings: inout [String : String]) throws {
    }

    open override func decode(from decoder: Decoder, scene: BaseScene) throws {
    }

    open override func encode(to encoder: Encoder, scene: BaseScene) throws {
        switch scene.Scene {
        case "DatePuzzle":
            try (scene as! DatePuzzleScene).encode(to: encoder)
            break
        case "ZenPuzzle":
            try (scene as! ZenPuzzleScene).encode(to: encoder)
            break
        default:
            break
        }
    }

    open override func update(scene: BaseScene) -> BaseScene? {
        var newData: BaseScene? = nil
        switch scene.Scene {
        case "DatePuzzle":
            if (!(scene is DatePuzzleScene)) {
                newData = DatePuzzleScene()
            }
            break
        case "ZenPuzzle":
            if (!(scene is ZenPuzzleScene)) {
                newData = ZenPuzzleScene()
            }
            break
        default:
            break
        }
        return newData
    }
        
    open override func getDescription(scene: BaseScene) -> String {
        switch scene.Scene {
            case "DatePuzzle":
                return (scene as! DatePuzzleScene).getDescription()
            case "ZenPuzzle":
                return (scene as! ZenPuzzleScene).getDescription()
            default:
                return ""
        }
    }

    open override func toStringsHeader(scene: BaseScene, index: Int, strings: [String : String]) -> String {
        return ""
    }

    open override func toScriptHeader(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return ""
    }

    open override func toStringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        return []
    }

    open override func toScriptLines(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        return []
    }
}
