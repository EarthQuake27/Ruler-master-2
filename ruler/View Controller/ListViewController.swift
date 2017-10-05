//
//  ListViewController.swift
//  ruler
//
//  Created by Portia Wang on 8/8/17.
//  Copyright © 2017 Portia Wang. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Properties
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var entries = [Entry]()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.entries = CoreDataHelper.retrieveEntry()
        tableView.reloadData()
        self.entries.sort { (entry1, entry2) -> Bool in
            if entry1.date?.compare(entry2.date! as Date) == ComparisonResult.orderedAscending{
                return true
            }
            return false
        }
        self.backgroundView.isHidden = true
    }

    //MARK: - Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        cell.nameLabel.text! = entries[indexPath.row].name!
        cell.valueLabel.text! = String(describing: entries[indexPath.row].value!) + " " + String(describing: entries[indexPath.row].unit!)
        cell.dateCreatedLabel.text! = "Created on " + (entries[indexPath.row].date?.convertToString())!
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            CoreDataHelper.deleteEntry(entry: entries[indexPath.row])
            self.entries.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let popOverVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SaveViewController") as? SaveViewController
        let selectedItem = self.entries[indexPath.row]
        popOverVC?.item = selectedItem
        popOverVC?.unit = selectedItem.unit!
        popOverVC?.value = selectedItem.value!
        popOverVC?.name = selectedItem.name!
        popOverVC?.CMValue = selectedItem.cmValue
        self.addChildViewController(popOverVC!)
        popOverVC?.view.frame = self.view.frame
        self.backgroundView.isHidden = false
        popOverVC?.didMove(toParentViewController: self)
        
        UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: { _ in
            self.view.addSubview((popOverVC?.view)!)
        }, completion: nil)
    }
}
