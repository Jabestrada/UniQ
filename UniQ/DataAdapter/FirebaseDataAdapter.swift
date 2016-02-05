//
//  FirebaseDataAdapter.swift
//  UniQ
//
//  Created by Julius Estrada on 03/02/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

import UIKit

public protocol FirebaseConvertible {
    // Returns value of key field
    func getKeyValue() -> String
    
    // Returns all field values except key field
    func toAnyObject() -> AnyObject
}


public class FirebaseDataAdapter : DataAdapterProtocol  {
    // IMPORTANT: This implementation relies on the following conventions:
    // Given a dataSourceEntityName, the expected Firebase URL is:
    //    <your_Firebase_URL>/pluralized(dataSourceEntityName)
    // Thus, given a "Person" entity name, Firebase URL is <your_Firebase_URL>/Persons
    //    Note that pluralize has a crude implementation below, and should have corresponding logic in singularize()
    //    Adding a new Person record will result to the following tree:
    //    <your_Firebase_URL>/Persons
    //                          |
    //                          |- entityId [entityIdValue]
    //                               |------ firstName [firstNameValue]
    //                               |------ lastName  [lastNameValue]
    
    // TODO: Replace URL below with yours.
    static var rootUrl = "https:<YOUR_FIREBASE_URL>"
    
    // MARK: DataAdapterProtocol
    // SELECT
    public func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?, completion: (result: [T]?, error: NSError?) -> Void) {
        let fbUrl = FirebaseDataAdapter.buildUrl(dataSourceEntityName)
        let ref = Firebase(url: fbUrl)
        ref.queryOrderedByKey().observeEventType(.Value, withBlock: { snapshot in
            var newItems = [T]()
            for item in snapshot.children {
                let modelItem = FirebaseMapper.map(item as! FDataSnapshot) as T
                newItems.append(modelItem)
            }
            completion(result: newItems, error: nil)
        })
    }
    
    // INSERT
    public func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)?, completion: (newEntity: T?, error: NSError?) -> Void)
    {
        let entity = FirebaseMapper.create(dataSourceEntityName) as! T
        guard let firebirdEntity = entity as? FirebaseConvertible else {
            assertionFailure("Entity returned by FirebaseMapper.create for [\(dataSourceEntityName)] doesn't conform to FirebaseConvertible")
            return
        }
        assignValues?(entity)
        
        let ref = Firebase(url: FirebaseDataAdapter.buildUrl(dataSourceEntityName))
        let newItemRef = ref.childByAppendingPath(firebirdEntity.getKeyValue())
        newItemRef.setValue(firebirdEntity.toAnyObject()) { (error, firebase ) -> Void in
            completion(newEntity: entity, error: error)
        }
    }
    
    
    // UPDATE
    public func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void), completion: (updated: Bool, error: NSError?) -> Void)
    {
        let entity = FirebaseMapper.create(dataSourceEntityName) as! T
        guard let firebirdEntity = entity as? FirebaseConvertible else {
            assertionFailure("Entity returned by FirebaseMapper.create for [\(dataSourceEntityName)] doesn't conform to FirebaseConvertible")
            return
        }
        
        valuesAssignmentBlock(entity)
        
        if let predicate = predicate {
            // TODO: Implement buildPredicate for FirebaseDataAdapter.
        }
        
        let ref = Firebase(url: FirebaseDataAdapter.buildUrl(dataSourceEntityName))
        let existingItemRef = ref.childByAppendingPath(predicate?.rhs as! String)
        
        existingItemRef.updateChildValues(firebirdEntity.toAnyObject() as! [NSObject: AnyObject],
            withCompletionBlock: { (error, firebase) -> Void in
            completion(updated: error == nil, error: error)
        })
    }
    
    
    // DELETE
    public func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool, completion: (deleted: Bool, error: NSError?) -> Void)
    {
        
        if let predicate = predicate {
            // TODO: Implement buildPredicate for FirebaseDataAdapter.
        }
        
        let ref = Firebase(url: FirebaseDataAdapter.buildUrl(dataSourceEntityName))
        let existingItemRef = ref.childByAppendingPath(predicate?.rhs as! String)
        existingItemRef.removeValueWithCompletionBlock { (error, firebase) -> Void in
            completion(deleted: error == nil, error: error)
        }
    }
    
    
    // MARK: Helper functions
    public static func buildUrl(entityName: String) -> String {
        return "\(rootUrl)/\(pluralize(entityName))"
    }
    
    public static func pluralize(input: String) -> String {
        // TODO: Modify pluralize strategy here if needed (e.g., Loss => Losss ???)
        return input + "s"
    }
    public static func singularize(input: String) -> String{
        // TODO: As with pluralize, modify strategy if needed.
        return input.substringToIndex(input.endIndex.advancedBy(-1))
    }
    
    public static func getEntityNameFromUrl(firebaseRefUrl: String) -> String {
        // Get collection name and return in singularized form.
        var urlComponents = firebaseRefUrl.componentsSeparatedByString("/")
        var collectionName = urlComponents[urlComponents.count - 2]
        return singularize(collectionName)
    }
}
