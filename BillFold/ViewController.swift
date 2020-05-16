//
//  ViewController.swift
//  BillFold
//
//  Created by Simon Schueller on 5/16/20.
//  Copyright © 2020 Simon Schueller. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var moneyLabel: UILabel!
    
    var money = "$0.00"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        moneyLabel.text = money
    }
    
    @IBAction func addMoney(_ sender: UIButton) {
        if let money = moneyTextField.text{
            moneyLabel.text = "$" + money
        }
        moneyTextField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
      let allowedCharacters = CharacterSet.decimalDigits
      let characterSet = CharacterSet(charactersIn: string)
      return allowedCharacters.isSuperset(of: characterSet)
    }

}

