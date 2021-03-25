import UIKit
import Foundation

class ViewController: UIViewController {

    let dectetor: NetServiceBrowser = NetServiceBrowser()
    
    var smbServices: [NetService] = [NetService]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    
    /*
     Be sure to set _smb._tcp in info.plist
     */
    
    override func viewDidAppear(_ animated: Bool) {
        dectetor.delegate = self
        dectetor.includesPeerToPeer = false
        dectetor.searchForServices(ofType: "_smb._tcp.", inDomain: "local.")
    }
}


extension ViewController: NetServiceBrowserDelegate{
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        debugPrint("will Search")
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        debugPrint("Discoverred service\(service.name), resolving....")
        service.delegate = self
        service.resolve(withTimeout: 3)
        smbServices.append(service)
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        debugPrint("stop search")
    }
    
}


extension ViewController: NetServiceDelegate{
    func netServiceDidStop(_ sender: NetService) {
        debugPrint("NetServiceDelegate did stop")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        debugPrint("failed to resolve: \(errorDict)")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let data = sender.addresses?.first else { return }
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        data.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> Void in
                let sockaddrPtr = pointer.bindMemory(to: sockaddr.self)
                guard let unsafePtr = sockaddrPtr.baseAddress else { return }
                guard getnameinfo(unsafePtr, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                    return
                }
            }
        let ipAddress = String(cString:hostname)
        debugPrint("service:\(sender.name), address: \(ipAddress)")
        
    }
}
