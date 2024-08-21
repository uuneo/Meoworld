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
