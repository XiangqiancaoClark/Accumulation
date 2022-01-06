//
//  UIViewExtensions.swift
//  SwipableCell
//
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.
//

import UIKit

extension UIView {
    public var size: CGSize {
        set { height = newValue.height; width = newValue.width }
        get { return frame.size }
    }
    
    public var height: CGFloat {
        set { frame.size.height = newValue }
        get { return frame.size.height }
    }
    
    public var width: CGFloat {
        set { frame.size.width = newValue }
        get { return frame.size.width }
    }

    public var x: CGFloat {
        set { frame.origin.x = newValue }
        get { return frame.origin.x }
    }

    public var y: CGFloat {
        set { frame.origin.y = newValue }
        get { return frame.origin.y }
    }
}
