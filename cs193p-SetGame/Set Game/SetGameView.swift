//
//  SetGameView.swift
//  Set Game
//
//  Created by David Crow on 6/3/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var viewModel: SetGame
    
    private var setSelected: Bool {
        viewModel.numberOfSelectedCards == 3
    }
    
    private var setFormsAMatch: Bool {
        viewModel.selectedCardsFormAMatch()
    }
    
    private var randomOffset: CGSize {
        let size = UIScreen.main.bounds.size
        let signs: [CGFloat] = [-1, 1]
        return CGSize(width: (.random(in: 2 * 0..<size.width) + size.width) * signs.randomElement()!,
                      height: (.random(in: 2 * 0..<size.height) + size.height) * signs.randomElement()!
        )
    }
    
    private func dealCards(count: Int = 12) {
        withAnimation(.easeInOut(duration: self.animationDuration)) {
            viewModel.dealCards(count: count)
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        self.dealCards(count: 3)
                    }) { Text("Deal Cards") }
                        .disabled(!viewModel.deckStillHasCards)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: self.animationDuration)) {
                            self.viewModel.resetGame()
                        }
                    }) { Text("New Game") }
                }
                .padding([.horizontal, .top])
                
                ZStack {
                    Group {
                        Spacer()
                        Text("You win!").font(Font.largeTitle)
                        Spacer()
                    }
                    .opacity(self.viewModel.playerWonTheGame ? 1 : 0)
                    
                    Group {
                        Grid(viewModel.cardsInPlay) { card in
                            CardView(card: card, setSelected: self.setSelected, setFormsAMatch: self.setFormsAMatch)
                                .transition(.offset(self.randomOffset))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: self.animationDuration)) {
                                        self.viewModel.choose(card)
                                    }
                                }
                        }
                        .onAppear {
                            self.dealCards()
                        }
                    }
                    .opacity(self.viewModel.playerWonTheGame ? 0 : 1)
                }
            }
        }
    }
    
    private let animationDuration = 0.25
}

struct CardView: View {
    var card: MatchingGame<SetGame.Symbol, SetGame.Shading>.Card
    let setSelected: Bool
    let setFormsAMatch: Bool
    var hasIcon: Bool {
        setSelected && card.isSelected
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
    
    @ViewBuilder
    private func body(for size: CGSize) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white)
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(lineWidth: lineWidth)
                .foregroundColor(card.isSelected ? Color.yellow : Color.black)
            
            VStack {
                ForEach(0..<card.content.number) {_ in
                    ZStack {
                        self.buildShapeFor(self.card.content.symbol, stroked: false)
                            .opacity(self.computeOpacityFor(self.card.content.shading))
                        
                        self.buildShapeFor(self.card.content.symbol, stroked: true)
                    }
                    .foregroundColor(self.card.content.color)
                }
                .aspectRatio(aspectRatioForShapes, contentMode: .fit)
            }
            .padding(paddingForCardContent)
            
            Image(systemName: setFormsAMatch ? "checkmark" : "xmark")
                .font(Font.system(size: fontSize(for: size)))
                .opacity(hasIcon ? 1 : 0)

        }
        .aspectRatio(aspectRatioForCards, contentMode: .fit)
        .padding(paddingForCards)
    }
    
    @ViewBuilder
    private func buildShapeFor(_ symbol: SetGame.Symbol, stroked: Bool) -> some View {
        if symbol == .diamond {
            Diamond().if(stroked) { content in content.stroke(lineWidth: lineWidth) }
        } else if symbol == .oval {
            Capsule().if(stroked) { content in content.stroke(lineWidth: lineWidth) }
        } else if symbol == .squiggle {
            Rectangle().if(stroked) { content in content.stroke(lineWidth: lineWidth) }
        }
    }
    
    private func computeOpacityFor(_ shading: SetGame.Shading) -> Double {
        shading == .open ? opacityForOpen : (shading == .striped ? opacityForStriped : opacityForSolid)
    }
    
    // MARK: - Drawing Constants
    
    private let cornerRadius: CGFloat = 10.0
    private let lineWidth: CGFloat = 3
    
    private let aspectRatioForShapes: CGFloat = 2.0
    private let aspectRatioForCards: CGFloat = 2/3
    
    private let paddingForCardContent: CGFloat = 10
    private let paddingForCards: CGFloat = 5
    
    private let opacityForOpen = 0.0
    private let opacityForStriped = 0.25
    private let opacityForSolid = 1.0
    
    private func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.5
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SetGame()
        return SetGameView(viewModel: game)
    }
}
