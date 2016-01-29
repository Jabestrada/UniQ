//
//  Predicate.swift
//
//  Created by JABE on 9/27/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

import UIKit

public struct Predicate {
    var lhs : String
    var op: PredicateOperator
    public var rhs: AnyObject?
    var rhsValueKind: PredicateValueKind
    
    public init(lhs: String, op: PredicateOperator, rhs: AnyObject?, rhsValueKind: PredicateValueKind){
        self.lhs = lhs
        self.op = op
        self.rhs = rhs
        self.rhsValueKind = rhsValueKind
    }
    
    public init(lhs: String, op: PredicateOperator, rhs: AnyObject?) {
        self.init(lhs: lhs, op: op, rhs: rhs, rhsValueKind:  PredicateValueKind.String)
    }
    
}


public enum PredicateCondition : Int {
    case and = 0
    case or = 1
}


public class PredicateGroup {
    var predicate1 : Predicate
    var innerPredicateCondition : PredicateCondition?
    var predicate2 : Predicate?

    var outerPredicateCondition : PredicateCondition?
    var outerPredicateGroup : PredicateGroup?
    
    init(predicate1: Predicate){
        self.predicate1 = predicate1
    }

    
    convenience init(predicate1: Predicate, predicate2: Predicate?){
        if let predicate2 = predicate2{
            self.init(predicate1: predicate1, predicate2: predicate2)
        }
        else
        {
            self.init(predicate1: predicate1)
        }
    }
    
    convenience init(predicate1: Predicate, predicate2: Predicate){
        self.init(predicate1: predicate1)
        self.predicate2 = predicate2
        self.innerPredicateCondition = PredicateCondition.and
    }
    
    convenience init(predicate1: Predicate, predicate2: Predicate, predicateCondition: PredicateCondition){
        self.init(predicate1: predicate1, predicate2: predicate2)
        self.innerPredicateCondition = predicateCondition
    }
    
    func andWith(predicateGroup: PredicateGroup){
        outerPredicateCondition = PredicateCondition.and
        outerPredicateGroup = predicateGroup
    }
    
    func orWith(predicateGroup: PredicateGroup){
        outerPredicateCondition = PredicateCondition.or
        outerPredicateGroup = predicateGroup
    }
}