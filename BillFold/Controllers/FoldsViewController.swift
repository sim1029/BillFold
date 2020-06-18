//
//  FoldsViewController.swift
//  BillFold
//
//  Created by Simon Schueller on 5/22/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class FoldsViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var textField = UITextField()
    var folds: Results<Fold>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
        // Custom back button
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "left-arrow")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "left-arrow")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        
        loadFolds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return folds?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let fold = folds?[indexPath.row]{
            cell.textLabel?.text = fold.name
            if let color = UIColor(hexString: fold.color)?.darken(byPercentage:
                CGFloat(indexPath.row) / CGFloat(folds!.count) / 1.35){
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor.white
            }
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
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let foldForDeletion = self.folds?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(foldForDeletion)
                }
            }catch{
                print("Error deleting category \(error)")
            }
        }
    }
    
    //MARK: - Add New Folds
    @IBAction func addFold(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Fold", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newFold = Fold()
            newFold.name = self.textField.text!
            newFold.dateCreated = Date()
            newFold.total = 0.0
            newFold.color = UIColor.systemGreen.hexValue()
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
        performSearch(for: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count != 0{
            performSearch(for: searchBar.text!)
        } else {
            loadFolds()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func performSearch(for text: String){
        folds = realm.objects(Fold.self)
        folds = folds?.filter("name CONTAINS[cd] %@", text).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
}
