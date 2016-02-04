//
//  AppModelEditorDelegate.swift
//  UniQ
//
//  Created by Julius Estrada on 02/02/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

protocol AppModelEditorDelegate {
    func didAddInstance<T>(sourceViewController: UIViewController,  instance: T)
    func didUpdateInstance<T>(sourceViewController: UIViewController, instance: T)
    func didDeleteInstance<T>(sourceViewController: UIViewController, instance: T)
    func getModelInstance() -> NSObject?
}
