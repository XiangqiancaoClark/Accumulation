//
//  ExceedButtonDemoViewController.swift
//  Accumulation
//
//  Created by PiKaqq on 2022/1/7.
//

import UIKit

class ExceedButtonDemoViewController : UIViewController {

    @IBOutlet weak var button: ExceedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.hotSize = CGSize(width: 120, height: 50)
    }
    
    @IBAction private func _onButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "热区按钮被点击", preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        alert.addAction(action)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
}
