//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

class MenuBar {
    var statusItem: NSStatusItem!
    var menu : NSMenu!
    
    private var settings = MenuBarSettings()
    
    private var monitor = Monitor()
    
    private var ip : MeterIp
    private var network : MeterNetwork
    private var cpu : MeterCpu
    private var mem : MeterMemory
    private var disk : MeterDisk
    private var battery : MeterBattery
    
    static var charPercentage = NSMutableAttributedString(string: String(format: "%%")
                                                  ,attributes: StringAttribute.small)
    static var charPercentageWidth = 0.0
    
    init(){
        settings.initialise()
        MenuBar.charPercentageWidth = Double(MenuBar.charPercentage.size().width)
        ip = MeterIp()
        network = MeterNetwork()
        cpu = MeterCpu()
        mem = MeterMemory()
        disk = MeterDisk()
        battery = MeterBattery()
    }
    
    func reset() {
        ip = MeterIp()
        network = MeterNetwork()
        cpu = MeterCpu()
        mem = MeterMemory()
        disk = MeterDisk()
        battery = MeterBattery()
    }
    
    func initialise() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        menu = NSMenu()
        //let menuSettings = NSMenuItem()
        //menuSettings.title = "Settings"
        //menuSettings.submenu = NSMenu(title: "Settings")
        //menuSettings.submenu?.items = [NSMenuItem(title: "Compact"
        //                               ,action: #selector(AppDelegate.appMonitorClicked(_:)), keyEquivalent: "s")]
        //menu.addItem(menuSettings)
        menu.addItem(NSMenuItem(title: "Compact"
                    ,action: #selector(AppDelegate.compact(_:)), keyEquivalent: "c"))
        menu.addItem(NSMenuItem(title: "Normal"
                    ,action: #selector(AppDelegate.normal(_:)), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "Extra"
                    ,action: #selector(AppDelegate.extra(_:)), keyEquivalent: "e"))
        
        menu.addItem(NSMenuItem(title: "Activity Monitor"
                    ,action: #selector(AppDelegate.appMonitorClicked(_:)), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Quit"
                    ,action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
        
        update()
    }
    
    func update() {
        ip.update(monitor)
        network.update(monitor)
        cpu.update(monitor)
        mem.update(monitor)
        disk.update(monitor)
        battery.update(monitor)
        
        let mbWidth = ip.containerWidth
                    + network.containerWidth
                    + cpu.containerWidth
                    + mem.containerWidth
                    + disk.containerWidth
                    + battery.containerWidth
                    - (MenuBarSettings.arrowWidth * 5.0)
        
        let mbHeight = MenuBarSettings.menubarHeight
        
        let image = NSImage( size: NSSize( width: mbWidth, height: mbHeight))
        image.lockFocus()
        
        var pos = 0.0
        ip.draw(pos, Color.pomegranate, Color.pomegranateDark)
        pos += ip.containerWidth - MenuBarSettings.arrowWidth
        network.draw(pos, Color.punpkin, Color.punpkinDark)
        pos += network.containerWidth - MenuBarSettings.arrowWidth
        cpu.draw(pos, Color.orange, Color.orangeDark)
        pos += cpu.containerWidth - MenuBarSettings.arrowWidth
        mem.draw(pos, Color.green, Color.greenDark)
        pos += mem.containerWidth - MenuBarSettings.arrowWidth
        disk.draw(pos, Color.blue, Color.blueDark)
        pos += disk.containerWidth - MenuBarSettings.arrowWidth
        battery.draw(pos, Color.purple, Color.purpleDark)
        
        image.unlockFocus()
        statusItem?.button?.image = image
    }
}
