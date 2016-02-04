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
    
    public func buildPredicate(predicate: Predicate) -> MPMediaPropertyPredicate {
        // TODO: Switch on predicate.lhs to determine forProperty value.
        return MPMediaPropertyPredicate(value: predicate.rhs, forProperty: MPMediaItemPropertyPersistentID)
    }
    
    // Async SELECT
    public func fetch<T>(dataSourceEntityName: String, predicate: Predicate?, limit: Int?, sortDescriptors: [NSSortDescriptor]?, completion: (result: [T]?, error: NSError?) -> Void) {
        var mediaItems : [T]?
        let query = MPMediaQuery.songsQuery()
        if let predicate = predicate {
            let mediaPredicate = self.buildPredicate(predicate)
            query.filterPredicates = (NSSet(object: mediaPredicate) as! Set<MPMediaPredicate>)
        }
        ThreadingUtil.inBackground({ () -> Void in
            mediaItems = query.items!.map({item in item as! T})
            }) { () -> Void in
                completion(result: mediaItems, error: nil)
        }
    }
    
    // Async INSERT
    public func insert<T>(dataSourceEntityName: String, valuesAssignmentBlock assignValues: ((T) -> Void)?, completion: (newEntity: T?, error: NSError?) -> Void)
    {
        // NotImplementedException
        abort()
    }
    
    // Async UPDATE
    public func update<T>(dataSourceEntityName: String, predicate: Predicate?, updateOnlyOne: Bool, valuesAssignmentBlock: ((T) -> Void), completion: (updated: Bool, error: NSError?) -> Void)
    {
        // NotImplementedException
        abort()
    }
    
    // Async DELETE
    public func delete(dataSourceEntityName: String, predicate: Predicate?, deleteOnlyOne: Bool, completion: (deleted: Bool, error: NSError?) -> Void)
    {
        // NotImplementedException
        abort()
    }

}

