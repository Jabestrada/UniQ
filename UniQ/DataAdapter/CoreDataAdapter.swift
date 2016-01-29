//
//  CoreDataAdapter.swift
//
//  Created by JABE on 9/26/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

import CoreData


public class CoreDataAdapter : DataAdapterProtocol
{
    func getCtx() -> NSManagedObjectContext{
        // JABE, Nov. 11, 2015: Return dummy instance of NSManagedObjectContext since AppDelegate.managedObjectContext is only available
        // in XCode projects with CoreData during project creation.
//        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        return NSManagedObjectContext()
    }
    
    func buildPredicate(predicate: Predicate) -> NSPredicate {
        var predicateOperator = ""
        switch predicate.op{
        case .Equals:
            predicateOperator = "=="
        default:
            assertionFailure("Predicate operator \(predicate.op) is not currently implemented.")
        }
        return NSPredicate(format: "\(predicate.lhs)\(predicateOperator)%@", argumentArray: [predicate.rhs!])
    }
    
    public func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock: ((T) -> Void)? ) -> T {
        let ctx = getCtx()
        let entity = NSEntityDescription.insertNewObjectForEntityForName(dataSourceEntityName, inManagedObjectContext: ctx) as! T;
        if let valuesAssignmentBlock = valuesAssignmentBlock {
            valuesAssignmentBlock(entity)
        }
        do {
            try ctx.save()
        }
        catch let e as NSError {
            fatalError("CoreDataAdapter.insert: Error inserting entity [\(dataSourceEntityName)]. Details:\(e)")
        }
        
        return entity
    }
  
    public func update<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, updateOnlyOne: Bool = true, valuesAssignmentBlock: ((T) -> Void)?) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }
    
    public func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool = true, valuesAssignmentBlock: ((T) -> Void)?) -> Int {
        var updated = 0;
        let ctx = getCtx()
        do {
            let request = NSFetchRequest(entityName: dataSourceEntityName)
            if let predicate = predicate {
                request.predicate = buildPredicate(predicate)
            }
            if updateOnlyOne {
                request.fetchLimit = 1
            }
            
            let results = try ctx.executeFetchRequest(request)
            for result in results {
                if let valuesAssignmentBlock = valuesAssignmentBlock {
                    valuesAssignmentBlock(result as! T)
                }
                updated++
            }
            do {
                try ctx.save()
            }
            catch let e as NSError {
                fatalError("CoreDataAdapter.update: Error updating entity [\(dataSourceEntityName)]. Details:\(e)")
            }
        }
        catch let e as NSError{
            print(e)
        }
        return updated
    }
 
    public func delete(dataSourceEntityName: String, predicateGroup: PredicateGroup?, deleteOnlyOne: Bool = true) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }
    
    public func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool = true) -> Int {
        var deletedCount = 0;
        let ctx = getCtx()
        do {
            let request = NSFetchRequest(entityName: dataSourceEntityName)
            if let predicate = predicate {
                request.predicate = buildPredicate(predicate)
            }
            if deleteOnlyOne {
                request.fetchLimit = 1
            }

            let results = try ctx.executeFetchRequest(request)
            for result in results {
                deletedCount++
                ctx.deleteObject(result as! NSManagedObject)
                if deleteOnlyOne {
                    break
                }
            }
        }
        catch let e as NSError{
            print(e)
        }
        return deletedCount
    }
    
    public func fetch<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, limit: Int?) -> [T]{
        // TODO: Throw NotImplementedException
        abort()
    }
  
    public func fetch<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T]{
        // TODO: Throw NotImplementedException
        abort()
    }
    
    public func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T]{
        var returnedSet = [AnyObject]()
        let request = NSFetchRequest(entityName: dataSourceEntityName)
        if let predicate = predicate {
            request.predicate = buildPredicate(predicate)
        }
        if let limit = limit {
            request.fetchLimit = limit
        }
        do {
            returnedSet = try getCtx().executeFetchRequest(request)
        }
        catch let error as NSError {
            assertionFailure("CoreDataAdapter.fetch<\(dataSourceEntityName)>: Error querying set. Details: \(error)")
        }
        return returnedSet.map({ item in item as! T })
    }
    
}
