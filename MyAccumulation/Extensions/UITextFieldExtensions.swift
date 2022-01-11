//  UITextFieldExtensions.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

import UIKit

extension UITextField {
    /// 返回`text`字符长度。如果为`nil`则返回`0`。
    public var length: Int {
        return self.text?.count ?? 0
    }
    
    /// 是否`text`字符串为空。
    public var isEmpty: Bool {
        return self.text?.isEmpty ?? true
    }
    
    /// 将`NSRange`转化为`UITextRange`。无效返回`nil`。
    public func textRangeFromNSRange(_ range: NSRange) -> UITextRange? {
        if range.location == NSNotFound || NSMaxRange(range) > self.length {
            return nil
        }
        
        let startPosition = position(from: beginningOfDocument, offset: range.location)!
        let endPosition = position(from: beginningOfDocument, offset: NSMaxRange(range))!
        return textRange(from: startPosition, to: endPosition)
    }
}
