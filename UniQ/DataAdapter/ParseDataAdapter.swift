//
//  ParseDataAdapter.swift
//  myEats
//
//  Created by JABE on 11/3/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

//import Parse

public class ParseDataAdapter: DataAdapterProtocol {
    
    public func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)? ) -> T {
        let newObject = PFObject(className: dataSourceEntityName)
        let newObjectAsT = newObject as! T
        if let assignValues = assignValues {
            assignValues(newObjectAsT)
        }
        do {
            try newObject.save()
        }
        catch let e as NSError {
            print("ParseDataAdapter.insert error: \(e.localizedDescription)")
        }
        return newObjectAsT
    }
    


    
    public func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void)?) -> Int {
        let pfObject = PFObject(withoutDataWithClassName: dataSourceEntityName, objectId: predicate!.rhs as? String)
        if let valuesAssignmentBlock = valuesAssignmentBlock {
            let modelToUpdate = pfObject as! T
            valuesAssignmentBlock(modelToUpdate)
        }
        do {
            try pfObject.save()
        }
        catch let e as NSError {
            print("ParseDataAdapter update<T> error: \(e)")
            return -1
        }
        return 1
    }
   
    public func update<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void)?) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }
    
    public func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }
    
    public func delete(dataSourceEntityName: String, predicateGroup: PredicateGroup?, deleteOnlyOne: Bool) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }
    
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
    
    
    public func fetch<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        if let predicateGroup = predicateGroup {
            var objects = [PFObject]()
            let query = PFQuery(className: dataSourceEntityName)
            buildPredicate(query, predicateGroup: predicateGroup)
            if let _ = sortDescriptors {
//                assertionFailure("sortDescriptors not yet implemented")
                query.orderBySortDescriptors(sortDescriptors)
            }
            do {
                objects = try query.findObjects()
            }
            catch let e as NSError{
                print("Error with ParseDataAdapter.fetch(\(dataSourceEntityName)): \(e)")
            }
            
              return objects.map({item in Factory.convert(item)})
        }
        else {
            return fetch(dataSourceEntityName, predicate: nil, limit: nil, sortDescriptors: sortDescriptors)
        }
    }
    
    
    public func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
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
        
        do {
            if isParseKeyField(predLhs) && predIsEquals {
                objects.append(try query.getObjectWithId(predRhs))
            }
            else {
                objects = try query.findObjects()
            }
        }
        catch let e as NSError {
            print("Error with ParseDataAdapter.fetch(\(dataSourceEntityName)): \(e)")
        }

        return objects.map({item in Factory.convert(item)})
    }
    
}




