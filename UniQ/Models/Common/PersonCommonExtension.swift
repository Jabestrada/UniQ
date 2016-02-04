//
//  PersonCommonExtension.swift
//  UniQ
//
//  Created by Julius Estrada on 03/02/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

import Foundation

public enum PersonFields  : String {
    case id = "entityId"
    case firstName = "firstName"
    case lastName = "lastName"
}

extension Person : UniQProtocol {
    
    // MARK:  UniQProtocol
    public typealias T = Person
    public static var dataSourceEntityName : String {
        get {
            return "Person"
        }
    }
    
    // MARK: App domain specific statics
    static func insert(valuesAssignmentBlock: (Person) -> Void, completion: (newPerson: Person?, error: NSError?) -> Void){
        dataAdapter.insert(self.dataSourceEntityName, valuesAssignmentBlock: valuesAssignmentBlock, completion: completion)
    }
    
    static func delete(person: Person, completion: (deleted: Bool, error: NSError?) -> Void){
        dataAdapter.delete(self.dataSourceEntityName, predicate: Predicate(lhs: PersonFields.id.rawValue, op: PredicateOperator.Equals, rhs: person.entityId), deleteOnlyOne: true) { (deleted, error) -> Void in
            completion(deleted: deleted, error: error)
        }
    }
    
    static func update(person: Person, valuesAssignmentBlock: (Person) -> Void, completion: (updated: Bool, error: NSError?) -> Void) {
        dataAdapter.update(self.dataSourceEntityName, predicate: Predicate(lhs: PersonFields.id.rawValue, op: .Equals, rhs: person.entityId), updateOnlyOne: true, valuesAssignmentBlock: valuesAssignmentBlock) { (updated, error) -> Void in
            completion(updated: updated, error: error)
        }
    }
    
    static func getAll(completion: (persons: [Person]?, error: NSError?) -> Void){
        dataAdapter.fetch(self.dataSourceEntityName, predicate: nil, limit: nil, sortDescriptors: nil) { (result, error) -> Void in
            completion(persons: result, error: error);
        }
    }
    
    static func getById(id: String, completion: (person: Person?, error: NSError?) -> Void){
        dataAdapter.fetch(self.dataSourceEntityName, predicate: Predicate(lhs: PersonFields.id.rawValue, op: PredicateOperator.Equals, rhs: id), limit: 1, sortDescriptors: nil)
            { (result : [Person]?, error: NSError?) -> Void in
                if let results = result {
                    completion(person: results.count > 0 ? results[0] : nil, error: error)
                } else {
                    completion(person: nil, error: error)
                }
        }
    }
}