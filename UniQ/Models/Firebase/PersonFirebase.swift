//
//  PersonFirebase.swift
//  UniQ
//
//  Created by Julius Estrada on 03/02/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

import UIKit

public class Person : NSObject, FirebaseConvertible {
    
    // MARK: UniQ
    public static let dataAdapter : DataAdapterProtocol = Factory.createDataAdapter()
    
    // MARK: Model fields
    var entityId: String?
    var firstName: String?
    var lastName: String?
    

    // Empty ctor needed by FirebaseMapper during compile-time.
    override init() {
        super.init()
    }
    
    init(snapshot: FDataSnapshot) {
        entityId = snapshot.key
        firstName = snapshot.value[PersonFields.firstName.rawValue] as! String
        lastName = snapshot.value[PersonFields.lastName.rawValue] as! String
    }
    
    // MARK: FirebaseConvertible
    public func toAnyObject() -> AnyObject {
        return [
            PersonFields.firstName.rawValue: firstName!,
            PersonFields.lastName.rawValue: lastName!
        ]
    }
    
    public func getKeyValue() -> String {
        return entityId!
    }
}