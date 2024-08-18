//
//  Object+.swift
//  Meow
//
//  Created by He Cho on 2024/8/17.
//

import Foundation
import RealmSwift


extension Object {
    func toDictionary() -> [String: AnyObject] {
        var dicProps = [String: AnyObject]()
        self.objectSchema.properties.forEach { property in
            if property.isArray {
                var arr: [[String: AnyObject]] = []
                for obj in self.dynamicList(property.name) {
                    arr.append(obj.toDictionary())
                }
                dicProps[property.name] = arr as AnyObject
            } else if let value = self[property.name] as? Object {
                dicProps[property.name] = value.toDictionary() as AnyObject
            } else if let value = self[property.name] as? Date {
                dicProps[property.name] = Int64(value.timeIntervalSince1970) as AnyObject
            } else {
                let value = self[property.name]
                dicProps[property.name] = value as AnyObject
            }
        }
        return dicProps
    }
}
