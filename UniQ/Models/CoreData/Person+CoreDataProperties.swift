//
//  Person+CoreDataProperties.swift
//  
//
//  Created by Julius Estrada on 03/02/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var entityId: String?

}
