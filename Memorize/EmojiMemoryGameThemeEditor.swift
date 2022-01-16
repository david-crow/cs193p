
//  EmojiMemoryGameThemeEditor.swift
//  Memorize
//
//  Created by David Crow on 6/28/20.
//  Copyright © 2020 David Crow. All rights reserved.


import SwiftUI

struct EmojiMemoryGameThemeEditor: View {
    let theme: EmojiMemoryGameTheme

    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var store: EmojiMemoryGameStore
    
    @State private var name = ""
    @State private var emojisToAdd = ""
    @State private var explainMinimumPairs = false
    @State private var numberOfPairs: Int = 0
    @State private var color = UIColor.label
    
    private let colors: [UIColor] = [
        .label, .systemBlue, .systemGreen, .systemIndigo, .systemOrange, .systemPink,
        .systemPurple, .systemRed, .systemTeal, .systemYellow, .systemGray, .systemGray4
    ]
        
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(theme.name)
                    .font(.headline)
                
                HStack {
                    Spacer()
                    Button("Done") {
                        self.presentation.wrappedValue.dismiss()
                    }
                }
            }
            .padding()
            
            Form {
                nameSection
                addEmojiSection
                removeEmojiSection
                
                if self.store.removedEmojis(for: self.theme)!.count > 0 {
                    removedEmojiSection
                }
                
                cardCountSection
                colorSection
            }
            .onAppear {
                self.name = self.theme.name
                self.numberOfPairs = self.theme.numberOfPairs
                self.color = UIColor(self.theme.colorRGB)
            }
        }
    }
    
    // MARK: - Form Sections
    
    var nameSection: some View {
        Section {
            TextField("Theme Name", text: self.$name, onEditingChanged: { began in
                if !began {
                    self.store.updateName(self.name, for: self.theme)
                }
            })
        }
    }
    
    var addEmojiSection: some View {
        Section(header: Text("Add Emoji").font(headerFontSize)) {
            HStack {
                TextField("Emoji", text: $emojisToAdd)
                Spacer()
                Button("Add") {
                    self.store.addEmojis(self.emojisToAdd, to: self.theme)
                    self.emojisToAdd = ""
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: HStack {
            Text("Emojis").font(headerFontSize)
            Spacer()
            Text("tap emoji to remove")
        }) {
            Grid(self.store.emojis(in: self.theme)!, id: \.self) { emoji in
                Text(emoji)
                    .font(Font.system(size: self.emojiEditorFontSize))
                    .onTapGesture {
                        if self.store.emojis(in: self.theme)!.count <= self.minimumPairs {
                            self.explainMinimumPairs = true
                        } else {
                            self.store.removeEmoji(emoji, from: self.theme)
                        }
                    }
                    .alert(isPresented: self.$explainMinimumPairs) {
                        Alert(
                            title: Text("Minimum Emojis"),
                            message: Text("You cannot remove any more emojis. The game requires at least \(self.minimumPairs) pairs."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }
            .frame(height: gridHeight(count: store.emojis(in: theme)!.count))
        }
    }
    
    var removedEmojiSection: some View {
        Section(header: HStack {
            Text("Removed Emojis").font(headerFontSize)
            Spacer()
            Text("tap emoji to add")
        }) {
            Grid(self.store.removedEmojis(for: self.theme)!, id: \.self) { emoji in
                Text(emoji)
                    .font(Font.system(size: self.emojiEditorFontSize))
                    .onTapGesture {
                        self.store.addEmojis(emoji, to: self.theme)
                    }
            }
            .frame(height: gridHeight(count: store.removedEmojis(for: theme)!.count))
        }
    }
    
    var cardCountSection: some View {
        Section(header: Text("Card Count").font(headerFontSize)) {
            HStack {
                Text("\(self.store.numberOfPairs(in: theme)!) Pairs")
                Spacer()
                Stepper("", value: $numberOfPairs, in: minimumPairs...store.emojis(in: theme)!.count, onEditingChanged: { began in
                    if !began {
                        self.store.updateNumberOfPairs(self.numberOfPairs, for: self.theme)
                    }
                })
            }
        }
    }
    
    var colorSection: some View {
        Section(header: Text("Color").font(headerFontSize)) {
            Grid(self.colors, id: \.self) { color in
                self.colorSwatch(color)
                    .padding(self.colorSwatchPadding)
            }
            .frame(height: gridHeight(count: colors.count))
        }
    }
    
    func colorSwatch(_ color: UIColor) -> some View {
        var brightness: CGFloat = .zero
        color.getWhite(&brightness, alpha: nil)
        
        return RoundedRectangle(cornerRadius: colorSwatchCornerRadius).fill(Color(color))
            .onTapGesture {
                self.store.changeColor(color, for: self.theme)
            }
            .overlay(
                Image(systemName: "checkmark.circle")
                    .imageScale(.large)
                    .foregroundColor(brightness > colorSwatchCheckmarkBrightnessLimit ? .black : .white)
                    .padding(self.colorSwatchCheckmarkPadding)
                    .opacity(color.rgb == self.store.colorRGB(for: theme)! ? 1 : 0)
            )
    }

    // MARK: - Drawing Constants

    private let headerFontSize: Font = .subheadline
    private let emojiEditorFontSize: CGFloat = 40
    private let minimumPairs: Int = 2
    private let colorSwatchPadding: CGFloat = 3
    private let colorSwatchCornerRadius: CGFloat = 10
    private let colorSwatchCheckmarkBrightnessLimit: CGFloat = 0.9
    private let colorSwatchCheckmarkPadding: CGFloat = 5
    
    private func gridHeight(count: Int) -> CGFloat {
        CGFloat((count - 1) / 6 * 70 + 70)
    }

    private var emojiEditorHeight: CGFloat {
        CGFloat((store.emojis(in: theme)!.count - 1) / 6 * 70 + 70)
    }
    
    private var removedEmojiEditorHeight: CGFloat {
        CGFloat((store.removedEmojis(for: theme)!.count - 1) / 6 * 70 + 70)
    }

    private var colorEditorHeight: CGFloat {
        CGFloat((colors.count - 1) / 6 * 70 + 70)
    }
}
