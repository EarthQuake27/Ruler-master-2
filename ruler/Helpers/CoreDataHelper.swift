//
//  CoreDataHelper.swift
//  Ruler
//
//  Created by Portia Wang on 8/8/17.
//  Copyright © 2017 Portia Wang. All rights reserved.
//

import CoreData
import UIKit

class CoreDataHelper {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let persistentContainer = appDelegate.persistentContainer
    static let managedContext = persistentContainer.viewContext
    
    //static methods will go here
    
    //new activity
    static func newEntry() -> Entry {
        weak var entry = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: managedContext) as? Entry
        return entry!
    }
    
    //save activity
    static func saveEntry() {
        do{
            try managedContext.save()
        } catch let error as NSError{
            print("could not save \(error)")
        }
    }
    
    //delete activity
    static func deleteEntry (entry: Entry){
        managedContext.delete(entry)
        saveEntry()
    }
    
    //retreive activity
    
    static func retrieveEntry() -> [Entry] {
        let fetchRequest = NSFetchRequest<Entry>(entityName: "Entry")
        do {
            let results = try managedContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        return []
    }
}





