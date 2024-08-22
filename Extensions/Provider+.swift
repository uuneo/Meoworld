//
//  Provider+.swift
//  Meow
//
//  Created by He Cho on 2024/8/19.
//

import Foundation
import CallKit
import UIKit

extension CXProviderConfiguration {
    static var custom: CXProviderConfiguration {
    // 1
    let configuration = CXProviderConfiguration()

    // 2
    // Native call log shows video icon if it was video call.
    configuration.supportsVideo = true

    // Support generic type to handle *User ID*
    configuration.supportedHandleTypes = [.generic]

    // Icon image forwarding to app in CallKit View
    if let iconImage = UIImage(named: "logo_png") {
        configuration.iconTemplateImageData = iconImage.pngData()
    }
    return configuration
    }
}


extension CXProvider {
    // To ensure initializing only at once. Lazy stored property doesn't ensure it.
    static var custom: CXProvider {
        
        // Configure provider with sendbird's customzied configuration.
        let configuration = CXProviderConfiguration.custom
        let provider = CXProvider(configuration: configuration)
        
        return provider
    }
}


extension CXCallUpdate {
    func update(with remoteUserID: String, hasVideo: Bool, incoming: Bool) {
        // the other caller is identified by a CXHandle object
        let remoteHandle = CXHandle(type: .generic, value: remoteUserID)
        
        self.remoteHandle = remoteHandle
        self.localizedCallerName = remoteUserID
        self.hasVideo = hasVideo
    }
    
    func onFailed(with uuid: UUID) {
        let remoteHandle = CXHandle(type: .generic, value: "Unknown")
        
        self.remoteHandle = remoteHandle
        self.localizedCallerName = "Unknown"
        self.hasVideo = false
    }
}


typealias ErrorHandler = ((NSError?) -> ())


extension Notification.Name {
    static let DidCallEnd = Notification.Name("DidCallEnd")
    static let DidCallAccepted = Notification.Name("DidCallAccepted")
}



