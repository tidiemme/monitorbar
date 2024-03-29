//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import SwiftUI
import AppKit
import CoreLocation

@main
struct mbApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    static let updateInterval : Double = 2.0
    static let menuBar = MenuBar()
    
    //private let popover = NSPopover.init()
    private var timer: RepeatingTimer!
    private let contentView = ContentView()
    private var locationManager = CLLocationManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set the SwiftUI's ContentView to the Popover's ContentViewController
        //popover.behavior = .transient
        //popover.animates = false
        //popover.contentViewController = NSViewController()
        //popover.contentViewController?.view = NSHostingView(rootView: contentView)
        
        // :TODO: load config/colors and themes from files
        //let asset = NSDataAsset(name: "Config", bundle: Bundle.main)
        //let jsonW = try? JSONSerialization.jsonObject(with: asset!.data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: String]
        //if let json = jsonW {
        //    if let theme = json["theme"] {
        //        print(theme)
        //    }
        //}
        
        AppDelegate.menuBar.initialise()
        
        timer = RepeatingTimer(AppDelegate.updateInterval)
        timer.eventHandler = fireTimer
        timer.resume()
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(self.onWakeUp(notification:)),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(self.onSleep(notification:)),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        if locationManager.authorizationStatus == .authorizedAlways {
            locationManager.delegate = self
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func buildMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        AppDelegate.menuBar.statusItem?.button?.menu = menu
    }
    
    @objc func fireTimer() {
        DispatchQueue.main.async {
            AppDelegate.menuBar.update()
        }
    }
    
    @objc func appMonitorClicked(_ sender: Any) {
        let conf = NSWorkspace.OpenConfiguration()
        conf.hidesOthers = false // if true, hide other apps when open
        conf.hides = false // if true, open app but doesn't show window
        conf.activates = false // if true, open app and move front most
        // conf.arguments, you can past arguments. you might use to exec command line tool
        // conf.environment, you can set enviromentl variables.
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app")
                                          ,configuration: conf)
    }
    
    @objc func compact(_ sender: Any) {
        AppDelegate.setMode(1)
    }
    
    @objc func normal(_ sender: Any) {
        AppDelegate.setMode(2)
    }
    
    @objc func extra(_ sender: Any) {
        AppDelegate.setMode(3)
    }
    
    static func setMode(_ mode : Int) {
        MenuBarSettings.mode = mode
        UserDefaults.standard.set(mode, forKey: "Mode")
        AppDelegate.menuBar.reset()
        AppDelegate.menuBar.update()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    }
    
    /*
    @objc private func showPopover(_ sender: AnyObject?) {
        if let button = AppDelegate.menuBar.statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    @objc private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    @objc private func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    */
    
    @objc private func onSleep(notification: NSNotification) {
        timer.suspend()
    }
    
    @objc private func onWakeUp(notification: NSNotification) {
        timer.resume()
    }
}
