//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

struct StringAttribute {
    static let normal = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13),
        NSAttributedString.Key.foregroundColor: NSColor.white
    ]
    
    static let small = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9),
        NSAttributedString.Key.foregroundColor: NSColor.white
    ]
}

struct Color {
    static let purple = NSColor.init(deviceRed: 142.0/255.0, green: 68.0/255.0, blue: 173.0/255, alpha: 1.0)
    static let purpleDark = NSColor.init(deviceRed: 75.0/255.0, green: 36.0/255.0, blue: 92.0/255, alpha: 1.0)
    static let blue = NSColor.init(deviceRed: 41.0/255.0, green: 128.0/255.0, blue: 185.0/255, alpha: 1.0)
    static let blueDark = NSColor.init(deviceRed: 26.0/255.0, green: 79.0/255.0, blue: 115.0/255, alpha: 1.0)
    static let green = NSColor.init(deviceRed: 39.0/255.0, green: 174.0/255.0, blue: 96.0/255, alpha: 1.0)
    static let greenDark = NSColor.init(deviceRed: 8.0/255.0, green: 102/255.0, blue: 48.0/255, alpha: 1.0)
    static let punpkin = NSColor.init(deviceRed: 211.0/255.0, green: 84.0/255.0, blue: 0.0/255, alpha: 1.0)
    static let punpkinDark = NSColor.init(deviceRed: 140.0/255.0, green: 55.0/255.0, blue: 0.0/255, alpha: 1.0)
    static let orange = NSColor.init(deviceRed: 229.0/255.0, green: 142.0/255.0, blue: 38.0/255, alpha: 1.0)
    static let orangeDark = NSColor.init(deviceRed: 143.0/255.0, green: 79.0/255.0, blue: 3.0/255, alpha: 1.0)
    static let pomegranate = NSColor.init(deviceRed: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255, alpha: 1.0)
    static let pomegranateDark = NSColor.init(deviceRed: 83.0/255.0, green: 19.0/255.0, blue: 17.0/255, alpha: 1.0)
}

func drawContainer(_ start : Double
                          ,_ width : Double
                          ,_ height : Double
                          ,_ halfHeight : Double
                          ,_ color : NSColor) {
    let path = NSBezierPath()
    path.move(to: CGPoint(x: start + width, y: 0))
    path.line(to: CGPoint(x: start + width - halfHeight, y: halfHeight))
    path.line(to: CGPoint(x: start + width, y: height))
    path.line(to: CGPoint(x: start + halfHeight, y: height))
    path.line(to: CGPoint(x: start, y: halfHeight))
    path.line(to: CGPoint(x: start + halfHeight, y: 0))
    path.line(to: CGPoint(x: start + width, y: 0))
    color.set()
    path.fill()
}

func drawCircleIcon(_ pos : Double
                   ,_ iconWidth : Double
                   ,_ iconHeight : Double
                   ,_ usage : Double
                   ,_ color : NSColor) {
    var iconCircle = NSBezierPath()
    let iconCircleAngle = CGFloat(360 * Double(usage))
    color.setStroke()
    iconCircle.appendArc(withCenter: CGPoint(x: pos + iconWidth / 2, y: 9.0)
                        ,radius: 5.0
                        ,startAngle: 0
                        ,endAngle: 360)
    iconCircle.lineWidth = 5
    iconCircle.stroke()
    
    NSColor.white.setStroke()
    iconCircle = NSBezierPath()
    iconCircle.appendArc(withCenter: CGPoint(x: pos + iconWidth / 2, y: 9.0)
                                ,radius: 5.0
                                ,startAngle: 0
                                ,endAngle: iconCircleAngle
                                ,clockwise: false)
    iconCircle.lineWidth = 3
    iconCircle.stroke()
}
    
func drawWifiIcon(_ pos : Double
                 ,_ strength : Int
                 ,_ color : NSColor) {
    
    if ( strength == 3) {
        NSColor.white.setStroke()
    } else {
        color.setStroke()
    }
    
    let one = NSBezierPath()
    one.appendArc(withCenter: CGPoint(x: pos + 9.0, y: 5.5)
                 ,radius: 9.0
                 ,startAngle: 30
                 ,endAngle: 150
                 ,clockwise: false)
    // not sure why I have to do this if stoke color is not white the width seems different
    if ( strength > 2) {
        one.lineWidth = 2
    } else {
        one.lineWidth = 3
    }
    one.stroke()
    
    if ( strength == 2) {
        NSColor.white.setStroke()
    }
    
    let two = NSBezierPath()
    two.appendArc(withCenter: CGPoint(x: pos + 9.0, y: 5.5)
                 ,radius: 5.0
                 ,startAngle: 30
                 ,endAngle: 150
                 ,clockwise: false)
    if ( strength > 1) {
        two.lineWidth = 2
    } else {
        two.lineWidth = 3
    }
    two.stroke()
    
    if ( strength == 1) {
        NSColor.white.setStroke()
    }
    
    let three = NSBezierPath()
    three.appendArc(withCenter: CGPoint(x: pos + 9.0, y: 5.5)
                   ,radius: 1.0
                   ,startAngle: 0
                   ,endAngle: 360)
    if ( strength > 0) {
        three.lineWidth = 2
    } else {
        three.lineWidth = 3
    }
    three.stroke()
}
