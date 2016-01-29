//
//  DataAdapter.swift
//
//  Created by JABE on 9/26/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

import Foundation

public protocol DataAdapterProtocol {
    func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)? ) -> T
    func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void)?) -> Int
    func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool) -> Int
    func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T]
    
    func update<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void)?) -> Int
    func delete(dataSourceEntityName: String, predicateGroup: PredicateGroup?, deleteOnlyOne: Bool) -> Int
//    func fetch<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, limit: Int?) -> [T]
    func fetch<T>(dataSourceEntityName: String, predicateGroup: PredicateGroup?, limit: Int?, sortDescriptors: [NSSortDescriptor]?) -> [T]
}
