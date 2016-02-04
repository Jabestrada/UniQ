//
//  DataAdapterProtocol.swift
//
//  Created by JABE on 9/26/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

import Foundation

public protocol DataAdapterProtocol {
    // SELECT
    func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?, completion: (result: [T]?, error: NSError?) -> Void)
    
    // INSERT
    func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)?, completion: (newEntity: T?, error: NSError?) -> Void)

    // UPDATE
    func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void), completion: (updated: Bool, error: NSError?) -> Void)

    // DELETE
    func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool, completion: (deleted: Bool, error: NSError?) -> Void)
}
