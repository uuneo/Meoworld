//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by He Cho on 2024/8/8.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        self.preferredContentSize = CGSize(width: self.view.frame.width, height: 100)
    }
    
    

    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        
        if userInfo["autocopy"] as? String == "1"  || userInfo["automaticallycopy"] as? String == "1"{
            if let copy = userInfo["copy"] as? String {
                UIPasteboard.general.string = copy
            }
            else {
                UIPasteboard.general.string = notification.request.content.body
            }
        }
        
        if let imageUrl = userInfo["image"] as? String{
            Task{
               
                if let imageFileUrl = await ImageManager.downloadImage(imageUrl),
                   let image = UIImage(contentsOfFile: imageFileUrl){
                    let viewWidth = self.view.frame.width
                    let aspectRatio = image.size.width / image.size.height
                    let viewHeight = viewWidth / aspectRatio
                    DispatchQueue.main.async { [weak self] in
                        if let self = self{
                            imageView.image = image
                            self.imageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
                            self.preferredContentSize = CGSize(width: viewWidth, height: viewHeight)
                        }
                        
                    }
                }
            }
            
        }else{
            self.preferredContentSize = CGSize(width: 0, height: 0)
        }
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        
        let userInfo = response.notification.request.content.userInfo
        
        
        switch response.actionIdentifier{
            
        case Identifiers.detailAction:
            completion(.dismissAndForwardAction)
            
        case Identifiers.copyAction:
            if let copy = userInfo["copy"] as? String {
                UIPasteboard.general.string = copy
            }
            else {
                UIPasteboard.general.string = response.notification.request.content.body
            }
            completion(.dismiss)
        default:
            completion(.dismiss)
        }
        
        
    }
}
