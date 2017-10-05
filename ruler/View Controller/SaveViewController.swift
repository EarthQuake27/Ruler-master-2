//
//  SaveViewController.swift
//  ruler
//
//  Created by Portia Wang on 8/9/17.
//  Copyright © 2017 Portia Wang. All rights reserved.
//

import Foundation
import UIKit

class SaveViewController: UIViewController, UITextFieldDelegate{
    
    //MARK: - Properties
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var value = ""
    var unit = ""
    var name = ""
    var item = Entry()
    var isNew = true
    var CMValue = 0.0
    
    //MARK: - Lifecycles
    
    func dismissKeyboard(){
        if self.titleTextField.isFirstResponder {
            self.titleTextField.endEditing(true)
        } else {
            saveButtonTapped(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleTextField.delegate = self
        segmentControl.addTarget(self, action: #selector(SaveViewController.changeUnit), for: .valueChanged)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(SaveViewController.dismissKeyboard))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(SaveViewController.dismissKeyboard))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SaveViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        valueLabel.text = value
        unitLabel.text = unit
        nameTextField.text = name
        
        if self.parent is ListViewController{
            self.saveButton.setTitle("Back", for: .normal)
            segmentControl.selectedSegmentIndex = Int(self.item.index)
        } else {
            self.saveButton.setTitle("Save", for: .normal)
        }
    }
    
    
    //MARK: - Functions
    
    func changeUnit(){
        if segmentControl.selectedSegmentIndex == 0{
            self.valueLabel.text = String(roundtoSecond(num:CMValue))
            self.unitLabel.text = "CM"
        }
        if segmentControl.selectedSegmentIndex == 1{
            self.valueLabel.text = String(roundtoSecond(num:CMValue/100.0))
            self.unitLabel.text = "M"
        }
        if segmentControl.selectedSegmentIndex == 2{
            self.valueLabel.text = String(roundtoSecond(num:CMValue/2.54))
            self.unitLabel.text = "INCH"
        }
        if segmentControl.selectedSegmentIndex == 3{
            self.valueLabel.text = String(roundtoSecond(num:CMValue/30.48))
            self.unitLabel.text = "FOOT"
        }
        if segmentControl.selectedSegmentIndex == 4{
            let ft = Int(CMValue/30.48)
            let inch = Double(CMValue/2.54 - ((Double(ft)*12)))
            
            self.valueLabel.text = String(ft) + "ft"
            self.unitLabel.text = String(Double(Int(inch*10))/10) + "in"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.titleTextField.endEditing(true)
        return true
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.titleTextField.text != ""{
            if parent is ResultViewController {
                let parent = self.parent as! ResultViewController
                let item = CoreDataHelper.newEntry()
                item.name = self.titleTextField.text!
                item.value = self.valueLabel.text!
                item.unit = self.unitLabel.text!
                item.date = Date() as NSDate
                item.index = Int16(segmentControl.selectedSegmentIndex)
                CoreDataHelper.saveEntry()
                item.cmValue = parent.CMValue
                parent.dismiss(animated: true, completion: {
                    self.dismiss(animated: true, completion: {
                    })
                })
            } else {
                let parent = self.parent as! ListViewController
                self.item.name = self.titleTextField.text!
                self.item.unit = self.unitLabel.text!
                self.item.value = self.valueLabel.text!
                self.item.index = Int16(segmentControl.selectedSegmentIndex)
                CoreDataHelper.saveEntry()
                parent.backgroundView.isHidden = true
                parent.entries = CoreDataHelper.retrieveEntry()
                parent.tableView.reloadData()
                parent.view.isUserInteractionEnabled = true
                
                UIView.animate(withDuration: 0.25, delay: 0.0, options: .transitionCrossDissolve, animations: {
                    self.view.removeFromSuperview()
                })
            }
        } else {
            let alert = UIAlertController(title: "No title entered", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .cancel, handler: { (alert) in
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: {
            })
        }
    }
    
    func roundtoSecond( num: Double) -> Double{
        return (Double(Int(num*100))/100.0)
    }
}

















