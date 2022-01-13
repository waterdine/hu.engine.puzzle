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
    
    open override func decode(from scriptParameters: [String : String], sceneType: String, strings: inout [String : String]) -> BaseScene? {
        var scene: BaseScene? = nil
        switch sceneType {
            case "DatePuzzle":
                scene = DatePuzzleScene.init(from: scriptParameters, strings: &strings)
                break
            case "ZenPuzzle":
                scene = ZenPuzzleScene.init(from: scriptParameters, strings: &strings)
                break
            case "Janken":
                scene = JankenScene.init(from: scriptParameters, strings: &strings)
                break
            case "TV":
                scene = TVScene.init(from: scriptParameters, strings: &strings)
                break
            default:
                break
        }
        return scene
    }
    
    open override func decode(from decoder: Decoder, sceneType: String) throws -> BaseScene? {
        var scene: BaseScene? = nil
        switch sceneType {
        case "DatePuzzle":
            scene = try DatePuzzleScene.init(from: decoder)
            break
        case "ZenPuzzle":
            scene = try ZenPuzzleScene.init(from: decoder)
            break
        case "Janken":
            scene = try JankenScene.init(from: decoder)
            break
        case "TV":
            scene = try TVScene.init(from: decoder)
            break
        default:
            break
        }
        return scene
    }

    open override func encode(to encoder: Encoder, scene: BaseScene) throws {
        switch scene.Scene {
        case "DatePuzzle":
            try (scene as! DatePuzzleScene).encode(to: encoder)
            break
        case "ZenPuzzle":
            try (scene as! ZenPuzzleScene).encode(to: encoder)
            break
        case "Janken":
            try (scene as! JankenScene).encode(to: encoder)
            break
        case "TV":
            try (scene as! TVScene).encode(to: encoder)
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
        case "Janken":
            if (!(scene is JankenScene)) {
                newData = JankenScene()
            }
            break
        case "TV":
            if (!(scene is TVScene)) {
                newData = TVScene()
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
            case "Janken":
                return (scene as! JankenScene).getDescription()
            case "TV":
                return (scene as! TVScene).getDescription()
            default:
                return ""
        }
    }
    
    open override func appendText(scene: BaseScene, text: String, textBucket: String, chapterNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
        let line: TextLine = TextLine()
        line.textString = text
        if (textBucket.isEmpty) {
            let lineString = "line_\(lineIndex)"
            let lineReference = chapterNumber + "_" + sceneNumber + "_" + lineString
            switch scene.Scene {
            case "ZenPuzzle":
                if (text.starts(with: "Question")) {
                    (scene as! ZenPuzzleScene).Question = chapterNumber + "_" + sceneNumber + "_question"
                    strings[(scene as! ZenPuzzleScene).Question!] = text.replacingOccurrences(of: "Question: ", with: "")
                } else {
                    if (!command) {
                        strings[lineReference] = String(text)
                        line.textString = lineReference
                    }
                    if ((scene as! ZenPuzzleScene).Text == nil) {
                        (scene as! ZenPuzzleScene).Text = []
                    }
                    (scene as! ZenPuzzleScene).Text!.append(line)
                }
                break
            case "DatePuzzle":
                if (text.starts(with: "Question")) {
                    (scene as! DatePuzzleScene).Question = chapterNumber + "_" + sceneNumber + "_question"
                    strings[(scene as! DatePuzzleScene).Question] = text.replacingOccurrences(of: "Question: ", with: "")
                } else if (text.starts(with: "Answer")) {
                    (scene as! DatePuzzleScene).Answer = chapterNumber + "_" + sceneNumber + "_answer"
                    strings[(scene as! DatePuzzleScene).Answer] = text.replacingOccurrences(of: "Answer: ", with: "")
                } else {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                    if ((scene as! DatePuzzleScene).Text != nil) {
                        (scene as! DatePuzzleScene).Text!.append(line)
                    }
                }
                break
            default:
                break
            }
        } else if (textBucket == "Solved") {
            let lineString = "solved_line_\(lineIndex)"
            let lineReference = chapterNumber + "_" + sceneNumber + "_" + lineString
            switch scene.Scene {
            case "ZenPuzzle":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                if ((scene as! ZenPuzzleScene).SolvedText == nil) {
                    (scene as! ZenPuzzleScene).SolvedText = []
                }
                (scene as! ZenPuzzleScene).SolvedText!.append(line)
                break
            default:
                break
            }
        }
    }
    
    open override func stringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        var lines: [String] = []
        switch scene.Scene {
            case "DatePuzzle":
                lines.append(contentsOf: (scene as! DatePuzzleScene).toStringsLines(index: index, strings: strings))
                for textLine in (scene as! DatePuzzleScene).Text ?? [] {
                    if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                        lines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                    }
                }
                lines.append("\"" + (scene as! DatePuzzleScene).Question + "\" = \"" + strings[(scene as! DatePuzzleScene).Question]! + "\";")
                lines.append("\"" + (scene as! DatePuzzleScene).Answer + "\" = \"" + strings[(scene as! DatePuzzleScene).Answer]! + "\";")
                break
            case "ZenPuzzle":
                lines.append(contentsOf: (scene as! ZenPuzzleScene).toStringsLines(index: index, strings: strings))
                if ((scene as! ZenPuzzleScene).Text != nil) {
                    for textLine in (scene as! ZenPuzzleScene).Text! {
                        if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                            lines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                        }
                    }
                }
                if ((scene as! ZenPuzzleScene).SolvedText != nil) {
                    lines.append("// Solved Text")
                    for textLine in (scene as! ZenPuzzleScene).SolvedText! {
                        if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                            lines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                        }
                    }
                }
                break
            default:
                break
        }
        return lines
    }
    
    open override func resolveSkipToIndexes(scene: BaseScene, indexMap: [Int : Int]) {
        switch scene.Scene {
        case "DatePuzzle":
            if (indexMap[(scene as! DatePuzzleScene).SkipTo] != nil) {
                (scene as! DatePuzzleScene).SkipTo = indexMap[(scene as! DatePuzzleScene).SkipTo]!
            }
            break
        default:
            break
        }
    }
}
