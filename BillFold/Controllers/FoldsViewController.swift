//
//  FoldsViewController.swift
//  BillFold
//
//  Created by Simon Schueller on 5/22/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import UIKit
import RealmSwift

class FoldsViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var textField = UITextField()
    var folds: Results<Fold>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFolds()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return folds?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldCell", for: indexPath)
        if let fold = folds?[indexPath.row]{
            cell.textLabel?.text = fold.name
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCash", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CashViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedFold = folds?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    func saveFolds(fold: Fold){
        do{
            try realm.write{
                realm.add(fold)
            }
        }catch{
            print("Error saving fold \(error)")
        }
        tableView.reloadData()
    }
    
    func loadFolds(){
        folds = realm.objects(Fold.self)
        for fold in folds! {
            print(fold.total)
        }
        tableView.reloadData()
    }
    
//    @IBAction func deleteAll(_ sender: UIBarButtonItem) {
//        // Create Fetch Request
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Fold")
//        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Cash")
//
//        // Create Batch Delete Request
//        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
//
//        do {
//            try context.execute(batchDeleteRequest)
//            try context.execute(batchDeleteRequest1)
//            tableView.reloadData()
//        } catch {
//            // Error Handling
//        }
//    }
    
    //MARK: - Add New Folds
    @IBAction func addFold(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Fold", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newFold = Fold()
            newFold.name = self.textField.text!
            newFold.dateCreated = Date()
            newFold.total = 0.0
            self.saveFolds(fold: newFold)
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            self.textField = field
            self.textField.placeholder = "Add a new Fold"
        }
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Search Bar Methods
extension FoldsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        folds = folds?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadFolds()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
