//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

class MeterDisk  : Meter {
    private var textPercentage : NSMutableAttributedString
    private var textTot : NSMutableAttributedString
    private var textFree : NSMutableAttributedString
    private var diskUsage : Double
    
    override init() {
        textPercentage = NSMutableAttributedString(string: String(format: "000")
                                                  ,attributes: StringAttribute.normal)
        textTot = NSMutableAttributedString(string: String(format: "000")
                                           ,attributes: StringAttribute.small)
        textFree = NSMutableAttributedString(string: String(format: "000")
                                            ,attributes: StringAttribute.small)
        diskUsage = 1.0
        
        super.init()
        minContainerWidth += MenuBarSettings.circleIconWidth
        if (MenuBarSettings.mode == MenuBarSettings.Mode.compact.rawValue) {
            minContainerWidth += MenuBarSettings.spacingCompact
        } else {
            if (MenuBarSettings.mode == MenuBarSettings.Mode.normal.rawValue) {
                minContainerWidth += MenuBar.charPercentageWidth
                                   + MenuBarSettings.spacing
            } else {
                minContainerWidth += MenuBar.charPercentageWidth
                                   + (MenuBarSettings.spacing * 2.0)
            }
        }
    }
    
    func update(_ monitor : Monitor) {
        let (diskTot, diskFree) = monitor.diskUsage()
        if let diskTotUn = diskTot, let diskFreeUn = diskFree {
            diskUsage = Double(diskTotUn-diskFreeUn) / Double(diskTotUn)
            textPercentage.mutableString.setString(String(format: "%.0f", diskUsage * 100.0))
            
            let dt = convertToCorrectUnit(bytes: UInt64(diskTotUn))
            textTot.mutableString.setString(String(format: "%.0f ", dt.value) + dt.unit.rawValue)
            
            let df = convertToCorrectUnit(bytes: UInt64(diskFreeUn))
            textFree.mutableString.setString(String(format: "%.0f ", df.value) + df.unit.rawValue)
        }
        
        containerWidth = minContainerWidth
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            containerWidth += Double(textPercentage.size().width)
            if (MenuBarSettings.mode == MenuBarSettings.Mode.extra.rawValue) {
                containerWidth += max(Double(textTot.size().width),Double(textFree.size().width))
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
                      ,Double(diskUsage), colorDark)
        
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            currentPos += MenuBarSettings.circleIconWidth + MenuBarSettings.spacing
            textPercentage.draw(at: NSPoint(x: currentPos, y: MenuBarSettings.textY))
            currentPos += Double(textPercentage.size().width)
            MenuBar.charPercentage.draw(at: NSPoint(x: currentPos, y: MenuBarSettings.percentageY))
            if (MenuBarSettings.mode == MenuBarSettings.Mode.extra.rawValue) {
                currentPos += MenuBar.charPercentageWidth + MenuBarSettings.spacing
                textTot.draw(at: NSPoint(x: currentPos, y: 8.0))
                textFree.draw(at: NSPoint(x: currentPos, y: 0.5))
            }
        }
    }
}
