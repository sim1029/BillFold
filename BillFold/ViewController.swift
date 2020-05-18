//
//  ViewController.swift
//  BillFold
//
//  Created by Simon Schueller on 5/16/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var amt: Int = 0
    var total: Double = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        moneyTextField.delegate = self
        moneyTextField.placeholder = updateAmount()
        moneyTextField.keyboardType = UIKeyboardType.numberPad
        moneyLabel.text = "$0.00"
    }
    
    @IBAction func resetBalance(_ sender: UIButton) {
        total = 0
        moneyLabel.text = formatMoneyLabel(total)
    }
    
    @IBAction func addMoney(_ sender: UIButton) {
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
    
    @IBAction func subtractMoney(_ sender: UIButton) {
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
}

