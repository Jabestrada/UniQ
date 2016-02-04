//
//  Person.swift
//  
//
//  Created by Julius Estrada on 03/02/2016.
//
//

import Foundation
import CoreData

public class Person: NSManagedObject {
    public static let dataAdapter : DataAdapterProtocol = Factory.createDataAdapter()
}
