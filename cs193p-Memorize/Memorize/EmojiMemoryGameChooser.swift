//
//  EmojiMemoryGameChooser.swift
//  Memorize
//
//  Created by David Crow on 6/27/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct EmojiMemoryGameChooser: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var store: EmojiMemoryGameStore
    @State private var editMode = EditMode.inactive
    @State private var showThemeEditor = false
    @State private var editingTheme = EmojiMemoryGameTheme.template

    var body: some View {
        NavigationView {
            List {
                ForEach(store.themes) { theme in
                    NavigationLink(destination: EmojiMemoryGameView(viewModel: EmojiMemoryGame(theme: theme))
                        .navigationBarTitle(theme.name)
                    ) {
                        HStack {
                            if self.editMode.isEditing {
                                Button(action: {
                                    self.showThemeEditor = true
                                    self.editingTheme = theme
                                }, label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(theme.color)
                                        .padding(.trailing)
                                })
                                .buttonStyle(BorderlessButtonStyle())
                            }

                            EmojiMemoryGameThemeSummary(theme: theme, isEditing: self.editMode.isEditing)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        self.store.themes.remove(at: index)
                    }
                }
            }
            .navigationBarTitle(store.name)
            .navigationBarItems(
                leading: Button(action: { self.store.themes.append(EmojiMemoryGameTheme.template) },
                                label: { Image(systemName: "plus").imageScale(.large) })
                    .opacity(editMode.isEditing ? 1 : 0),
                trailing: EditButton()
            )
            .environment(\.editMode, $editMode)
        }
        .sheet(isPresented: self.$showThemeEditor) {
            EmojiMemoryGameThemeEditor(theme: self.editingTheme)
                .environmentObject(self.store)
        }
    }
}
