//
//  bookManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/14.
//

import Foundation
import Contacts
import ContactsUI

class bookManager:ObservableObject{
    
    let shared = bookManager()
    var contact = CNContactStore()
    
    func requestAccess()  {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .notDetermined:
            contact.requestAccess(for: .contacts){state,error in
                
                print(state)
            }
        case .restricted:
            print("权限限制")
        case .denied:
            print("用户已经拒绝")
        case .authorized:
            print("已经授权")
        @unknown default:
            print("其他情况")
        }
        
        
    }
    
}
