//
//  FirebaseMapper.swift
//  UniQ
//
//  Created by Julius Estrada on 04/02/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

public class FirebaseMapper: NSObject {
    static func map<T>(snapshot: FDataSnapshot) -> T {
        let entityType = FirebaseDataAdapter.getEntityNameFromUrl("\(snapshot.ref)")
        switch entityType.lowercaseString {
        case "person":
            return Person(snapshot: snapshot) as! T
        // TODO: Add case for each model type. Otherwise, a run-time error will remind you.
        default:
            break
        }
        assertionFailure("FirebaseMapper.map(): object.ref.key [\(snapshot.ref.key)] has no defined mapper")
        abort()
    }
    
    static func create<T>(entityName: String) -> T {
        switch entityName.lowercaseString {
        case "person":
            return Person() as! T
         // TODO: Add case for each model type. Otherwise, a run-time error will remind you.
        default:
            break
        }
        assertionFailure("FirebaseMapper.create(): Entity name [\(entityName)] has no defined map")
        abort()
    }
}
