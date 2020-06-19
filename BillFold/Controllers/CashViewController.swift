//
//  ViewController.swift
//  BillFold
//
//  Created by Simon Schueller on 5/16/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import UIKit
import RealmSwift
import Gifu

class CashViewController: UIViewController, UITextFieldDelegate {

    let realm = try! Realm()
    
    // Variables
    @IBOutlet weak var piggyBankView: GIFImageView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var moneyLabel: UILabel!
    let commaString = ","
    var amt: Int = 0
    var total: Double = 0.00
    var selectedFold : Fold? {
        didSet{
            loadCash()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        moneyTextField.delegate = self
        moneyTextField.placeholder = updateAmount()
        overrideUserInterfaceStyle = .light
        moneyTextField.keyboardType = UIKeyboardType.numberPad
        
        listenForKeyboardEvents()
        
        loadCash()
    }

    deinit {
        stopListeningForKeyboardEvents()
    }
    
    //MARK: - Keyboard Methods
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func listenForKeyboardEvents(){
        //Listen for Keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        navigationItem.largeTitleDisplayMode = .never
        navBar.title = selectedFold!.name
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.systemYellow]
    }
    
    func stopListeningForKeyboardEvents() {
        //Stop listening for keyboard events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    //MARK: -Format input in textfield
    
    func textField(_ textfield: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString: NSString = moneyTextField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length <= maxLength {
            if let digit = Int(string) {
                amt = amt * 10 + digit
                moneyTextField.text = updateAmount()
            }
            if string == "" {
                amt = amt/10
                moneyTextField.text = updateAmount()
            }
        } else {
            moneyTextField.text = ""
            amt = 0
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
    
    //MARK: -Add, Subtract and reset total
    @IBAction func resetBalance(_ sender: UIBarButtonItem) {
        piggyBankView.image = UIImage(named: "piggyBankSub.gif")
        piggyBankView.animate(withGIFNamed: "piggyBankSub.gif")
        total = 0.0
        moneyLabel.text = formatMoneyLabel(total)
        saveCash(total)
    }
    
    @IBAction func addMoney(_ sender: UIButton) {
        if moneyTextField.text != "" {
            piggyBankView.image = UIImage(named: "piggyBankAdd.gif")
            piggyBankView.animate(withGIFNamed: "piggyBankAdd.gif")
            self.view.endEditing(true)
            if let money = moneyTextField.text{
                let tempMoney = money.replacingOccurrences(of: ",", with: "")
                let index = tempMoney.index(tempMoney.startIndex, offsetBy: 1)
                if let currentMoney = Double(tempMoney.suffix(from: index)){
                    total += currentMoney
                    print("The Current Money is \(currentMoney)")
                    moneyLabel?.text = formatMoneyLabel(total)
                    saveCash(total)
                }
            }
            moneyTextField.text = ""
            amt = 0
        }
    }
    
    @IBAction func subtractMoney(_ sender: UIButton) {
        if moneyTextField.text != "" {
            piggyBankView.image = UIImage(named: "piggyBankSub.gif")
            piggyBankView.animate(withGIFNamed: "piggyBankSub.gif")
            self.view.endEditing(true)
            if let money = moneyTextField.text{
                let tempMoney = money.replacingOccurrences(of: ",", with: "")
                let index = tempMoney.index(tempMoney.startIndex, offsetBy: 1)
                if let currentMoney = Double(tempMoney.suffix(from: index)){
                    total -= currentMoney
                    moneyLabel?.text = formatMoneyLabel(total)
                    saveCash(total)
                }
            }
            moneyTextField.text = ""
            amt = 0
        }
    }
    
    //MARK: -Data Manipulation Methods
    func saveCash(_ total: Double){
        if let currentFold = self.selectedFold {
            do{
                try self.realm.write{
                    currentFold.total = total
                }
            }catch{
                print("error saving context \(error)")
            }
        }
    }
    
    func loadCash() {
        if let currentFold = self.selectedFold{
            total = currentFold.total
            moneyLabel?.text = formatMoneyLabel(currentFold.total)
            saveCash(currentFold.total)
        }
        else{
            moneyLabel?.text = formatMoneyLabel(total)
        }
    }
    

}


