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
    private(set) var theme: EmojiMemoryGameTheme
    
    init(theme: EmojiMemoryGameTheme? = nil) {
        self.theme = theme ?? EmojiMemoryGameTheme.themes.randomElement()!
        model = EmojiMemoryGame.createMemoryGame(theme: theme!)
    }
    
    private static func createMemoryGame(theme: EmojiMemoryGameTheme) -> MemoryGame<String> {
        MemoryGame<String>(numberOfPairs: theme.numberOfPairs) { pairIndex in
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
        theme.emojis.shuffle()
        model = EmojiMemoryGame.createMemoryGame(theme: theme)
    }
}
