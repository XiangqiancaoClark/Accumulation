//
//  QCUITextFieldDemoViewController.swift
//  Accumulation
//
//  Created by PiKaqq on 2022/1/7.
//

import UIKit

class QCUITextFieldDemoViewController : UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: QCUITextField!
    @IBOutlet weak var phoneTextField: QCUITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.setStrategy(UITextFieldMaxLengthStrategy(11))
        let phoneStrategy = UITextFieldPhoneNumberStrategy(textField: phoneTextField)
        phoneTextField.setStrategy(phoneStrategy)
    }
    
    // MARK: - Protocols
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

}
