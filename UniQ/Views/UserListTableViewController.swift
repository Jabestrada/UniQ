//
//  UserListTableViewController.swift
//  UniQ
//
//  Created by Julius Estrada on 29/01/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//


import UIKit

protocol AppModelEditor {
    var delegate : AppModelEditorDelegate? { get set }
}


class UserListTableViewController: UITableViewController, AppModelEditorDelegate {
    typealias T = Person
    
    var persons = [Person]()
    var modelChanged = false
    
    var currentModelInstance: T?
    
    override func viewDidLoad() {
        self.tableView.dataSource = self
        modelChanged = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if modelChanged {
            loadData()
            modelChanged = false
        }
    }
    
 
    func loadData(){
        Person.getAll { (persons, error) -> Void in
            if (error == nil){
                self.persons = persons!
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if var modelEditor = segue.destinationViewController as? AppModelEditor {
            if let indexPath = sender as? NSIndexPath {
                currentModelInstance = persons[indexPath.row]
            }
            else {
                currentModelInstance = nil
            }
            modelEditor.delegate = self
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        let person = persons[indexPath.row]
        cell.textLabel?.text = person.firstName
        cell.detailTextLabel?.text = person.lastName
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete){
            let person = persons[indexPath.row]
            Person.delete(person, completion: { (deleted, error) -> Void in
                if (error == nil && deleted){
                    self.loadData()
                } else {
                    print("Error during deletion attempt. Details: \(error?.localizedDescription)")
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toUserSetupSegue", sender: indexPath)
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }


    func getModelInstance() -> NSObject? {
        return currentModelInstance
    }
    
    func didAddInstance<T>(sourceViewController: UIViewController, instance: T) {
        modelChanged = true
    }
    
    func didUpdateInstance<T>(sourceViewController: UIViewController, instance: T) {
        modelChanged = true
    }
    func didDeleteInstance<T>(sourceViewController: UIViewController, instance: T){
        modelChanged = true
    }

}


