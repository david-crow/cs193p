//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by David Crow on 5/24/20.
//  Copyright © 2020 David Crow. All rights reserved.
//
 
import SwiftUI

class EmojiMemoryGame: ObservableObject {
    @Published private var model: MemoryGame<String>
    
    private(set) var currentTheme: EmojiTheme
    
    static let emojiThemes = [
        EmojiTheme("Halloween", emojis: ["👻", "🎃", "🕷", "🦇", "🦉", "💀", "🧟‍♂️", "🧛‍♂️", "🧙‍♀️"], color: UIColor.orange),
        EmojiTheme("Animals", emojis: ["🦓", "🦒", "🦙", "🦛", "🦘", "🦍"], color: UIColor.green),
        EmojiTheme("Sports", emojis: ["⚽️", "🏀", "🏈", "⚾️", "🎾", "🏐"], color: UIColor.red),
        EmojiTheme("Vehicles", emojis: ["🚙", "🚎", "🚑", "🚚", "🚒", "🚌"], color: UIColor.blue),
        EmojiTheme("Faces", emojis: ["😊", "😡", "😴", "🤠", "😳", "🤪", "😎", "😍"], color: UIColor.yellow),
        EmojiTheme("Fruits", emojis: ["🍇", "🍓", "🥝", "🍍", "🍉", "🍌"], color: UIColor.purple),
    ]
    
    struct EmojiTheme: Codable {
        init(_ name: String, emojis: [String], color: UIColor) {
            self.name = name
            self.emojis = emojis.shuffled()
            self.color = color.rgb
        }
        
        let name: String
        let emojis: [String]
        let color: UIColor.RGB
        var numberOfPairsOfCards: Int {
            emojis.count
        }
        var json: Data? {
            try? JSONEncoder().encode(self)
        }
    }
    
    init() {
        currentTheme = EmojiMemoryGame.emojiThemes.randomElement()!
        model = EmojiMemoryGame.createMemoryGame(theme: currentTheme)
    }
    
    private static func createMemoryGame(theme: EmojiTheme) -> MemoryGame<String> {
        print("json = \(theme.json?.utf8 ?? "nil")")
        return MemoryGame<String>(numberOfPairsOfCards: theme.numberOfPairsOfCards) { pairIndex in
            theme.emojis[pairIndex]
        }
    }
    
    // MARK: - Access to the Model
    
    var cards: [MemoryGame<String>.Card] {
        model.cards
    }
    
    var score: Int {
        model.score
    }
    
    // MARK: - Intent(s)
    
    func choose(_ card: MemoryGame<String>.Card) {
        model.choose(card)
    }
    
    func resetGame() {
        currentTheme = EmojiMemoryGame.emojiThemes.randomElement()!
        model = EmojiMemoryGame.createMemoryGame(theme: currentTheme)
    }
}
