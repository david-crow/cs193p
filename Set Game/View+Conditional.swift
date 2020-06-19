//
//  View+Conditional.swift
//  Set Game
//
//  Created by David Crow on 6/5/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

extension View {
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            return AnyView(content(self))
        } else {
            return AnyView(self)
        }
    }
}
