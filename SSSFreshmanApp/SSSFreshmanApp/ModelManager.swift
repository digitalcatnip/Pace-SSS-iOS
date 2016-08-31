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
    
    func saveModel(model: Object) {
        try! realm.write {
            self.realm.add(model, update: true)
        }
    }
    
    func saveModels(models: [Object]) {
        try! realm.write {
            for model in models {
                self.realm.add(model, update: true)
            }
        }
    }
    
    func query(type: Object.Type, queryString: NSPredicate?) -> Results<Object> {
        if queryString != nil {
            return realm.objects(type).filter(queryString!)
        } else {
            return realm.objects(type)
        }
    }
}
