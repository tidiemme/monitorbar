//------------------------------------------------------------------------------
// This file is part of Monitor Bar. Copyright (c) tidiemme.
// You should have received a copy of the MIT License along with Monitor Bar.
// If not see <https://opensource.org/licenses/MIT>.
//------------------------------------------------------------------------------
// Some code taken from @D0miH https://github.com/iglance/iGlance
//------------------------------------------------------------------------------

import Foundation

class Monitor {
    private var prevCpuInfo = processor_info_array_t(nil)
    private var prevCpuInfoCnt = mach_msg_type_number_t(0)
    
    func batteryCurrentCapacity() -> Int {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for source in sources {
            if let description = IOPSGetPowerSourceDescription(snapshot, source).takeUnretainedValue() as? [String: Any] {
                if description["Type"] as? String == kIOPSInternalBatteryType {
                    return description[kIOPSCurrentCapacityKey] as? Int ?? 0
                }
            }
        }
        return 0
    }
    
    func batteryPlugged() -> Bool {
        let timeRemaining: CFTimeInterval = IOPSGetTimeRemainingEstimate()
        if timeRemaining == -2.0 {
            return true
        }
        return false
    }
    
    static func cpuCount() -> natural_t {
        var cpuCount = natural_t(0)
        var cpuInfo : UnsafeMutablePointer<integer_t>!
        var cpuInfoCnt = mach_msg_type_number_t(0)
        
        let res = host_processor_info(mach_host_self()
                                     ,PROCESSOR_CPU_LOAD_INFO
                                     ,&cpuCount
                                     ,&cpuInfo
                                     ,&cpuInfoCnt);
        if res != KERN_SUCCESS {
            print("Error! host_processor_info failed")
            return 0
        }
        return cpuCount
    }
    
