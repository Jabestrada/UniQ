//
//  Factory.swift
//  myEats
//
//  Created by JABE on 11/3/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//


class Factory: NSObject {
    class func createDataAdapter() -> DataAdapterProtocol {
//        return ParseDataAdapter()
        return CoreDataAdapter()
//        return FirebaseDataAdapter()
    }
}
