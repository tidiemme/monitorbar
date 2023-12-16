//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

class MeterNetwork  : Meter {
    private var lastTotalTransmittedBytes: (up: UInt64, down: UInt64) = (up: 0, down: 0)
    
    private var upBandwidth : (value: Double, unit: ByteUnit)
    private var downBandwidth : (value: Double, unit: ByteUnit)
    
    private var textUp : NSMutableAttributedString
    private var textDown : NSMutableAttributedString
    private var textSize : Double
    
    #if !DYN_SIZE
    private let textSizeFixed : Double = 40.0
    #endif
    
    override init() {
        upBandwidth = (value: 0.0, unit: ByteUnit.Byte)
        downBandwidth = (value: 0.0, unit: ByteUnit.Byte)
        textUp = NSMutableAttributedString(string: String(format: "0 MB/s"), attributes: StringAttribute.small)
        textDown = NSMutableAttributedString(string: String(format: "0 MB/s"), attributes: StringAttribute.small)
        #if DYN_SIZE
        textSize = Double(textUp.size().width)
        #else
        textSize = textSizeFixed
        #endif
        super.init()
        minContainerWidth += MenuBarSettings.netIconWidth
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            minContainerWidth += MenuBarSettings.spacing
            containerWidth = minContainerWidth + textSize
        } else {
            containerWidth = minContainerWidth
        }
    }
    
    func update(_ monitor : Monitor) {
        let interface = monitor.currentNetworkInterface()
        let transmittedBytes = monitor.getTotalTransmittedBytesOf(interface)
        var upBytes: UInt64 = 0
        var downBytes: UInt64 = 0
        if transmittedBytes.up >= lastTotalTransmittedBytes.up {
            upBytes = transmittedBytes.up - lastTotalTransmittedBytes.up
        }
        if transmittedBytes.down >= lastTotalTransmittedBytes.down {
            downBytes = transmittedBytes.down - lastTotalTransmittedBytes.down
        }
        upBandwidth = convertToCorrectUnit(bytes: upBytes / UInt64(AppDelegate.updateInterval))
        downBandwidth = convertToCorrectUnit(bytes: downBytes / UInt64(AppDelegate.updateInterval))
        lastTotalTransmittedBytes = transmittedBytes
        
        let tU = String(format: "%.0f ", upBandwidth.value) + upBandwidth.unit.rawValue + "/s"
        let tD = String(format: "%.0f ", downBandwidth.value) + downBandwidth.unit.rawValue + "/s"
        textUp.mutableString.setString(tU)
        textDown.mutableString.setString(tD)
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            #if DYN_SIZE
            textSize = Double(max(textUp.size().width,textDown.size().width))
            containerWidth = minContainerWidth + textSize
            #endif
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
        let upIcon = NSBezierPath()
        upIcon.move(to: CGPoint(x: currentPos, y: 10.0))
        upIcon.line(to: CGPoint(x: currentPos + MenuBarSettings.netIconWidth, y: 10.0))
        upIcon.line(to: CGPoint(x: currentPos + (MenuBarSettings.netIconWidth / 2.0), y: 16.0))
        upIcon.line(to: CGPoint(x: currentPos, y: 10.0))
        if (upBandwidth.value > 0.0) {
            NSColor.white.set()
        } else {
            colorDark.set()
        }
        upIcon.fill()
        let downIcon = NSBezierPath()
        downIcon.move(to: CGPoint(x: currentPos, y: 8.0))
        downIcon.line(to: CGPoint(x: currentPos + MenuBarSettings.netIconWidth, y: 8.0))
        downIcon.line(to: CGPoint(x: currentPos + (MenuBarSettings.netIconWidth / 2.0), y: 2.0))
        downIcon.line(to: CGPoint(x: currentPos, y: 8.0))
        if (downBandwidth.value > 0.0) {
            NSColor.white.set()
        } else {
            colorDark.set()
        }
        downIcon.fill()
        if (MenuBarSettings.mode != MenuBarSettings.Mode.compact.rawValue) {
            currentPos += MenuBarSettings.netIconWidth + MenuBarSettings.spacing
            textUp.draw(at: NSPoint(x: currentPos + textSize - Double(textUp.size().width), y: 8.0))
            textDown.draw(at: NSPoint(x: currentPos + textSize - Double(textDown.size().width), y: 0.5))
        }
    }
}
