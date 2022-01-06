//
//  ViewController.swift
//  SwipableCell
//
//  Created by Qiancaoxiang on 2022/1/6.
//

import UIKit

class ViewController : UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = SwipableCell(style: .default, reuseIdentifier: "cell")
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: 100, height: 80))
            label.tag = 100
            (cell as! SwipableCell).mainContentView.addSubview(label)
            (cell as! SwipableCell).delegate = self
        }
        (cell?.viewWithTag(100) as? UILabel)?.text = "index-\(indexPath.row + 1)"
        return cell!
    }
}


extension ViewController : SwipableCellDelegate {
    func numberOfItemsInCell(_ cell: SwipableCell) -> UInt {
        return 3
    }
    
    func widthForItemInCell(_ cell: SwipableCell, atIndex index: UInt) -> CGFloat {
        return 80
    }
    
    func viewForItemInCell(_ cell: SwipableCell, atIndex index: UInt) -> UIView {
        let view = UIView()
        if index == 0 {
            view.backgroundColor = .red
        } else if index == 1 {
            view.backgroundColor = .blue
        } else {
            let top = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
            top.addTarget(self, action: #selector(_onTopButton(_:)), for: .touchUpInside)
            top.backgroundColor = .gray
            view.addSubview(top)
            let bottom = UIButton(frame: CGRect(x: 0, y: 40, width: 80, height: 40))
            bottom.backgroundColor = .green
            view.addSubview(bottom)
        }
        return view
    }
    
    func cell(_ cell: SwipableCell, didTappedItemAtIndex index: UInt) {
        print(#function + ", index-\(index)")
    }
    
    func didEndEditingCell(_ cell: SwipableCell) {
    }
    
    func didBeginEditingCell(_ cell: SwipableCell) {
    }
    
    @objc private func _onTopButton(_ sender: UIButton) {
        print(#function)
    }
}
