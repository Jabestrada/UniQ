//
//  ThreadingUtil.swift
//
//  Created by JABE on 11/11/15.
//  Copyright © 2015 JABELabs. All rights reserved.
//

class ThreadingUtil {
    static func inMainQueue(executeBlock:() -> Void){
        dispatch_async(dispatch_get_main_queue(), executeBlock)
    }
    
    static func inBackground(executeBlock: () -> Void, callBack:(() -> Void)?) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            executeBlock()
            if let callBack = callBack {
                dispatch_async(dispatch_get_main_queue(), callBack)
            }
        }
    }
    

    
}
