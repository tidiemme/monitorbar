//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

class MeterCpu  : Meter {
    private var text : NSMutableAttributedString
    private var cpus = [Double]()
    private var cpuCount : natural_t
    private var cpuUsage : Double
    private var textSize : Double
    
    #if !DYN_SIZE
    private let textSizeDef : Double = 17
    private let textSize100 : Double = 22.2
    #endif
    
    override init() {
        text = NSMutableAttributedString(string: String(format: "000"), attributes: StringAttribute.normal)
        cpuUsage = 0.0
        cpuCount = Monitor.cpuCount()
        let cpuIconsWidth = (Double(cpuCount) * MenuBarSettings.cpuBarWidth) + ((Double(cpuCount - 1)))
        #if DYN_SIZE
        textSize = Double(text.size().width)
        #else
        textSize = textSizeDef
        #endif
        super.init()
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            minContainerWidth += cpuIconsWidth
                               + MenuBarSettings.spacing
                               + MenuBar.charPercentageWidth
        } else {
            minContainerWidth += MenuBarSettings.cpuBarWidthCompact
        }
    }
    
    func update(_ monitor : Monitor) {
        (cpus, cpuUsage) = monitor.cpuUsage()
        text.mutableString.setString(String(format: "%.0f", cpuUsage))
        #if !DYN_SIZE
        if (cpuUsage < 100) {
            textSize = textSizeDef
        } else {
            textSize = textSize100
        }
        #else
        textSize = Double(text.size().width)
        #endif
        containerWidth = minContainerWidth
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            containerWidth += textSize
        }
    }
    
    func draw(_ pos : Double, _ color : [Double]) {
        var currentPos = pos
        drawContainer(currentPos
                     ,containerWidth
                     ,MenuBarSettings.menubarHeight
                     ,MenuBarSettings.menubarHalfHeight
                     ,getColor(color))
        
        let colorDark = getColorDark(color)
        currentPos += MenuBarSettings.arrowWidth + MenuBarSettings.spacing
            
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            for cpu in cpus {
                if cpu >= 0.0 {
                    let cpuBarR = NSRect(x: currentPos, y: MenuBarSettings.cpuBarY
                                        ,width: MenuBarSettings.cpuBarWidth, height: MenuBarSettings.cpuBarHeight)
                    let roundedCpuBarR = NSBezierPath(roundedRect: cpuBarR, xRadius: 0.1, yRadius: 0.1)
                    colorDark.set()
                    roundedCpuBarR.fill()
                    
                    let barHeight = MenuBarSettings.cpuBarHeight * (cpu / 100.0)
                    let cpuBar = NSRect(x: currentPos, y: MenuBarSettings.cpuBarY
                                        ,width: MenuBarSettings.cpuBarWidth, height: barHeight)
                    let roundedCpuBar = NSBezierPath(roundedRect: cpuBar, xRadius: 0.1, yRadius: 0.1)
                    NSColor.white.set()
                    roundedCpuBar.fill()
                    currentPos += MenuBarSettings.cpuBarWidth + 0.9
                }
            }
            currentPos += MenuBarSettings.cpuBarWidth - 3
            text.draw(at: NSPoint(x: currentPos + textSize - Double(text.size().width), y: MenuBarSettings.textY))
            currentPos += textSize
            MenuBar.charPercentage.draw(at: NSPoint(x: currentPos, y: MenuBarSettings.percentageY))
        } else {
            let cpuBarR = NSRect(x: currentPos, y: MenuBarSettings.cpuBarY
                                ,width: MenuBarSettings.cpuBarWidthCompact, height: MenuBarSettings.cpuBarHeight)
            let roundedCpuBarR = NSBezierPath(roundedRect: cpuBarR, xRadius: 0.1, yRadius: 0.1)
            colorDark.set()
            roundedCpuBarR.fill()
                    
            let barHeight = MenuBarSettings.cpuBarHeight * (cpuUsage / 100.0)
            let cpuBar = NSRect(x: currentPos, y: MenuBarSettings.cpuBarY
                               ,width: MenuBarSettings.cpuBarWidthCompact, height: barHeight)
            let roundedCpuBar = NSBezierPath(roundedRect: cpuBar, xRadius: 0.1, yRadius: 0.1)
            NSColor.white.set()
            roundedCpuBar.fill()
        }
    }
}
