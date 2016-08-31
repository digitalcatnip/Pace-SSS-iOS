//
//  ModelManager.swift
//  Pace SSS
//
//  Created by James McCarthy on 8/31/16.
//  Copyright © 2016 Digital Catnip. All rights reserved.
//

import RealmSwift


class ModelManager {
    static let sharedInstance = ModelManager()
    var realm = try! Realm()
    
    func saveModel(model: BaseObject) {
        try! realm.write {
            self.realm.add(model, update: true)
        }
    }
    
    func saveModels(models: [BaseObject]) {
        try! realm.write {
            for model in models {
                self.realm.add(model, update: true)
            }
        }
    }
    
    func deleteModels(models: [BaseObject]) {
        try! realm.write {
            for object in models {
                self.realm.delete(object)
            }
        }
    }
    
    func query<T>(type: T.Type, queryString: NSPredicate?) -> Results<T> {
        if queryString != nil {
            return realm.objects(type).filter(queryString!)
        } else {
            return realm.objects(type)
        }
    }
}
