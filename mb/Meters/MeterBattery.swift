//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI
import IOKit.ps

class MeterBattery : Meter {
    private var text : NSMutableAttributedString
    private var plugged : Bool
    private var charged : Bool
    private var currentCapacity : Int
    
    override init() {
        text = NSMutableAttributedString(string: String(format: "000%")
                                 ,attributes: StringAttribute.normal)
        plugged = false
        charged = false
        currentCapacity = 100
        super.init()
        
        minContainerWidth += MenuBarSettings.circleIconWidth
        
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact) {
            minContainerWidth += MenuBarSettings.spacing
        } else {
            minContainerWidth += MenuBarSettings.spacingCompact
        }
    }
    
    func update(_ monitor : Monitor) {
        plugged = monitor.batteryPlugged()
        currentCapacity = monitor.batteryCurrentCapacity()
        charged = currentCapacity == 100
        text.mutableString.setString(String(format: "%.d", currentCapacity))
        containerWidth = minContainerWidth
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact) {
            containerWidth += Double(text.size().width)
                            + MenuBar.charPercentageWidth
        }
    }
    
    func draw(_ pos : Double, _ color : NSColor, _ colorDark : NSColor) {
        var currentPos = pos
        drawContainer(currentPos
                     ,containerWidth
                     ,MenuBarSettings.menubarHeight
                     ,MenuBarSettings.menubarHalfHeight
                     ,color)
        
        currentPos += MenuBarSettings.arrowWidth + MenuBarSettings.spacing
        drawCircleIcon(currentPos, MenuBarSettings.circleIconWidth, MenuBarSettings.circleIconHeight
                      ,Double(currentCapacity) / 100.0, colorDark)
        if plugged {
            if charged {
                NSColor.white.set()
            } else {
                NSColor.magenta.set()
            }
            let batteryCircle = NSBezierPath()
            batteryCircle.appendArc(withCenter: CGPoint(x: currentPos + MenuBarSettings.circleIconWidth / 2, y: 9.0)
                                ,radius: 2.5
                                ,startAngle: 0
                                ,endAngle: 360)
            batteryCircle.fill()
        }
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact) {
            currentPos += MenuBarSettings.circleIconWidth + MenuBarSettings.spacing
            text.draw(at: NSPoint(x: currentPos, y: MenuBarSettings.textY))
            currentPos += Double(text.size().width)
            MenuBar.charPercentage.draw(at: NSPoint(x: currentPos, y: MenuBarSettings.percentageY))
        }
    }
}
