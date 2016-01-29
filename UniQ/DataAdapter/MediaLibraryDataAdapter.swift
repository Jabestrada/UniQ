//
//  MediaLibraryDataAdapter.swift
//  UGetApp
//
//  Created by JABE on 10/5/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

import Foundation
import MediaPlayer

public class MediaLibraryDataAdapter : DataAdapterProtocol {
    public func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)? ) -> T {
        // TODO: Throw NotImplementedException
        abort()
    }
    
    public func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool = true, valuesAssignmentBlock: ((T) -> Void)?) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }

    public func update<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, updateOnlyOne: Bool = true, valuesAssignmentBlock: ((T) -> Void)?) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }

    
    public func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool = true) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }

    public func delete(dataSourceEntityName: String, predicateGroup: PredicateGroup?, deleteOnlyOne: Bool = true) -> Int {
        // TODO: Throw NotImplementedException
        abort()
    }

    public func fetch<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        // TODO: Throw NotImplementedException
        abort()
    }
    
    public func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        let query = MPMediaQuery.songsQuery()
        if let predicate = predicate {
            let mediaPredicate = buildPredicate(predicate)
            query.filterPredicates = (NSSet(object: mediaPredicate) as! Set<MPMediaPredicate>)

        }
        return  query.items!.map({item in item as! T} )
    }
    
    public func buildPredicate(predicate: Predicate) -> MPMediaPropertyPredicate {
        // TODO: Switch on predicate.lhs to determine forPropertyValue.
        return MPMediaPropertyPredicate(value: predicate.rhs, forProperty: MPMediaItemPropertyPersistentID)
    }
}

