//  UIViewExtensions.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

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


// MARK: - 常用的一些动画封装

extension UIView {
    public enum ShakeDirection {
        case horizontal
        case vertical
    }
    
    public enum ShakeAnimationType {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }
    
    public enum AngleUnit {
        case degrees
        case radians
    }
    
    /// 视图渐现效果。如果视图被隐藏了，先取消隐藏，然后执行`alpha=1`的动画。
    public func fadeIn(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }
    
    /// 视图渐隐效果。如果视图被隐藏了，先取消隐藏，然后执行`alpha=0`的动画。
    public func fadeOut(duration: TimeInterval = 1, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: completion)
    }
    
    /// 实现`shake`的动画效果。
    public func shake(
        direction: ShakeDirection = .horizontal,
        duration: TimeInterval = 1,
        animationType: ShakeAnimationType = .easeOut,
        completion: ((Bool) -> Void)? = nil) {
            UIView.animate(withDuration: duration, animations: {
                let animation: CAKeyframeAnimation
                switch direction {
                case .horizontal:
                    animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
                case .vertical:
                    animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
                }
                switch animationType {
                case .linear:
                    animation.timingFunction = CAMediaTimingFunction(
                        name: CAMediaTimingFunctionName.linear)
                case .easeIn:
                    animation.timingFunction = CAMediaTimingFunction(
                        name: CAMediaTimingFunctionName.easeIn)
                case .easeOut:
                    animation.timingFunction = CAMediaTimingFunction(
                        name: CAMediaTimingFunctionName.easeOut)
                case .easeInOut:
                    animation.timingFunction = CAMediaTimingFunction(
                        name: CAMediaTimingFunctionName.easeInEaseOut)
                }
                animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
                self.layer.add(animation, forKey: "shake")
            }, completion: completion)
    }
    
    /// 实现缩放的动画效果。
    public func scale(
        by offset: CGPoint,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: .curveLinear,
                animations: { () -> Void in
                self.transform = self.transform
                        .scaledBy(x: offset.x, y: offset.y)
            }, completion: completion)
        } else {
            transform = transform
                .scaledBy(x: offset.x, y: offset.y)
            completion?(true)
        }
    }
    
    /// 实现旋转的动画效果
    public func rotate(
        toAngle angle: CGFloat,
        ofType type: AngleUnit,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
        let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
        let aDuration = animated ? duration : 0
        UIView.animate(withDuration: aDuration, animations: {
            self.transform = self.transform
                .concatenating(CGAffineTransform(rotationAngle: angleWithType))
        }, completion: completion)
    }
}
