//
//  PuzzleScenes.swift
//  Shared
//
//  Created by A. A. Bills on 28/07/2021.
//

import Foundation
import Flat47Game

open class PuzzleScene: VisualScene {
    public var Text: [TextLine]? = nil
    public var SolvedText: [TextLine]? = nil
    
    enum PuzzleScene: String, CodingKey {
        case Text
        case SolvedText
    }
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: PuzzleScene.self)
        Text = try container.decodeIfPresent([TextLine].self, forKey: PuzzleScene.Text)
        SolvedText = try container.decodeIfPresent([TextLine].self, forKey: PuzzleScene.SolvedText)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: PuzzleScene.self)
        try container.encodeIfPresent(Text, forKey: PuzzleScene.Text)
        try container.encodeIfPresent(SolvedText, forKey: PuzzleScene.SolvedText)
    }
    
    open override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = []
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
                
        if (Text != nil) {
            for textLine in Text! {
                if (textLine.textString.starts(with: "[") || textLine.textString.isEmpty) {
                    lines.append(textLine.textString)
                } else {
                    lines.append(strings[textLine.textString]!)
                }
            }
        }
        
        if (SolvedText != nil) {
            lines.append("// Solved Text")
            
            for textLine in SolvedText! {
                if (textLine.textString.starts(with: "[") || textLine.textString.isEmpty) {
                    lines.append(textLine.textString)
                } else {
                    lines.append(strings[textLine.textString]!)
                }
            }
        }
        
        return lines
    }
}

open class DatePuzzleScene: PuzzleScene {
    public var Question: String = ""
    public var Answer: String = ""
    public var SkipTo: Int = 0
    
    enum DatePuzzleCodingKeys: String, CodingKey {
        case Question
        case Answer
        case SkipTo
    }
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        
        if (scriptParameters["Question"] != nil) {
            Question = scriptParameters["Chapter"]! + "_" + scriptParameters["SceneNumber"]! + "_question"
            strings[Question] = scriptParameters["Question"]
        }
        
        if (scriptParameters["Answer"] != nil) {
            Answer = scriptParameters["Chapter"]! + "_" + scriptParameters["SceneNumber"]! + "_answer"
            strings[Answer] = scriptParameters["Answer"]
        }
        
        if (scriptParameters["SkipTo"] != nil) {
            SkipTo = Int(scriptParameters["SkipTo"]!)!
        }
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: DatePuzzleCodingKeys.self)
        Question = try container.decode(String.self, forKey: DatePuzzleCodingKeys.Question)
        Answer = try container.decode(String.self, forKey: DatePuzzleCodingKeys.Answer)
        SkipTo = try container.decode(Int.self, forKey: DatePuzzleCodingKeys.SkipTo)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: DatePuzzleCodingKeys.self)
        try container.encode(Question, forKey: DatePuzzleCodingKeys.Question)
        try container.encode(Answer, forKey: DatePuzzleCodingKeys.Answer)
        try container.encode(SkipTo, forKey: DatePuzzleCodingKeys.SkipTo)
    }
    
    open override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        if (indexMap[SkipTo] != nil) {
            scriptLine += ", SkipTo: \(indexMap[SkipTo]!)"
        } else {
            scriptLine += ", SkipTo: \(SkipTo)"
        }
        
        return scriptLine
    }
    
    open override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = []
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
        
        lines.append("Question: " + strings[Question]!)
        
        lines.append("Answer: " + strings[Answer]!)
        
        return lines
    }
}

open class ZenPuzzleScene: PuzzleScene {
    public var Question: String? = nil
    public var ZenChoice: Int? = nil
    public var DifficultyLevel: Int? = nil
    public var Animate: Bool? = nil
    
    enum ZenPuzzleCodingKeys: String, CodingKey {
        case Question
        case ZenChoice
        case DifficultyLevel
        case Animate
        case Text
        case SolvedText
    }
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        
        if (scriptParameters["Question"] != nil) {
            Question = scriptParameters["Chapter"]! + "_" + scriptParameters["SceneString"]! + "_question"
            strings[Question!] = scriptParameters["Question"]
        }
        
        if (scriptParameters["ZenChoice"] != nil) {
            ZenChoice = Int(scriptParameters["ZenChoice"]!)
        }
        
        if (scriptParameters["DifficultyLevel"] != nil) {
            DifficultyLevel = Int(scriptParameters["DifficultyLevel"]!)
        }
        
        if (scriptParameters["Animate"] != nil) {
            Animate = (scriptParameters["Animate"] == "True") ? true : false
        }
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ZenPuzzleCodingKeys.self)
        Question = try container.decodeIfPresent(String.self, forKey: ZenPuzzleCodingKeys.Question)
        ZenChoice = try container.decodeIfPresent(Int.self, forKey: ZenPuzzleCodingKeys.ZenChoice)
        DifficultyLevel = try container.decodeIfPresent(Int.self, forKey: ZenPuzzleCodingKeys.DifficultyLevel)
        Animate = try container.decodeIfPresent(Bool.self, forKey: ZenPuzzleCodingKeys.Animate)
    }
    
    open override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ZenPuzzleCodingKeys.self)
        try container.encodeIfPresent(Question, forKey: ZenPuzzleCodingKeys.Question)
        try container.encodeIfPresent(ZenChoice, forKey: ZenPuzzleCodingKeys.ZenChoice)
        try container.encodeIfPresent(DifficultyLevel, forKey: ZenPuzzleCodingKeys.DifficultyLevel)
        try container.encodeIfPresent(Animate, forKey: ZenPuzzleCodingKeys.Animate)
    }
    
    open override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        if (ZenChoice != nil) {
            scriptLine += ", ZenChoice: \(ZenChoice!)"
        }
        
        if (DifficultyLevel != nil) {
            scriptLine += ", DifficultyLevel: \(DifficultyLevel!)"
        }
        
        if (Animate != nil) {
            scriptLine += ", Animate: " + ((Animate! == true) ? "True" : "False")
        }
        
        return scriptLine
    }
    
    open override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = []
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
        
        if (Question != nil) {
            lines.append("Question: " + strings[Question!]!)
        }
        
        return lines
    }
}