    func cpuUsage() -> ([Double], Double) {
        var cpuCount = natural_t(0)
        var cpuInfo : UnsafeMutablePointer<integer_t>!
        var cpuInfoCnt = mach_msg_type_number_t(0)
        
        let res = host_processor_info(mach_host_self()
                                     ,PROCESSOR_CPU_LOAD_INFO
                                     ,&cpuCount
                                     ,&cpuInfo
                                     ,&cpuInfoCnt);
        if res != KERN_SUCCESS {
            print("Error! host_processor_info failed")
            return ([], 0.0)
        }
        
        var cpus = [Double]()
        var inUse = Int32(0)
        var total = Int32(0)
        var usage = Double(0.0)
        var totUsage = Double(0.0)
        
        if let prevCpuInfo = prevCpuInfo {
            for i in 0 ..< Int32(cpuCount) {
                inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)] - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)] - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                        + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)] - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                total = inUse
                      + (cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)] - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)])
                usage = 100.0 * Double(inUse) / Double(total)
                totUsage += usage
                cpus.append(usage)
            }
            let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(prevCpuInfoCnt)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
        } else {
            for _ in 0 ..< Int32(cpuCount) {
                cpus.append(0.0)
            }
            usage = Double(cpuCount)
        }
            
        prevCpuInfo = cpuInfo
        prevCpuInfoCnt = cpuInfoCnt
        cpuInfo = nil
        cpuInfoCnt = 0;
        
        return (cpus, totUsage/Double(cpuCount))
    }
    
    // tot, used, file cached
    func memUsage() -> (Double, Double, Double) {
        let host_port: host_t = mach_host_self()
        
        var pagesize: vm_size_t = 0
        host_page_size(host_port, &pagesize)
        
        var hostInfoSize: mach_msg_type_number_t = mach_msg_type_number_t(UInt32(MemoryLayout<host_basic_info>.size / MemoryLayout<integer_t>.size))
        var hostInfoData: host_basic_info = host_basic_info.init()
        let resHI = withUnsafeMutablePointer(to: &hostInfoData) {
            (p:UnsafeMutablePointer<host_basic_info>) -> Bool in
            return p.withMemoryRebound(to: integer_t.self, capacity: Int(hostInfoSize)) {
                (pp:UnsafeMutablePointer<integer_t>) -> Bool in
                let retvalue = host_info(host_port, HOST_BASIC_INFO, pp, &hostInfoSize)
                return retvalue == KERN_SUCCESS
            }
        }
        if !resHI {
            print("Error! host_info failed")
            return (0.0, 0.0, 0.0)
        }
 
        var hostStatistics64Size: mach_msg_type_number_t = mach_msg_type_number_t(UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size))
        var hostStatistics64Data: vm_statistics64 = vm_statistics64.init()
        let resb = withUnsafeMutablePointer(to: &hostStatistics64Data) {
            (p:UnsafeMutablePointer<vm_statistics64>) -> Bool in
            return p.withMemoryRebound(to: integer_t.self, capacity: Int(hostStatistics64Size)) {
                (pp:UnsafeMutablePointer<integer_t>) -> Bool in
                let retvalue = host_statistics64(host_port, HOST_VM_INFO64, pp, &hostStatistics64Size)
                return retvalue == KERN_SUCCESS
            }
        }
        if !resb {
            print("Error! host_processor_info failed")
            return (0.0, 0.0, 0.0)
        }
        
        let tot = Double(hostInfoData.max_mem)
        //let free = Double(hostStatistics64Data.free_count) * Double(pagesize)// / Unit.megabyte.rawValue)
        //let active = Double(hostStatistics64Data.active_count) * Double(pagesize) // / Unit.megabyte.rawValue) / 1000.0
        //let inactive = Double(hostStatistics64Data.inactive_count) * Double(pagesize)// / Unit.megabyte.rawValue) / 1000.0
        let wired = Double(hostStatistics64Data.wire_count) * Double(pagesize)// / Unit.megabyte.rawValue) / 1000.0
        let compressed = Double(hostStatistics64Data.compressor_page_count) * Double(pagesize)//  / Unit.megabyte.rawValue) / 1000.0
        let appMem = Double(hostStatistics64Data.internal_page_count
                   - hostStatistics64Data.purgeable_count)
                   * Double(pagesize)
        let cached = Double(hostStatistics64Data.external_page_count + hostStatistics64Data.purgeable_count) * Double(pagesize)
        //let swap = Double(hostStatistics64Data.swapouts - hostStatistics64Data.swapins) * Double(pagesize)
        //let f = tot - free
        //print(tot, free, active, inactive, wired, compressed)
        let used = (appMem + wired + compressed)
        //print("A:", appMem / Unit.gigabyte.rawValue
        //     ," W: ", wired / Unit.gigabyte.rawValue
        //     ," C: ", compressed / Unit.gigabyte.rawValue
        //     ," U: ", used / Unit.megabyte.rawValue
        //     ," Cached: ", cached / Unit.gigabyte.rawValue
        //     ," Swap: ", swap / Unit.gigabyte.rawValue
        //     ," T: ", tot / Unit.megabyte.rawValue)
        return (tot, used, cached)
    }
    
    // Size, Free
    func diskUsage() -> (Int64?, Int64?) {
        let totalSpaceInBytes = getFileSize(for: .systemSize)
        let freeSpaceInBytes = getFileSize(for: .systemFreeSize)
        return (totalSpaceInBytes, freeSpaceInBytes)
    }
    
    private func getFileSize(for key: FileAttributeKey) -> Int64? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)

        guard
            let lastPath = paths.last,
            let attributeDictionary = try? FileManager.default.attributesOfFileSystem(forPath: lastPath) else { return nil }

        if let size = attributeDictionary[key] as? NSNumber {
            return size.int64Value
        } else {
            return nil
        }
    }
    
    func currentNetworkInterface() -> String {
        guard let commandOutput = executeCommand(
            launchPath: "/bin/bash",
            arguments: ["-c", "route get 0.0.0.0 2>/dev/null | grep interface: | awk '{print $2}'"]
        ) else {
            print("An error occurred while executing the command to get the currently used network interface")
            return "en0"
        }
        let interfaceName = commandOutput.trimmingCharacters(in: .whitespacesAndNewlines)
        return interfaceName.isEmpty ? "en0" : interfaceName
    }
    
    func getIp(_ interface: String) -> String {
        var address = String()

        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return address }
        guard let firstAddr = ifaddr else { return address }

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee

            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) { //|| addr.sa_family == UInt8(AF_INET6) {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let interfaceName =  String.init(cString: &ptr.pointee.ifa_name.pointee)
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        if (ptr.pointee.ifa_addr != nil && interfaceName == interface) {
                            address = String(cString: hostname)
                        }
                    }
                }
            }
        }

        freeifaddrs(ifaddr)
        return address
    }
    
    func getTotalTransmittedBytesOf(_ interface: String) -> (up: UInt64, down: UInt64) {
        guard let commandOutput = executeCommand(launchPath: "/usr/bin/env", arguments: ["netstat", "-bdnI", interface]) else {
            print("An error occurred while executing the netstat command")
            return (up: 0, down: 0)
        }
        let lowerCaseOutput = commandOutput.lowercased()
        let lines = lowerCaseOutput.split(separator: "\n")
        if lines.count <= 1 {
            print("Something went wrong while parsing the network bandwidth command output")
            return (up: 0, down: 0)
        }
        guard let regex = try? NSRegularExpression(pattern: "/ +/g") else {
            print("Failed to create the regex")
            return (up: 0, down: 0)
        }
        let firstLine = String(lines[1])
        let cleanedFirstLine = regex.stringByReplacingMatches(in: firstLine, options: [], range: NSRange(location: 0, length: firstLine.count), withTemplate: " ")
        let columns = cleanedFirstLine.split(separator: " ")
        guard let totalDownBytes = UInt64(String(columns[6])), let totalUpBytes = UInt64(String(columns[9])) else {
            print("Something went wrong while retrieving the down- and uploaded bytes")
            return (up: 0, down: 0)
        }
        return (up: totalUpBytes, down: totalDownBytes)
    }
}
