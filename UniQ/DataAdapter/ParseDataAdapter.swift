//
//  ParseDataAdapter.swift
//  myEats
//
//  Created by JABE on 11/3/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

//import Parse
import Foundation

public class ParseDataAdapter: DataAdapterProtocol {

    // Async SELECT
    public func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?, completion: (result: [T]?, error: NSError?) -> Void){
        
        var objects = [PFObject]()
        let query = PFQuery(className: dataSourceEntityName)
        
        if let sortDescriptors = sortDescriptors {
            query.orderBySortDescriptors(sortDescriptors)
        }
        
        var predLhs = ""
        var predRhs = ""
        var predIsEquals = false
        if let predicate = predicate {
            buildPredicate(query, predicate: predicate)
            predLhs = predicate.lhs
            predRhs = predicate.rhs as! String
            predIsEquals = predicate.op == PredicateOperator.Equals
        }
        
        var pfError : NSError?
        ThreadingUtil.inBackground({ () -> Void in
            do {
                // Parse has special handling for key field (getObjectWithId)
                if self.isParseKeyField(predLhs) && predIsEquals {
                    objects.append(try query.getObjectWithId(predRhs))
                }
                else {
                    objects = try query.findObjects()
                }
            }
            catch let e as NSError {
                pfError = e
                print("Error with ParseDataAdapter.fetch(\(dataSourceEntityName)): \(e)")
            }
            }) { () -> Void in
                completion(result: objects.map({item in item as! T}), error: pfError)
        }
    }
    
    // ASYNC INSERT
    public func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)?,
        completion: (newEntity: T?, error: NSError?) -> Void){
            let newObject = PFObject(withoutDataWithClassName: dataSourceEntityName, objectId: nil)
            let newObjectAsT = newObject as! T
            assignValues?(newObjectAsT)
            newObject.saveInBackgroundWithBlock { (saved, error) -> Void in
                completion(newEntity: newObject as? T, error: error)
            }
    }
    
    
    // ASYNC UPDATE
    public func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void), completion: (updated: Bool, error: NSError?) -> Void){
        let query = PFQuery(className: dataSourceEntityName)
        if let predicate = predicate {
            buildPredicate(query, predicate: predicate)
        }
        
        query.findObjectsInBackgroundWithBlock {(results, error) -> Void in
            var updated = false
            var counter = 0
            var total = 0
            let updateGroup  = dispatch_group_create()
            if error == nil {
                if let results = results {
                    total = results.count
                    for result in results {
                        valuesAssignmentBlock(result as! T)
                        dispatch_group_enter(updateGroup)
                        result.saveInBackgroundWithBlock({ (saved, error) -> Void in
                            counter++
                            dispatch_group_leave(updateGroup)
                        })
                        if (updateOnlyOne){
                            break
                        }
                    }
                }
            }
            dispatch_group_notify(updateGroup, dispatch_get_main_queue(), { () -> Void in
                updated = total > 0 &&
                    updateOnlyOne ? counter == 1 : total == counter
                completion(updated: updated, error: error)
            })
        }
        
        
    }
    
    // ASYNC DELETE
    public func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool, completion: (deleted: Bool, error: NSError?) -> Void) {

        let query = PFQuery(className: dataSourceEntityName)
        if let predicate = predicate {
            buildPredicate(query, predicate: predicate)
        }
        query.findObjectsInBackgroundWithBlock {(results, error) -> Void in
            var deleted = false
            var counter = 0
            var total = 0
            let deleteGroup = dispatch_group_create()
            if error == nil {
                if let results = results {
                    total = results.count
                    for result in results {
                        dispatch_group_enter(deleteGroup)
                        result.deleteInBackgroundWithBlock({ (deleted, error) -> Void in
                             counter++
                             dispatch_group_leave(deleteGroup)
                        })
                        if (deleteOnlyOne){
                            break
                        }
                    }
                }
            }
            dispatch_group_notify(deleteGroup, dispatch_get_main_queue(), { () -> Void in
                deleted = total > 0 &&
                          deleteOnlyOne ? counter == 1 : total == counter
                completion(deleted: deleted, error: error)
            })
        }

    }
    
    
    // MARK: Predicate helpers
    private func isParseKeyField(fieldName: String) -> Bool {
        return fieldName == "id" || fieldName == "objectId"
    }
    
    private func buildPredicate(query: PFQuery, predicate: Predicate) {
        if predicate.op == .NearGeo {
            if let locationPredicateValue = predicate.rhs as? JLLocationPredicateValue {
                let geoPoint = PFGeoPoint(latitude: locationPredicateValue.latitude, longitude: locationPredicateValue.longitude)
                query.whereKey(predicate.lhs, nearGeoPoint: geoPoint, withinMiles: locationPredicateValue.withinMiles)
            }
            else {
                assertionFailure("ParseDataAdapter.buildPredicate: rhs is not of type JLLocationPredicateValue and op is .NearGeo")
            }
        }
        else {
            if (isParseKeyField(predicate.lhs) && predicate.op == .Equals){
                // JABE, 11/9/2015: Ignore predicate if lhs is a key field (id, objectId, etc.) due to Parse's internal behavior of failing in conditions 
                // such as the one below. In which case, defer find strategy to query.getObjectWithId
                // query.whereKey("id", equalTo: predicate.rhs! as? String)
            }
            else {
                switch predicate.op {
                case .Equals:
                    query.whereKey(predicate.lhs, equalTo: predicate.rhs!)
                    break;
                case .NotEquals:
                    if isParseKeyField(predicate.lhs){
                        // JABE, Nov. 30, 2015: Can't make condition below work. Problem is basically where id != <parameter id>
                        query.whereKeyDoesNotExist(predicate.rhs as! String)
                    }
                    else {
                        query.whereKey(predicate.lhs, notEqualTo: predicate.rhs!)
                    }
                    break;
                case .Contains:
                    query.whereKey(predicate.lhs, containsString: predicate.rhs as? String)
                    break;
                case .LessThan:
                    query.whereKey(predicate.lhs, lessThan: predicate.rhs!)
                    break;
                default:
                    assertionFailure("ParseDataAdapter.buildPredicate >> Predicate not handled: \(predicate.op)")
                    break;
                }

            }
        }
    }
    
    private func buildPredicate(query: PFQuery, predicateGroup: PredicateGroup){
        buildPredicate(query, predicate: predicateGroup.predicate1)
        if let predicate2 = predicateGroup.predicate2 {
            buildPredicate(query, predicate: predicate2)
        }
        if let outerPredicateGroup = predicateGroup.outerPredicateGroup {
            buildPredicate(query, predicateGroup: outerPredicateGroup)
        }
    }
    
    
    
}




