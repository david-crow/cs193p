//
//  EmojiMemoryGameThemeSummary.swift
//  Memorize
//
//  Created by David Crow on 6/28/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct EmojiMemoryGameThemeSummary: View {
    let theme: EmojiMemoryGameTheme
    let isEditing: Bool
    
    var emojiCount: String {
        theme.numberOfPairs == theme.emojis.count ? "All" : String(theme.numberOfPairs)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(theme.name)
                .font(.title)
                .foregroundColor(isEditing ? .primary : theme.color)
                        
            Text("\(emojiCount) of \(theme.emojis.joined())")
                .lineLimit(1)
        }
    }
}
