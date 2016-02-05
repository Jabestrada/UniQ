//
//  UserSetup.swift
//  UniQ
//
//  Created by Julius Estrada on 29/01/2016.
//  Copyright © 2016 JABE Labs. All rights reserved.
//

import UIKit

class UserSetupViewController: UIViewController, AppModelEditor {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    var delegate : AppModelEditorDelegate?
    var personModel : Person?
    
    override func viewDidLoad() {
        if let personModel = delegate?.getModelInstance() as? Person {
            // Edit mode
            self.personModel = personModel
            fillUI(personModel)
        }
        self.navigationItem.title = self.isNew() ? "New" : "Edit"
        
        let saveButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain,
            target: self, action: "onSaveTapped")
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    func onSaveTapped(){
        if (isNew()){
            Person.insert({ (person: Person) -> Void in
                    person.entityId = NSUUID().UUIDString
                    self.fillModel(person)
                }) { (newPerson, error) -> Void in
                    if (error == nil) {
                        self.delegate?.didAddInstance(self, instance: newPerson)
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        print("ERROR: \(error?.localizedDescription)")
                    }
            }
        } else {
            var updatedPerson : Person?
            Person.update(personModel!, valuesAssignmentBlock: { (person: Person) -> Void in
                    self.fillModel(person)
                    updatedPerson = person
                }, completion: { (updated, error) -> Void in
                    if (error == nil && updated) {
                        self.delegate?.didUpdateInstance(self, instance: updatedPerson)
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    else {
                        // Oops, inform user of update failure.
                    }
            })
        }
    }
    
    func isNew() -> Bool {
        return personModel == nil
    }
    
    func fillModel(person: Person){
        person.firstName = self.firstNameTextField.text!
        person.lastName = self.lastNameTextField.text!
    }
    
    func fillUI(person: Person){
        firstNameTextField.text = person.firstName
        lastNameTextField.text = person.lastName
    }
}
