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
    
    open override func appendText(scene: BaseScene, text: String, textBucket: String, chapterNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
        let line: TextLine = TextLine()
        line.textString = text
        if (textBucket.isEmpty) {
            let lineString = "line_\(lineIndex)"
            let lineReference = chapterNumber + "_" + sceneNumber + "_" + lineString
            switch scene.Scene {
            case "Story":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                (scene as! StoryScene).Text.append(line)
                break
            case "CutScene":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                (scene as! CutSceneScene).Text.append(line)
                break
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
                    (scene as! DatePuzzleScene).Text.append(line)
                }
                break
            case "Choice":
                if (text.starts(with: "DirectingText")) {
                    (scene as! ChoiceScene).DirectingText = chapterNumber + "_" + sceneNumber + "_direction"
                    strings[(scene as! ChoiceScene).DirectingText] = text.replacingOccurrences(of: "DirectingText: ", with: "")
                } else if (text.starts(with: "Choice")) {
                    let choiceSplit = text.replacingOccurrences(of: "//", with: "±").split(separator: "±")
                    let choiceTextSplit = choiceSplit[0].split(separator: ":")
                    let choiceNumber: String = String(choiceTextSplit[0]).replacingOccurrences(of: "Text", with: "").replacingOccurrences(of: "Choice", with: "").trimmingCharacters(in: [" ", "-", ",", ":", "/"])
                    let choiceText: String = String(choiceTextSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":", "/"])
                    var choiceParameters: [String : String] = ["Text" : choiceText]
                    choiceParameters["Choice"] = choiceNumber
                    if (choiceSplit.count > 1) {
                        let choiceParameterSplit = choiceSplit[1].split(separator: ",")
                        for parameterCombined in choiceParameterSplit {
                            if (!parameterCombined.starts(with: "Choice")) {
                                let parameterSplit = parameterCombined.split(separator: ":")
                                let parameter = String(parameterSplit[0]).trimmingCharacters(in: [" ", "-", ",", ":"])
                                let value = String(parameterSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":"])
                                choiceParameters[parameter] = value
                            }
                        }
                    }
                    
                    // Map the SkipTos to SceneLabels
                    if (choiceParameters["SkipTo"] != nil) {
                        var newSkipTo = ""
                        for skipToUntrimmed in choiceParameters["SkipTo"]!.split(separator: ";") {
                            let skipToTrimmed = skipToUntrimmed.trimmingCharacters(in: [" ", ",", ";"])
                            var skipToNumber = Int(skipToTrimmed)
                            if (skipToNumber == nil) {
                                if (sceneLabelMap[skipToTrimmed] == nil) {
                                    let newIndex = -(sceneLabelMap.count + 1)
                                    sceneLabelMap[skipToTrimmed] = newIndex
                                    skipToNumber = newIndex
                                } else {
                                    skipToNumber = sceneLabelMap[skipToTrimmed]!
                                }
                            }
                            
                            if (!newSkipTo.isEmpty) {
                                newSkipTo += ";"
                            }
                            
                            newSkipTo += "\(skipToNumber!)"
                        }
                        choiceParameters["SkipTo"] = newSkipTo
                    }
                    
                    choiceParameters["Chapter"] = chapterNumber
                    choiceParameters["SceneNumber"] = sceneNumber
                    let choice = Choice.init(from: choiceParameters, strings: &strings)
                    let choiceIndex = Int(choiceNumber)!
                    // atode: Check choiceIndex > 0 and handle it otherwise
                    if ((scene as! ChoiceScene).Choices == nil) {
                        (scene as! ChoiceScene).Choices = []
                    }
                    
                    for _ in (scene as! ChoiceScene).Choices!.count..<choiceIndex {
                        (scene as! ChoiceScene).Choices!.append(Choice())
                    }
                    (scene as! ChoiceScene).Choices?[choiceIndex - 1] = choice
                }
            case "ChapterTransition":
                if (text.starts(with: "HorizontalNumber")) {
                    (scene as! ChapterTransitionScene).HorizontalNumber = chapterNumber + "_horizontal_number"
                    strings[(scene as! ChapterTransitionScene).HorizontalNumber] = text.replacingOccurrences(of: "HorizontalNumber: ", with: "")
                } else if (text.starts(with: "HorizontalTitle")) {
                    (scene as! ChapterTransitionScene).HorizontalTitle = chapterNumber + "_horizontal_title"
                    strings[(scene as! ChapterTransitionScene).HorizontalTitle] = text.replacingOccurrences(of: "HorizontalTitle: ", with: "")
                } else if (text.starts(with: "VerticalNumber")) {
                    (scene as! ChapterTransitionScene).VerticalNumber = chapterNumber + "_vertical_number"
                    strings[(scene as! ChapterTransitionScene).VerticalNumber] = text.replacingOccurrences(of: "VerticalNumber: ", with: "")
                } else if (text.starts(with: "VerticalTitle")) {
                    (scene as! ChapterTransitionScene).VerticalTitle = chapterNumber + "_vertical_title"
                    strings[(scene as! ChapterTransitionScene).VerticalTitle] = text.replacingOccurrences(of: "VerticalTitle: ", with: "")
                }
            default: break
            }
        //} else if (textBucket == "Solved") {
        //    let lineString = "solved_line_\(lineIndex)"
        //    let lineReference = chapter + "_" + scene + "_" + lineString
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
            default: break
            }
    }
    
    open override func stringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        var lines: [String] = []
        switch scene.Scene {
            case "DatePuzzle":
                lines.append(contentsOf: (scene as! DatePuzzleScene).toStringsLines(index: index, strings: strings))
                for textLine in (scene as! DatePuzzleScene).Text {
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
        default: break
        }
    }
}
