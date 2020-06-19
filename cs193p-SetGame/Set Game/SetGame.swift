//
//  SetGame.swift
//  Set Game
//
//  Created by David Crow on 6/3/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

class SetGame: ObservableObject {
    @Published private var model: MatchingGame<Symbol, Shading> = SetGame.createMatchingGame()
    
    private static func createMatchingGame() -> MatchingGame<Symbol, Shading> {
        let cards = SetGame.createDeckOfCards().shuffled()
        return MatchingGame<Symbol, Shading>(numberOfCards: cards.count) { cardIndex in
            cards[cardIndex]
        }
    }
    
    typealias SetCard = (number: Int, color: Color, symbol: Symbol, shading: Shading)
    private static func createDeckOfCards() -> [SetCard] {
        var deckOfCards = [SetCard]()
        for number in [1, 2, 3] {
            for color in [Color.red, Color.green, Color.purple] {
                for symbol in Symbol.allCases {
                    for shading in Shading.allCases {
                        deckOfCards.append((number: number, color: color, symbol: symbol, shading: shading))
                    }
                }
            }
        }
        
        return deckOfCards
    }

    enum Symbol: CaseIterable {
        case diamond, squiggle, oval
    }
    
    enum Shading: CaseIterable {
        case solid, striped, open
    }
    
    // MARK: - Access to the Model
    
    var cards: [MatchingGame<Symbol, Shading>.Card] {
        model.cards
    }
    
    var cardsInPlay: [MatchingGame<Symbol, Shading>.Card] {
        model.cardsInPlay
    }
    
    var numberOfSelectedCards: Int {
        model.numberOfSelectedCards
    }
    
    var deckStillHasCards: Bool {
        model.numberOfCardsInTheDeck > 0
    }
    
    var playerWonTheGame: Bool {
        model.cards.count == model.cards.filter { $0.status == .outOfPlay }.count
    }
    
    func selectedCardsFormAMatch() -> Bool {
        model.selectedCardsFormAMatch()
    }
    
    // MARK: - Intent(s)
    
    func dealCards(count: Int = 12) {
        model.dealCards(count: count)
    }
    
    func choose(_ card: MatchingGame<Symbol, Shading>.Card) {
        model.choose(card)
    }
    
    func resetGame() {
        model = SetGame.createMatchingGame()
        dealCards()
    }
}
