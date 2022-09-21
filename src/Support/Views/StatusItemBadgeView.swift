//
//  StatusItemBadgeView.swift
//  Support
//
//  Created by Jordy Witteman on 21/09/2022.
//

import Cocoa
import Foundation

// Notification badge drawing view
// https://stackoverflow.com/questions/68671831/swiftui-macos-menubar-icon-with-badge
class StatusItemBadgeView: NSView {
    
    var color: NSColor
    
    init(frame frameRect: NSRect, color : NSColor) {
        self.color = color
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        self.color = NSColor()
        super.init(coder: coder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let fillColor = color
        let path = NSBezierPath(ovalIn: NSRect(x: 0, y: 0, width: 8, height: 8))
        fillColor.set()
        path.fill()
    }
    
}
