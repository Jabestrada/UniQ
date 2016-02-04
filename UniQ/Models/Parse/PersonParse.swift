//
//  PersonParse.swift
//  UniQ
//
//  Created by Julius Estrada on 03/02/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

import Foundation

public class Person : PFObject, PFSubclassing {
    // MARK: UniQ
    public static let dataAdapter : DataAdapterProtocol = Factory.createDataAdapter()
    
    // MARK: Model fields
    @NSManaged var entityId: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    
    // MARK: PFSubclassing
    public class func parseClassName() -> String {
        return "Person"
    }
    
    public override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}