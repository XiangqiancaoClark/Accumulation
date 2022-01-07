//  UIButtonExtensions.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

import UIKit
import ObjectiveC

fileprivate struct UIButtonAssoicateKey {
    static var object: Void?
}

extension UIButton {
    /// 给`UIButton`添加关联对象。
    public var object: Any? {
        set {
            objc_setAssociatedObject(
                self,
                &UIButtonAssoicateKey.object,
                newValue,
                .OBJC_ASSOCIATION_RETAIN)
        }
        
        get {
            objc_getAssociatedObject(self, &UIButtonAssoicateKey.object)
        }
    }
}

extension UIButton {
    /// 设置不同状态的背景颜色。原理：根据颜色生产图片，设置背景图片。
    public func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(colorImage, for: state)
    }
}
