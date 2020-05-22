//
//  ViewController.swift
//  BillFold
//
//  Created by Simon Schueller on 5/16/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import UIKit

class CashViewController: UIViewController, UITextFieldDelegate {

//    var cash = Cash()
//    cash.total = 0.0
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//    let newCash = Cash(context: self.context)
//    newCash.total =
//    newItem.done = false
//    newItem.parentCategory = self.selectedCategory
//    self.itemArray.append(newItem)
//    self.saveItems()
    
    //MARK: -Outlets
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var moneyLabel: UILabel!
    
    //MARK: -Variables
    var amt: Int = 0
    var total: Double = 0.00
//    var selectedFold : Fold? {
//        didSet{
//            loadItems()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        moneyTextField.delegate = self
        moneyTextField.placeholder = updateAmount()
        overrideUserInterfaceStyle = .light
        moneyTextField.keyboardType = UIKeyboardType.numberPad
//        moneyLabel.text = "$0.00"
        //Listen for Keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        //Stop listening for keyboard events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //MARK: -Methods or Functions
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        }else{
            view.frame.origin.y = 0
        }
    }
    
    func textField(_ textfield: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            amt = amt * 10 + digit
            moneyTextField.text = updateAmount()
        }
        if string == "" {
            amt = amt/10
            moneyTextField.text = updateAmount()
        }
        return false
    }
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amt/100) + Double(amt%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
    
    func formatMoneyLabel(_ money: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.currency
        return formatter.string(from: NSNumber(value: money))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: -Actions
    @IBAction func resetBalance(_ sender: UIButton) {
        total = 0
        moneyLabel.text = formatMoneyLabel(total)
    }
    
    @IBAction func addMoney(_ sender: UIButton) {
        if moneyTextField.text != "" {
            self.view.endEditing(true)
            if let money = moneyTextField.text{
                let index = money.index(money.startIndex, offsetBy: 1)
                if let currentMoney = Double(money.suffix(from: index)){
                    total += currentMoney
                }
                moneyLabel.text = formatMoneyLabel(total)
            }
            moneyTextField.text = ""
            amt = 0
        }
    }
    
    @IBAction func subtractMoney(_ sender: UIButton) {
        if moneyTextField.text != "" {
            self.view.endEditing(true)
            if let money = moneyTextField.text{
                let index = money.index(money.startIndex, offsetBy: 1)
                if let currentMoney = Double(money.suffix(from: index)){
                    total -= currentMoney
                }
                moneyLabel.text = formatMoneyLabel(total)
            }
            moneyTextField.text = ""
            amt = 0
        }
    }
    
//    func saveItems(){
//        do{
//            try context.save()
//        }catch{
//            print("error saving context \(error)")
//        }
//        moneylabel.text = formatMoneyLabel(<#T##money: Double##Double#>)
//    }
//
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        }else{
//            request.predicate = categoryPredicate
//        }
//
//        do{
//            itemArray = try context.fetch(request)
//        }catch{
//            print("Error fetching data from context \(error)")
//        }
//        tableView.reloadData()
//    }
    
}

