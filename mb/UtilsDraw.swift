//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

// :TODO: Load all this color themes from file

var transparency = 1.0

struct Color {
    static let purple      = [142.0,  68.0, 173.0, transparency]
    static let blue        = [ 41.0, 128.0, 185.0, transparency]
    static let green       = [ 39.0, 174.0,  96.0, transparency]
    static let punpkin     = [211.0,  84.0,   0.0, transparency]
    static let orange      = [229.0, 142.0,  38.0, transparency]
    static let pomegranate = [192.0,  57.0,  43.0, transparency]
    
    static let blue1 = [ 7.0, 200.0, 249.0, transparency]
    static let blue2 = [ 9.0, 166.0, 243.0, transparency]
    static let blue3 = [10.0, 133.0, 237.0, transparency]
    static let blue4 = [12.0,  99.0, 231.0, transparency]
    static let blue5 = [13.0,  82.0, 228.0, transparency]
    static let blue6 = [13.0,  65.0, 225.0, transparency]
    
    static let verde = [217.0, 255.0, 8.0, transparency]
    
    static let black = [0.0, 0.0, 0.0, transparency]
    static let grey = [33.0, 33.0,33.0, transparency]
    static let white = [255.0, 255.0, 255.0, transparency]
}

var ThemePalette = [Color.pomegranate
                   ,Color.punpkin
                   ,Color.orange
                   ,Color.green
                   ,Color.blue
                   ,Color.purple]

var ThemeBlue = [Color.blue1
                ,Color.blue2
                ,Color.blue3
                ,Color.blue4
                ,Color.blue5
                ,Color.blue6]

var ThemeVerde = [Color.verde
                 ,Color.verde
                 ,Color.verde
                 ,Color.verde
                 ,Color.verde
                 ,Color.verde]

//var ThemeTextColor = Color.black
var ThemeTextColor = Color.white
//var ThemeTextColor = Color.grey

struct StringAttribute {
    static let normal = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13),
        NSAttributedString.Key.foregroundColor: getColor(ThemeTextColor)
    ]
    
    static let small = [
        NSAttributedString.Key.font: NSFont.systemFont(ofSize: 9),
        NSAttributedString.Key.foregroundColor: getColor(ThemeTextColor)
    ]
}

func getColor(_ rgb : [Double]) -> NSColor {
    return NSColor.init(deviceRed: CGFloat(rgb[0] / 255.0)
                       ,green: CGFloat(rgb[1] / 255.0)
                       ,blue: CGFloat(rgb[2] / 255.0)
                       ,alpha: CGFloat(rgb[3]))
}

func getColorDark(_ rgb : [Double]) -> NSColor {
    let r = rgb[0] * 0.6 / 255.0
    let g = rgb[1] * 0.6 / 255.0
    let b = rgb[2] * 0.6 / 255.0
    return NSColor.init(deviceRed: CGFloat(r)
                       ,green: CGFloat(g)
                       ,blue: CGFloat(b)
                       ,alpha: CGFloat(rgb[3]))
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
