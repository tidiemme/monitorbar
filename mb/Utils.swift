//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------
// Some code taken from @D0miH https://github.com/iglance/iGlance
//------------------------------------------------------------------------------

import Foundation
import SwiftUI

enum Unit : Double {
    case byte     = 1.0
    case kilobyte = 1024.0
    case megabyte = 1048576.0
    case gigabyte = 1073741824.0
}
    
enum ByteUnit: String, Comparable, CaseIterable {
    static func < (lhs: ByteUnit, rhs: ByteUnit) -> Bool {
        let caseArray = self.allCases

        var lhsIndex: Int?
        var rhsIndex: Int?
        for index in 0..<caseArray.count {
            if caseArray[index] == lhs {
                lhsIndex = index
            }
            if caseArray[index] == rhs {
                rhsIndex = index
            }
        }

        if lhsIndex == nil || rhsIndex == nil {
            print("Something went wrong while comparing the two ByteUnits \(lhs) and \(rhs)")
            return false
        }

        return lhsIndex! < rhsIndex!
    }

    case Byte = "B"
    case Kilobyte = "KB"
    case Megabyte = "MB"
    case Gigabyte = "GB"
    case Terabyte = "TB"
    case Petabyte = "PB"
    case Exabyte = "EB"
}

func executeCommand(launchPath: String, arguments: [String]) -> String? {
    let task = Process()
    let outputPipe = Pipe()

    // execute the command
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = outputPipe
    task.launch()
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: outputData, encoding: String.Encoding.utf8) else {
        print("An error occurred while casting the command output to a string")
        return nil
    }

    task.waitUntilExit()

    return output
}

func convertToCorrectUnit(bytes: UInt64) -> (value: Double, unit: ByteUnit) {
    if bytes < 1000 {
        return (value: Double(bytes), unit: ByteUnit.Byte)
    }
    let exp = Int(log2(Double(bytes)) / log2(1000.0))
    let unitString = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
    let unit = ByteUnit(rawValue: unitString) ?? ByteUnit.Gigabyte
    let number = Double(bytes) / pow(1000, Double(exp))

    return (value: number, unit: unit)
}
