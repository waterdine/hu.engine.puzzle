//
//  PuzzleScenes.swift
//  Shared
//
//  Created by A. A. Bills on 28/07/2021.
//

import Foundation

class DatePuzzleScene: VisualScene {
    var Question: String = ""
    var Answer: String = ""
    var SkipTo: Int = 0
    var Text: [TextLine] = []
    
    enum DatePuzzleCodingKeys: String, CodingKey {
        case Question
        case Answer
        case SkipTo
        case Text
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
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: DatePuzzleCodingKeys.self)
        Question = try container.decode(String.self, forKey: DatePuzzleCodingKeys.Question)
        Answer = try container.decode(String.self, forKey: DatePuzzleCodingKeys.Answer)
        SkipTo = try container.decode(Int.self, forKey: DatePuzzleCodingKeys.SkipTo)
        Text = try container.decode([TextLine].self, forKey: DatePuzzleCodingKeys.Text)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: DatePuzzleCodingKeys.self)
        try container.encode(Question, forKey: DatePuzzleCodingKeys.Question)
        try container.encode(Answer, forKey: DatePuzzleCodingKeys.Answer)
        try container.encode(SkipTo, forKey: DatePuzzleCodingKeys.SkipTo)
        try container.encode(Text, forKey: DatePuzzleCodingKeys.Text)
    }
    
    override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        if (indexMap[SkipTo] != nil) {
            scriptLine += ", SkipTo: \(indexMap[SkipTo]!)"
        } else {
            scriptLine += ", SkipTo: \(SkipTo)"
        }
        
        return scriptLine
    }
    
    override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = []
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
        
        lines.append("Question: " + strings[Question]!)
        
        lines.append("Answer: " + strings[Answer]!)
        
        for textLine in Text {
            if (textLine.textString.starts(with: "[")) {
                lines.append(textLine.textString)
            } else {
                lines.append(strings[textLine.textString]!)
            }
        }
        
        return lines
    }
}

class ZenPuzzleScene: VisualScene {
    var Question: String? = nil
    var ZenChoice: Int? = nil
    var DifficultyLevel: Int? = nil
    var Animate: Bool? = nil
    var Text: [TextLine]? = nil
    var SolvedText: [TextLine]? = nil
    
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
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ZenPuzzleCodingKeys.self)
        Question = try container.decodeIfPresent(String.self, forKey: ZenPuzzleCodingKeys.Question)
        ZenChoice = try container.decodeIfPresent(Int.self, forKey: ZenPuzzleCodingKeys.ZenChoice)
        DifficultyLevel = try container.decodeIfPresent(Int.self, forKey: ZenPuzzleCodingKeys.DifficultyLevel)
        Animate = try container.decodeIfPresent(Bool.self, forKey: ZenPuzzleCodingKeys.Animate)
        Text = try container.decodeIfPresent([TextLine].self, forKey: ZenPuzzleCodingKeys.Text)
        SolvedText = try container.decodeIfPresent([TextLine].self, forKey: ZenPuzzleCodingKeys.SolvedText)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ZenPuzzleCodingKeys.self)
        try container.encodeIfPresent(Question, forKey: ZenPuzzleCodingKeys.Question)
        try container.encodeIfPresent(ZenChoice, forKey: ZenPuzzleCodingKeys.ZenChoice)
        try container.encodeIfPresent(DifficultyLevel, forKey: ZenPuzzleCodingKeys.DifficultyLevel)
        try container.encodeIfPresent(Animate, forKey: ZenPuzzleCodingKeys.Animate)
        try container.encodeIfPresent(Text, forKey: ZenPuzzleCodingKeys.Text)
        try container.encodeIfPresent(SolvedText, forKey: ZenPuzzleCodingKeys.SolvedText)
    }
    
    override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
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
    
    override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = []
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
        
        if (Question != nil) {
            lines.append("Question: " + strings[Question!]!)
        }
        
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
