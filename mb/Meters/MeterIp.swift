//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI
import CoreWLAN

class MeterIp  : Meter {
    private var ip : String
    private var wifi : String
    private var signal : Int
    private var textIp : NSMutableAttributedString
    private var textWifi : NSMutableAttributedString
    private var currentInterface : CWInterface
    private var networks: Set<CWNetwork> = []
    
    override init() {
        ip = "127.0.0.1"
        wifi = "-"
        signal = 0
        textIp = NSMutableAttributedString(string: ip
                                          ,attributes: StringAttribute.small)
        textWifi = NSMutableAttributedString(string: wifi
                                          ,attributes: StringAttribute.small)
        currentInterface = CWInterface()
        super.init()
        minContainerWidth += MenuBarSettings.netIpIconWidth
    }
    
    func update(_ monitor : Monitor) {
        
        if let defaultInterface = CWWiFiClient.shared().interface() {
            currentInterface = defaultInterface
            if let sid = currentInterface.ssid() {
                wifi = sid
            } else {
                wifi = "-"
            }
        }
        let rssi = currentInterface.rssiValue()
        if (rssi > -50) {
            signal = 3
        } else if (rssi > -70) {
            signal = 2
        } else if (rssi > -90) {
            signal = 1
        } else {
            signal = 0
        }

        //let interface = monitor.currentNetworkInterface()
        ip = monitor.getIp(currentInterface.interfaceName!)
        if ip == "" {
            ip = "-"
        }
        textIp.mutableString.setString(ip)
        textWifi.mutableString.setString(wifi)
        
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
