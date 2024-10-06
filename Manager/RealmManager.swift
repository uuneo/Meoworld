//
//  RealmManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation
@_exported import RealmSwift


class RealmManager: NSObject,ObservableObject {
    static let shared = RealmManager()
    var realm: Realm?

    private override init() {
        realm = try? Realm()
		realm?.invalidate()
    }
    
  
    private func _realmHandler(_ complate: @escaping (_ realm: Realm) -> Void){
        if let realm = realm{
            try? realm.write {
                complate(realm)
            }
        }
    }
    
    func readMessage(id: String? = nil, group: String? = nil){
        
        
        self._realmHandler { realm in
            if let id = id{
                
                if  let item =  realm.objects(Message.self).where({ $0.id == id }).first{
                    item.read = true
                }
            }else if let group = group{
                
                let data =  realm.objects(Message.self).where({ $0.group == group && !$0.read })
                for item in data{
                    item.read = true
                }
            }else{
                let data =  realm.objects(Message.self).where({!$0.read})
                for item in data{
                    item.read = true
                }
            }
            
            
        }
        
    }
    
    func delete(id:String? = nil, group:String? = nil, less date:Date? = nil, read:Bool? = nil){
        
        self._realmHandler { realm in
            if let id = id {
                let item = realm.objects(Message.self).where({$0.id == id})
                realm.delete(item)
            } else if let group = group {
                let items =  realm.objects(Message.self).where({$0.group == group})
                realm.delete(items)
            }else if let date = date {
                let  items = realm.objects(Message.self).where({$0.createDate < date})
                realm.delete(items)
            } else if let read = read{
                let item = realm.objects(Message.self).where({$0.read == read})
                realm.delete(item)
            }else {
                realm.deleteAll()
            }
            
        }
        
    }
    
    func write(messages:[Message]){
        self._realmHandler { realm in
            for item in messages{
                realm.add(item)
            }
        }
    }
    
    func NReadCount(group:String? = nil)-> Int{
        if let group = group{
            return realm?.objects(Message.self).where({$0.group == group && !$0.read}).count ?? 0
        }else{
            return realm?.objects(Message.self).where({!$0.read}).count ?? 0
        }
       
    }
    
	func exportFiles(_ items:Results<Message>, completion: @escaping ((URL?,String?)-> Void)){
		
		Task.detached(priority: .high){
			do{
				let messages = Array(items)
				let jsonData = try JSONEncoder().encode(messages)
				
				let fileManager = FileManager.default
				let tempDirectoryURL = fileManager.temporaryDirectory
				let fileName = "meow_\(Date().formatString(format: "yyyy_MM_dd_HH_mm_ss")).json"
				let linkURL = tempDirectoryURL.appendingPathComponent(fileName)
				
				try jsonData.write(to: linkURL)
				
				await MainActor.run {
					completion(linkURL,NSLocalizedString("exportSuccess", comment: ""))
				}
				
				
			} catch {
#if DEBUG
				print("errors: \(error.localizedDescription)")
#endif
				await MainActor.run {
					completion(nil, error.localizedDescription)
				}
			}
			
		}
		
		
	}



}


