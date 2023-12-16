//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI
import CoreWLAN
import NetworkExtension
import CoreLocation

class MeterIp  : Meter {
    private var ip : String
    private var wifi : String
    private var signal : Int
    private var textIp : NSMutableAttributedString
    private var textWifi : NSMutableAttributedString
    
    override init() {
        ip = "127.0.0.1"
        wifi = "Wi-Fi"
        signal = 0
        textIp = NSMutableAttributedString(string: ip
                                          ,attributes: StringAttribute.small)
        textWifi = NSMutableAttributedString(string: wifi
                                            ,attributes: StringAttribute.small)
        super.init()
        minContainerWidth += MenuBarSettings.netIpIconWidth
    }

    func update(_ monitor : Monitor) {
        
        let defaultInterface : CWInterface? = CWWiFiClient.shared().interface()
        if defaultInterface != nil {
            if let sid = defaultInterface?.ssid() {
                wifi = sid
            } else {
                wifi = "Wi-Fi"
            }
        }
        textWifi.mutableString.setString(wifi)
        
        ip = monitor.getIp(monitor.currentNetworkInterface())
        textIp.mutableString.setString(ip)
        
        let rssi = defaultInterface?.rssiValue()
        if (rssi ?? 1 > -50) {
            signal = 3
        } else if (rssi ?? 1 > -70) {
            signal = 2
        } else if (rssi ?? 1 > -90) {
            signal = 1
        } else {
            signal = 0
        }

        containerWidth = minContainerWidth
        if (MenuBarSettings.mode == MenuBarSettings.Mode.extra.rawValue) {
            containerWidth += MenuBarSettings.spacing + Double(max(textIp.size().width,textWifi.size().width))
        }
    }
    
    func draw(_ pos : Double, _ color : [Double]) {
        var currentPos = pos
        drawContainer(currentPos
                     ,containerWidth
                     ,MenuBarSettings.menubarHeight
                     ,MenuBarSettings.menubarHalfHeight
                     ,getColor(color))
        currentPos += MenuBarSettings.arrowWidth + MenuBarSettings.spacing
        drawWifiIcon(currentPos, signal, getColorDark(color))
        if (MenuBarSettings.mode == MenuBarSettings.Mode.extra.rawValue) {
            currentPos += 18.0 + MenuBarSettings.spacing
            textIp.draw(at: NSPoint(x: currentPos, y: 0.5))
            textWifi.draw(at: NSPoint(x: currentPos, y: 8.0))
        }
    }
}

