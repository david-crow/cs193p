//
//  EmojiMemoryGameStore.swift
//  Memorize
//
//  Created by David Crow on 6/27/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI
import Combine

class EmojiMemoryGameStore: ObservableObject {
    @Published var themes: [EmojiMemoryGameTheme]
    private var autosave: AnyCancellable?
    let name: String
    
    init(named name: String = "Themes") {
        self.name = name
        let defaultsKey = "EmojiMemoryGameThemeStore.\(name)"
        themes = (UserDefaults.standard.object(forKey: defaultsKey) as? [Data])?
            .compactMap({ EmojiMemoryGameTheme(json: $0) }) ?? EmojiMemoryGameTheme.themes
        autosave = $themes.sink { themes in
            UserDefaults.standard.set(themes.map{ $0.json }, forKey: defaultsKey)
        }
    }
    
    // MARK: - Mutators
    
    func updateName(_ name: String, for theme: EmojiMemoryGameTheme) {
        if let index = themes.firstIndex(matching: theme) {
            themes[index].name = name
        }
    }
    
    func addEmojis(_ emojis: String, to theme: EmojiMemoryGameTheme) {
        if let index = themes.firstIndex(matching: theme) {
            let newEmojis = emojis.map { String($0) }
            themes[index].emojis.insert(contentsOf: newEmojis, at: 0)
            themes[index].emojis = Array(Set(themes[index].emojis))
            themes[index].removedEmojis.removeAll(where: { newEmojis.contains($0) })
        }
    }
    
    func removeEmoji(_ emoji: String, from theme: EmojiMemoryGameTheme) {
        if let index = themes.firstIndex(matching: theme) {
            themes[index].emojis.removeAll(where: { $0 == emoji })
            themes[index].numberOfPairs = min(themes[index].numberOfPairs, themes[index].emojis.count)
            themes[index].removedEmojis.insert(emoji, at: 0)
            themes[index].removedEmojis = Array(Set(themes[index].removedEmojis))
        }
    }
    
    func updateNumberOfPairs(_ numberOfPairs: Int, for theme: EmojiMemoryGameTheme) {
        if let index = themes.firstIndex(matching: theme) {
            themes[index].numberOfPairs = numberOfPairs
        }
    }
    
    func changeColor(_ color: UIColor, for theme: EmojiMemoryGameTheme) {
        if let index = themes.firstIndex(matching: theme) {
            themes[index].colorRGB = color.rgb
        }
    }
    
    // MARK: - Accessors
    
    func emojis(in theme: EmojiMemoryGameTheme) -> [String]? {
        if let index = themes.firstIndex(matching: theme) {
            return themes[index].emojis
        }
        return nil
    }
    
    func removedEmojis(for theme: EmojiMemoryGameTheme) -> [String]? {
        if let index = themes.firstIndex(matching: theme) {
            return themes[index].removedEmojis
        }
        return nil
    }
    
    func numberOfPairs(in theme: EmojiMemoryGameTheme) -> Int? {
        if let index = themes.firstIndex(matching: theme) {
            return themes[index].numberOfPairs
        }
        return nil
    }
    
    func colorRGB(for theme: EmojiMemoryGameTheme) -> UIColor.RGB? {
        if let index = themes.firstIndex(matching: theme) {
            return themes[index].colorRGB
        }
        return nil
    }
}
