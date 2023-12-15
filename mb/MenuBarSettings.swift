//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation

class MenuBarSettings {
    static let menubarHeight = 18.0
    static let menubarHalfHeight = 18.0 / 2.0
    static let spacing = 4.0
    static let spacingCompact = 2.0
    static let arrowWidth = 18.0 / 2.0
    static let textY = 2.0
    static let percentageY = 3.0
    static let dateFormatter = DateFormatter()
    static let circleIconWidth = 10.0
    static let circleIconHeight = 10.0
    
    static let cpuBarY = 3.0
    static let cpuBarWidth = 5.0
    static let cpuBarWidthCompact = 9.0
    static let cpuBarHeight = 12.0

    static let netIconWidth = 18.0 / 2.0
    static let netIpIconWidth = 18.0

    static var smallStringMaxSize = 0.0
    static var normalStringMaxSize = 0.0
    
    static var themes = [ThemePalette, ThemeBlue, ThemeVerde]

    // :TODO: load from config
    static var theme = 0
    static var itemsSpacing = 1.0
    
    enum Mode : Int {
        case compact = 1
        case normal = 2
        case extra = 3
    }

    static var mode = 2
    
    func initialise() {
        MenuBarSettings.mode = UserDefaults.standard.integer(forKey: "Mode")
        if MenuBarSettings.mode < 1 {
           MenuBarSettings.mode = 2 // default to normal
        }
        MenuBarSettings.dateFormatter.dateFormat = "E d MMM HH:mm"
        
        let smallSize = NSAttributedString(string: String(format: "000 KB/s")
                                         ,attributes: StringAttribute.small)
        MenuBarSettings.smallStringMaxSize = Double(smallSize.size().width)
        let normalSize = NSAttributedString(string: String(format: "999%")
                                         ,attributes: StringAttribute.normal)
        MenuBarSettings.normalStringMaxSize = Double(normalSize.size().width)
    }
}
