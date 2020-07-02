//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by David Crow on 6/8/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
