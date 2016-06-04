//
//  WhiteView.swift
//  IHC App
//
//  Created by Vikram Raj Gopinathan on 02/06/16.
//  Copyright © 2016 Kivi. All rights reserved.
//

import Cocoa

class WhiteView: NSView {

    override func drawRect(dirtyRect: NSRect) {
        NSColor.whiteColor().setFill()
        NSRectFill(bounds)
    }
    
}
