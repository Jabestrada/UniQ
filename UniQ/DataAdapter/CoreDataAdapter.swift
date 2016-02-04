//
//  CoreDataAdapter.swift
//
//  Created by JABE on 9/26/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

import CoreData
import UIKit

public class CoreDataAdapter : DataAdapterProtocol
{
    func getCtx() -> NSManagedObjectContext{
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func buildPredicate(predicate: Predicate) -> NSPredicate {
        // TODO: Expand build predicate to handle other NSPredicate operators.
        var predicateOperator = ""
        switch predicate.op {
        case .Equals:
            predicateOperator = "=="
        default:
            assertionFailure("Predicate operator \(predicate.op) is not currently implemented.")
        }
        return NSPredicate(format: "\(predicate.lhs)\(predicateOperator)%@", argumentArray: [predicate.rhs!])
    }
    
    // Async SELECT
    public func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?, completion: (result: [T]?, error: NSError?) -> Void){
        
        var returnedObjects : [T]?
        var cdError : NSError?
        ThreadingUtil.inBackground({ () -> Void in
            var queryResult = [AnyObject]()
            let request = NSFetchRequest(entityName: dataSourceEntityName)
            if let predicate = predicate {
                request.predicate = self.buildPredicate(predicate)
            }
            if let limit = limit {
                request.fetchLimit = limit
            }
            do {
                queryResult = try self.getCtx().executeFetchRequest(request)
            }
            catch let error as NSError {
                assertionFailure("CoreDataAdapter.fetch<\(dataSourceEntityName)>: Error querying set. Details: \(error)")
                cdError = error
            }
            returnedObjects = queryResult.map({ item in item as! T })
            }) { () -> Void in
                completion(result: returnedObjects, error: cdError)
        }
    }
    
    // Async INSERT
    public func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)?,
        completion: (newEntity: T?, error: NSError?) -> Void){
            
            let ctx = self.getCtx()
            let entity = NSEntityDescription.insertNewObjectForEntityForName(dataSourceEntityName, inManagedObjectContext: ctx) as! T;
            assignValues?(entity)
            var cdError : NSError?
            ThreadingUtil.inBackground({ () -> Void in
                do {
                    try ctx.save()
                }
                catch let e as NSError {
                    cdError = e
                }
                }) { () -> Void in
                    completion(newEntity: entity, error: cdError)
            }
    }
    
    // Async UPDATE
    public func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void), completion: (updated: Bool, error: NSError?) -> Void){

        let ctx = getCtx()
        
        let request = NSFetchRequest(entityName: dataSourceEntityName)
        if let predicate = predicate {
            request.predicate = buildPredicate(predicate)
        }
        if updateOnlyOne {
            request.fetchLimit = 1
        }
        var updateOk = false
        var cdError : NSError?
        ThreadingUtil.inBackground({ () -> Void in
            do {
                let results = try ctx.executeFetchRequest(request)
                for result in results {
                    valuesAssignmentBlock(result as! T)
                }
                try ctx.save()
                updateOk = true
            }
            catch let e as NSError{
                cdError = e
            }
        
            }) { () -> Void in
                    completion(updated: updateOk, error: cdError)
        }
    }
    
    // Async DELETE
    public func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool, completion: (deleted: Bool, error: NSError?) -> Void) {
        let ctx = getCtx()

        let request = NSFetchRequest(entityName: dataSourceEntityName)
        if let predicate = predicate {
            request.predicate = buildPredicate(predicate)
        }
        if deleteOnlyOne {
            request.fetchLimit = 1
        }
        
        var deletedCount = 0;
        var cdError : NSError?
        ThreadingUtil.inBackground({ () -> Void in
            do {
                let results = try ctx.executeFetchRequest(request)
                for result in results {
                    deletedCount++
                    ctx.deleteObject(result as! NSManagedObject)
                    if deleteOnlyOne {
                        break
                    }
                }
                try ctx.save()
            } catch let e as NSError{
                cdError = e
            }
            }) { () -> Void in
                completion(deleted: deletedCount > 0, error: cdError)
        }
    }

}
