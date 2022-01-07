//
//  SwipableCellDemoViewController.swift
//  Accumulation
//
//  Created by PiKaqq on 2022/1/7.
//

import UIKit
import SnapKit

class DemoSwipableCell : SwipableCell {
    weak var label: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let label = UILabel()
        self.mainContentView.addSubview(label)
        self.label = label
        label.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate let DemoSwipableCellId = "DemoSwipableCell"

class SwipableCellDemoViewController : UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80
        self.tableView.register(DemoSwipableCell.self, forCellReuseIdentifier: DemoSwipableCellId)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DemoSwipableCellId) as! DemoSwipableCell
        cell.label.text = "index-\(indexPath.row + 1)"
        cell.delegate = self
        return cell
    }
}

extension SwipableCellDemoViewController : SwipableCellDelegate {
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
