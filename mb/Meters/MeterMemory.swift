//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

class MeterMemory  : Meter {
    private var tot : Double
    private var used : Double
    private var cached : Double
    private var memUsage : Double
    
    private var textPercentage : NSMutableAttributedString
    private var textUsed : NSMutableAttributedString
    private var textCached : NSMutableAttributedString
    
    override init() {
        textPercentage = NSMutableAttributedString(string: String(format: "000%")
                                                  ,attributes: StringAttribute.normal)
        textUsed = NSMutableAttributedString(string: String(format: "000")
                                           ,attributes: StringAttribute.small)
        textCached = NSMutableAttributedString(string: String(format: "000")
                                            ,attributes: StringAttribute.small)
        tot = 0.0
        used = 0.0
        cached = 0.0
        memUsage = 0.0
        
        super.init()
        
        minContainerWidth += MenuBarSettings.circleIconWidth
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            if (MenuBarSettings.mode == MenuBarSettings.Mode.normal.rawValue) {
                minContainerWidth += MenuBarSettings.spacing
                                   + MenuBar.charPercentageWidth
            } else {
                minContainerWidth += (MenuBarSettings.spacing * 2.0)
                                   + MenuBar.charPercentageWidth
            }
        } else {
            minContainerWidth += MenuBarSettings.spacingCompact
        }
    }
    
    func update(_ monitor : Monitor) {
        (tot, used, cached) = monitor.memUsage()
        memUsage = used / tot
        textPercentage.mutableString.setString(String(format: "%.0f", memUsage * 100.0))
        textUsed.mutableString.setString(String(format: "%.2f GB", used / Unit.gigabyte.rawValue))
        textCached.mutableString.setString(String(format: "%.2f GB", cached / Unit.gigabyte.rawValue))
        
        containerWidth = minContainerWidth
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            containerWidth += Double(textPercentage.size().width)
            if (MenuBarSettings.mode == MenuBarSettings.Mode.extra.rawValue) {
                containerWidth += max(Double(textUsed.size().width),Double(textCached.size().width))
            }
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
                      ,Double(memUsage), colorDark)
        
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            currentPos += MenuBarSettings.circleIconWidth + MenuBarSettings.spacing
            textPercentage.draw(at: NSPoint(x: currentPos, y: MenuBarSettings.textY))
            currentPos += Double(textPercentage.size().width)
            MenuBar.charPercentage.draw(at: NSPoint(x: currentPos, y: MenuBarSettings.percentageY))
            if (MenuBarSettings.mode == MenuBarSettings.Mode.extra.rawValue) {
                currentPos += MenuBar.charPercentageWidth + MenuBarSettings.spacing
                textUsed.draw(at: NSPoint(x: currentPos, y: 8.0))
                textCached.draw(at: NSPoint(x: currentPos, y: 0.5))
            }
        }
    }
}
