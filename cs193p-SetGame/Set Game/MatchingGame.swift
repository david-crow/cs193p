//
//  MatchingGame.swift
//  Set Game
//
//  Created by David Crow on 6/3/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct MatchingGame<CardSymbol: Equatable, CardShading: Equatable> {
    private(set) var cards: [Card]
    
    private(set) var indicesOfTheCardsInPlay: [Int]
    
    private var indicesOfTheSelectedCards: [Int] {
        cards.indices.filter { cards[$0].isSelected && cards[$0].status == .inPlay }
    }
    
    var cardsInPlay: [Card] {
        var cardsInPlay = [Card]()
        for cardIndex in indicesOfTheCardsInPlay {
            cardsInPlay.append(cards[cardIndex])
        }
        return cardsInPlay
    }
    
    var numberOfCardsInTheDeck: Int {
        cards.filter { $0.status == .inDeck }.count
    }
    
    var numberOfSelectedCards: Int {
        indicesOfTheSelectedCards.count
    }
    
    init(numberOfCards: Int, cardContentFactory: (Int) -> (number: Int, color: Color, symbol: CardSymbol, shading: CardShading)) {
        cards = [Card]()
        indicesOfTheCardsInPlay = [Int]()
        for cardIndex in 0..<numberOfCards {
            let content = cardContentFactory(cardIndex)
            let cardContent = Card.CardContent(number: content.number, color: content.color, symbol: content.symbol, shading: content.shading)
            cards.append(Card(content: cardContent, id: cardIndex))
        }
    }
    
    mutating func dealCards(count: Int = 12) {
        if let randomDeckIndices = selectRandomCardsFromTheDeck(count: count) {
            for cardIndex in randomDeckIndices {
                cards[cardIndex].status = .inPlay
            }
            
            if selectedCardsFormAMatch() {
                for (index, cardIndex) in indicesOfTheSelectedCards.enumerated() {
                    cards[cardIndex].status = .outOfPlay
                    if let cardIndex = indicesOfTheCardsInPlay.firstIndex(of: cardIndex) {
                        indicesOfTheCardsInPlay[cardIndex] = randomDeckIndices[index]
                    }
                }
            } else {
                for cardIndex in randomDeckIndices {
                    indicesOfTheCardsInPlay.append(cardIndex)
                }
            }
        }
    }
    
    mutating func choose(_ card: Card) {
        if let chosenIndex = cards.firstIndex(matching: card) {
            if indicesOfTheSelectedCards.count == 3 {
                if selectedCardsFormAMatch() {
                    if let randomDeckIndices = selectRandomCardsFromTheDeck(count: 3) {
                        for cardIndex in randomDeckIndices {
                            cards[cardIndex].status = .inPlay
                        }
                        
                        for (index, cardIndex) in indicesOfTheSelectedCards.enumerated() {
                            cards[cardIndex].status = .outOfPlay
                            if let cardIndex = indicesOfTheCardsInPlay.firstIndex(of: cardIndex) {
                                indicesOfTheCardsInPlay[cardIndex] = randomDeckIndices[index]
                            }
                        }
                    } else {
                        for index in indicesOfTheSelectedCards{
                            cards[index].status = .outOfPlay
                            if let index = indicesOfTheCardsInPlay.firstIndex(of: index) {
                                indicesOfTheCardsInPlay.remove(at: index)
                            }
                        }
                    }
                } else {
                    for index in indicesOfTheSelectedCards {
                        cards[index].isSelected = false
                    }
                }
                cards[chosenIndex].isSelected = true
            } else {
                cards[chosenIndex].isSelected = !cards[chosenIndex].isSelected
            }
        }
    }
    
    private func selectRandomCardsFromTheDeck(count: Int) -> [Int]? {
        let count = min(count, numberOfCardsInTheDeck)
        if count == 0 {
            return nil
        }
        let randomDeckIndices = cards.indices.filter { cards[$0].status == .inDeck }.shuffled()
        return Array(randomDeckIndices[..<count])
    }
    
    func selectedCardsFormAMatch() -> Bool {
        if indicesOfTheSelectedCards.count == 3 {
            return Card.formsAMatch(cards[indicesOfTheSelectedCards[0]], cards[indicesOfTheSelectedCards[1]], cards[indicesOfTheSelectedCards[2]])
        }
        return false
    }
    
    struct Card: Identifiable {
        var status = Status.inDeck
        var isSelected = false
        
        let content: CardContent
        let id: Int
        
        struct CardContent {
            let number: Int
            let color: Color
            let symbol: CardSymbol
            let shading: CardShading
        }
        
        enum Status {
            case inDeck, inPlay, outOfPlay
        }

        static func formsAMatch(_ a: Card, _ b: Card, _ c: Card) -> Bool {
            return propertiesMatch(a.content.number, b.content.number, c.content.number)
                && propertiesMatch(a.content.color, b.content.color, c.content.color)
                && propertiesMatch(a.content.symbol, b.content.symbol, c.content.symbol)
                && propertiesMatch(a.content.shading, b.content.shading, c.content.shading)
        }
        
        static func propertiesMatch<CardProperty: Equatable>(
            _ a: CardProperty, _ b: CardProperty, _ c: CardProperty) -> Bool {
            return (a == b && a == c && b == c) || (a != b && a != c && b != c)
        }
    }
}
