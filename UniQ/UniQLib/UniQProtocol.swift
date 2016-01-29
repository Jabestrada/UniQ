//
//  UniQ.swift
//
//  Created by JABE on 9/26/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//



public enum UniQProtocolError: ErrorType{
    case WrongResultsCount(String, Int)
}

public protocol UniQProtocol {
    typealias T
    static var dataSourceEntityName : String { get }
    static var dataAdapter : DataAdapterProtocol { get }
}

public extension UniQProtocol {

    // Must have 1 and only 1
    static func singleOrDefault(predicate: Predicate, sortDescriptors: [NSSortDescriptor]?) throws -> T? {
        let results : [T] =  dataAdapter.fetch(self.dataSourceEntityName, predicate: predicate, limit: 2, sortDescriptors: sortDescriptors)
        guard results.count == 0 || results.count == 1 else {
            throw UniQProtocolError.WrongResultsCount("UniQProtocol.singleOrDefault<\(dataSourceEntityName)>: Fetched row count is \(results.count) when it must be either zero or 1", results.count)
        }
        return results.count == 0 ? T?.None : results[0]
    }
    
    // Can have 1, more than 1 or zero
    static func firstOrDefault(predicate: Predicate, sortDescriptors: [NSSortDescriptor]?) -> T? {
        let results : [T] =  dataAdapter.fetch(self.dataSourceEntityName, predicate: predicate, limit: 1, sortDescriptors: sortDescriptors)
        return results.count == 0 ? T?.None : results[0]
    }

    static func firstOrDefault(predicateGroup: PredicateGroup, sortDescriptors: [NSSortDescriptor]?) -> T? {
        let results : [T] =  dataAdapter.fetch(self.dataSourceEntityName, predicateGroup: predicateGroup, limit: 1, sortDescriptors: sortDescriptors)
        return results.count == 0 ? T?.None : results[0]
    }
    
    
    static func all(predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        return dataAdapter.fetch(self.dataSourceEntityName, predicate: predicate, limit: limit, sortDescriptors: sortDescriptors)
    }
   
    static func all(predicateGroup: PredicateGroup, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        return dataAdapter.fetch(self.dataSourceEntityName, predicateGroup: predicateGroup, limit: limit, sortDescriptors: sortDescriptors)
    }
    
}




