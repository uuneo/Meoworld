//
//  CallManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/19.
//

import Foundation
import CallKit
import UIKit
import AVFoundation



class CallManager: NSObject {
    
    // 1
    static let shared = CallManager()

    // 2
    private let provider: CXProvider
    
    // 3
    private let callController = CXCallController()


    override init() {
        provider = CXProvider(configuration: CXProviderConfiguration.custom)

        super.init()

        // If the queue is `nil`, delegate will run on the main thread.
        provider.setDelegate(self, queue: nil)
    }

    // 3
    func reportIncomingCall(uuid: UUID, sender: String, hasVideo: Bool, completionHandler: ((NSError?) -> Void)? = nil) {

        // Update call based on DirectCall object
        let update = CXCallUpdate()

        // 4. Informations for iPhone local call log
//        let callerID = call.caller?.userId ?? "Unknown"
        update.remoteHandle = CXHandle(type: .generic, value: sender)
        update.localizedCallerName = sender
        update.hasVideo = hasVideo

        // 5. Report new incoming call and add it to `callManager.calls`
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            guard error == nil else {
                completionHandler?(error as NSError?)
                return
            }
            debugPrint(uuid.uuidString)
        }
    }

    // 7
    func endCall(uuid: UUID,endedAt: Date, reason: CXCallEndedReason) {
        // 获取当前正在进行的通话ID
        
        let activeCalls = self.callController.callObserver.calls.filter { $0.uuid == uuid}
        guard let call = activeCalls.first else {
            debugPrint("No active call to end.")
            return
        }

        // 创建结束通话的操作
        let endCallAction = CXEndCallAction(call: call.uuid)

        // 创建一个请求对象，并添加结束通话的操作
        let transaction = CXTransaction(action: endCallAction)

        // 请求执行事务
        callController.request(transaction) { error in
            if let error = error {
                print("Failed to end call: \(error)")
            } else {
                print("Successfully ended call.")
            }
        }
        self.provider.reportCall(with: call.uuid, endedAt: endedAt, reason: reason)
    }
}


// ProviderDelegate.swift
extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        // Stop audio
        // End all calls because they are no longer valid
        // Remove all calls from the app's list of call
        debugPrint("providerDidReset 1")

    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // Get call object
        // Configure audio session
        // Add call to  `callManger.callIDs`.
        // Report connection started

        action.fulfill()
        debugPrint("2")
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // Configure audio session
        // Accept call
        // Notify incoming call accepted

        action.fulfill()
        debugPrint("电话接通")
        
    
    }
    
    // 拒接通话
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Mute the call
        // End the call

        action.fulfill()
        debugPrint("拒接通话/挂断电话")
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // update holding state.
        // Mute the call when it's on hold.
        // Stop the video when it's a video call.

        action.fulfill()
        debugPrint("5")
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // stop / start audio

        action.fulfill()
        debugPrint("6")
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Start audio
        debugPrint("7")
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // Restart any non-call related audio now that the app's audio session has been
        // de-activated after having its priority restored to normal.
        debugPrint("8")
    }
}
