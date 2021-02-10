//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

protocol MeterProtocol {
    func update(_ monitor : Monitor)
    func draw(_ pos : Double , _ color : [Double])
}

class MeterClass {
    var minContainerWidth : Double
    var containerWidth : Double
    
    init() {
        // minimum width
        minContainerWidth = (2.0 * MenuBarSettings.spacing)
                          + (2.0 * MenuBarSettings.arrowWidth)
        containerWidth = minContainerWidth
    }
}

typealias Meter = MeterClass & MeterProtocol
