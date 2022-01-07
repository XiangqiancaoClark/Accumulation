//  ReduceTableViewCell.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

import UIKit

/// 情景：拟物态开发时，`cell`并没有铺满屏幕。

class ReduceTableViewCell : UITableViewCell {
    
    @objc enum Location: Int {
        case top = 0, mid, bottom, single
    }
    
    @IBInspectable var location: Location = .single
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var frame: CGRect {
        get { super.frame }
        
        /// 缩小整个`cell`的大小，可以实现侧滑删除直接从内容视图右侧出现，而不是屏幕右侧。
        set {
            let inset = CGRect.Insets(top: 0, left: 15, right: 15, bottom: 0)
            let reallyRect = newValue.byInsets(inset)
            super.frame = reallyRect
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _addCornersByMask()
    }
    
    private func _addCornersByMask() {
        var bezierPath: UIBezierPath? = nil
        switch location {
        case .top:
            bezierPath = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 8, height: 8))
        case .bottom:
            bezierPath = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 8, height: 8))
        case .single:
            bezierPath = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: 8, height: 8))
        default: break
        }
        
        if let path = bezierPath {
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = UIColor.white.cgColor
            self.layer.mask = layer
        }
    }
    
}
