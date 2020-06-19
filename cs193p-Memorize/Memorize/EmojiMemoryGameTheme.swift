//
//  EmojiMemoryGameTheme.swift
//  Memorize
//
//  Created by David Crow on 6/27/20.
//  Copyright © 2020 David Crow. All rights reserved.
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
        EmojiMemoryGameTheme("Halloween", emojis: ["👻", "🎃", "🕷", "🦇", "🦉", "💀", "🧟‍♂️", "🧛‍♂️", "🧙‍♀️", "🕸"],
                             color: UIColor.systemOrange),
        EmojiMemoryGameTheme("Animals", emojis: ["🦓", "🦒", "🦙", "🦛", "🦘", "🦍", "🦆", "🐌", "🐍", "🦎",
                                                 "🦑", "🐬", "🐅", "🦧", "🦌", "🐩", "🐖", "🦩", "🦨", "🦥"],
                             color: UIColor.systemGreen, numberOfPairs: 10),
        EmojiMemoryGameTheme("Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐", "🏓", "🏏", "🏒", "🥍"],
                             color: UIColor.systemRed),
        EmojiMemoryGameTheme("Vehicles", emojis: ["🚙", "🚎", "🚑", "🚚", "🚒", "🚌", "🚓", "🏎", "🚜", "🚕"],
                             color: UIColor.systemBlue, numberOfPairs: 5),
        EmojiMemoryGameTheme("Faces", emojis: ["😊", "😡", "😴", "🤠", "😳", "🤪", "😎", "😍", "😅", "🥳",
                                               "🥺", "😭", "🤗", "🤐", "🥴", "🙄", "🤫", "😰", "🧐", "🙃"],
                             color: UIColor.systemYellow, numberOfPairs: 10),
        EmojiMemoryGameTheme("Fruits", emojis: ["🍇", "🍓", "🥝", "🍍", "🍉", "🍌", "🍊", "🍐", "🍒", "🥭"],
                             color: UIColor.systemPurple),
        EmojiMemoryGameTheme("Suits", emojis: ["♠️", "♣️", "♥️", "♦️"],
                             color: UIColor.systemGray),
    ]
    
    static let template = EmojiMemoryGameTheme("Untitled", emojis: ["😃", "👍🏻", "🌈", "❤️"], color: UIColor.systemTeal)
}
