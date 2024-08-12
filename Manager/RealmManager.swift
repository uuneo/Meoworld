//
//  RealmManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation
import RealmSwift


class RealmManager{
    static let shared = RealmManager()
    var realm: Realm?

    private init() {
        realm = try? Realm()
    }
    
    func getUnreadCount()-> Int?{
        return self.getObject()?.where({!$0.read}).count
    }
    
    
    func getGroupCount(_ groupName:String)-> Int{
        return self.getObject()?.count ?? 0
    }

    // Create
    func addObject(_ object: Message) -> Bool {
        guard let realm = realm else { return false }
        do {
            try realm.write {
                realm.add(object)
            }
            return true
        } catch {
            return false
        }
    }

    // Read
    func getObject() -> Results<Message>? {
        guard let realm = realm else { return nil }
        return realm.objects(Message.self)
    }
    
    
    func getReadGroupCount(group:String?) -> Int {
        
        guard let group = group else { return 0 }
        
        guard let realm = realm else { return 0 }
        return realm.objects(Message.self).where{$0.group == group}.where{!$0.read}.count
        
    }
    
    
    
    
    
    
    
    

    // Update
    func updateObject(_ object: Message, with updates: (Message) -> Void) -> Bool {
        guard let realm = realm else { return false }
        do {
            try realm.write {
                let objectToUpdate = object.isFrozen ? object.thaw() : object
                if let objectToUpdate = objectToUpdate {
                    updates(objectToUpdate)
                }
            }
            return true
        } catch {
            return false
        }
    }
    
    func readMessage(_ results: Results<Message>){
        let _ = self.updateObjects(results) { value in
            if let read = value?.read,!read{
                value?.read = true
            }
        }
    }
    func readMessage(group: String){
        let res = realm?.objects(Message.self).where({$0.group == group})
        if let messages = res{
            self.readMessage(messages)
        }
    }
    
    
    
    
    
    
    
    
    func updateObjects(_ results: Results<Message>?, with updates: (Message?) -> Void) -> Bool {
        guard let realm = realm else { return false }
        
        if let datas = results{
            do {
                try realm.write {
                    for object in datas {
                        let data = realm.objects(Message.self).where({$0.id == object.id}).first
                        updates(data)
                    }
                }
                return true
            } catch {
                return false
            }
        }
        return false
        
    }

    // Delete
    func deleteObject(_ object: Message?) -> Bool {
        guard let realm = realm else { return false }
        if let data = object{
            do {
                try realm.write {
                    let item = realm.objects(Message.self).where({$0.id == data.id})
                    realm.delete(item)
                }
                return true
            } catch {
                return false
            }
        }
       return false
    }
    
    func deleteObjects<T: Object>(_ objects: Results<T>?) -> Bool {
        guard let realm = realm else { return false }
        if let datas = objects{
            do {
                try realm.write {
                    realm.delete(datas)
                }
                return true
            } catch {
                return false
            }
        }
       return false
    }
    
    func allRead(){
        let alldata = self.getObject()?.where({!$0.read})
        let _ = self.updateObjects(alldata){data in
            data?.read = true
        }
    }
    
    func allDel(_ mode: Int = 0) {
        switch mode {
        case 0:
            let alldata = self.getObject()?.where({$0.read})
            let _ = self.deleteObjects(alldata)
        case 1:
            let alldata = self.getObject()?.where({!$0.read})
            let _ = self.deleteObjects(alldata)
        case 3:
            let _ = self.deleteObjects(self.getObject())
        default:
            break
        }
    }
    
    func delByGroup(_ group:String){
        let datas = self.getObject()?.where({$0.group == group})
        let _ = self.deleteObjects(datas)
    }
    
    func createMessage(message:Message){
        guard let realm = realm else { return }
        
        do{
            try realm.write{
                realm.add(message)
            }
        }catch{
            debugPrint(error)
        }
    }
    
    func allGroupNames()-> [String] {
        guard let realm = realm else{return []}
        let allKeys =  realm.objects(Message.self).sectioned(by: \.group,ascending: true).allKeys
        return allKeys.compactMap{ $0 }
    }
}
