//
//  EmojiMemoryGameTheme.swift
//  Memorize
//
//  Created by David Crow on 6/27/20.
//  Copyright Β© 2020 David Crow. All rights reserved.
//

import SwiftUI

struct EmojiMemoryGameTheme: Identifiable, Codable {
    var name: String
    var emojis: [String]
    var removedEmojis: [String]
    var colorRGB: UIColor.RGB
    var numberOfPairs: Int

    var id: UUID
    
    var color: Color {
        Color(colorRGB)
    }

    var json: Data? {
        try? JSONEncoder().encode(self)
    }
    
    init(_ name: String, emojis: [String], color: UIColor, numberOfPairs: Int? = nil, id: UUID? = nil) {
        self.name = name
        self.emojis = emojis
        self.removedEmojis = []
        self.colorRGB = color.rgb
        self.numberOfPairs = numberOfPairs ?? emojis.count
        self.id = id ?? UUID()
    }
    
    init?(json: Data?) {
        if let json = json, let newTheme = try? JSONDecoder().decode(EmojiMemoryGameTheme.self, from: json) {
            self = newTheme
        } else {
            return nil
        }
    }
    
    static var themes = [
        EmojiMemoryGameTheme("Halloween", emojis: ["π»", "π", "π·", "π¦", "π¦", "π", "π§ββοΈ", "π§ββοΈ", "π§ββοΈ", "πΈ"],
                             color: UIColor.systemOrange),
        EmojiMemoryGameTheme("Animals", emojis: ["π¦", "π¦", "π¦", "π¦", "π¦", "π¦", "π¦", "π", "π", "π¦",
                                                 "π¦", "π¬", "π", "π¦§", "π¦", "π©", "π", "π¦©", "π¦¨", "π¦₯"],
                             color: UIColor.systemGreen, numberOfPairs: 10),
        EmojiMemoryGameTheme("Sports", emojis: ["β½οΈ", "π", "π", "βΎοΈ", "πΎ", "π", "π", "π", "π", "π₯"],
                             color: UIColor.systemRed),
        EmojiMemoryGameTheme("Vehicles", emojis: ["π", "π", "π", "π", "π", "π", "π", "π", "π", "π"],
                             color: UIColor.systemBlue, numberOfPairs: 5),
        EmojiMemoryGameTheme("Faces", emojis: ["π", "π‘", "π΄", "π€ ", "π³", "π€ͺ", "π", "π", "π", "π₯³",
                                               "π₯Ί", "π­", "π€", "π€", "π₯΄", "π", "π€«", "π°", "π§", "π"],
                             color: UIColor.systemYellow, numberOfPairs: 10),
        EmojiMemoryGameTheme("Fruits", emojis: ["π", "π", "π₯", "π", "π", "π", "π", "π", "π", "π₯­"],
                             color: UIColor.systemPurple),
        EmojiMemoryGameTheme("Suits", emojis: ["β οΈ", "β£οΈ", "β₯οΈ", "β¦οΈ"],
                             color: UIColor.systemGray),
    ]
    
    static let template = EmojiMemoryGameTheme("Untitled", emojis: ["π", "ππ»", "π", "β€οΈ"], color: UIColor.systemTeal)
}
