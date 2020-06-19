//
//  Diamond.swift
//  Set Game
//
//  Created by David Crow on 6/5/20.
//  Copyright © 2020 David Crow. All rights reserved.
//

import SwiftUI

struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        let topCorner = CGPoint(x: rect.midX, y: rect.minY)
        let leftCorner = CGPoint(x: rect.minX, y: rect.midY)
        let bottomCorner = CGPoint(x: rect.midX, y: rect.maxY)
        let rightCorner = CGPoint(x: rect.maxX, y: rect.midY)

        var path = Path()
        path.move(to: topCorner)
        path.addLine(to: leftCorner)
        path.addLine(to: bottomCorner)
        path.addLine(to: rightCorner)
        path.addLine(to: topCorner)
        path.addLine(to: leftCorner)
        return path
    }
}
