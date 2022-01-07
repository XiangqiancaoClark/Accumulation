//  CGRectExtension.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

import CoreGraphics

extension CGRect {
    public struct Insets {
        let top: CGFloat
        let left: CGFloat
        let right: CGFloat
        let bottom: CGFloat
    }
    
    /// 保持中心位置不变，将当前的`rect`缩小或扩大，并获得新的`rect`。
    public func byInsets(_ insets: CGRect.Insets) -> CGRect {
        let y = self.origin.y + insets.top
        let x = self.origin.x + insets.left
        let width = self.size.width - (insets.left + insets.right)
        let height = self.size.height - (insets.top + insets.bottom)
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
