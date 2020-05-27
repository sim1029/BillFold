//
//  FoldsViewController.swift
//  BillFold
//
//  Created by Simon Schueller on 5/22/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import UIKit
import CoreData

class FoldsViewController: UITableViewController {
    
    var textField = UITextField()
    var folds = [Fold]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return folds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldCell", for: indexPath)
        cell.textLabel?.text = folds[indexPath.row].name
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCash", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CashViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedFold = folds[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    func saveFolds(){
        do{
            try context.save()
        }catch{
            print("Error saving fold \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        let request : NSFetchRequest<Fold> = Fold.fetchRequest()
        do{
            folds = try context.fetch(request)
        }catch{
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    
    @IBAction func deleteAll(_ sender: UIBarButtonItem) {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Fold")
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Cash")

        // Create Batch Delete Request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)

        do {
            try context.execute(batchDeleteRequest)
            try context.execute(batchDeleteRequest1)
            tableView.reloadData()
        } catch {
            // Error Handling
        }
    }
    //MARK: - Add New Folds
    @IBAction func addFold(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Fold", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newFold = Fold(context: self.context)
            let newCash = Cash(context: self.context)
            newCash.total = 0.0
            newFold.name = self.textField.text!
            newCash.parentFold = newFold
            self.folds.append(newFold)
            self.saveFolds()
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            self.textField = field
            self.textField.placeholder = "Add a new Fold"
        }
        present(alert, animated: true, completion: nil)
    }
}
