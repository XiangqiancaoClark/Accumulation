//  StringExtensions.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

import Foundation

extension String {
    /// 字符长度。由于中文在计算长度时，一个中文应该按两个字符长度计算。
    /// 可以通过ASCII的方式来计算。
    public var lengthWithinASCII: Int {
        var asciilength = 0
        for i in 0..<count {
            let character = (self as NSString).character(at: i)
            if isascii(Int32(character)) != 0 {
                asciilength += 1
            } else {
                asciilength += 2
            }
        }
        return asciilength
    }
    
    public subscript(integerIndex: Int) -> Character {
        let index = self.index(startIndex, offsetBy: integerIndex)
        return self[index]
    }
    
    public subscript(integerRange: Range<Int>) -> String {
        let start = self.index(startIndex, offsetBy: integerRange.lowerBound)
        let end = self.index(startIndex, offsetBy: integerRange.upperBound)
        return String(self[start..<end])
    }
    
    public subscript(integerClosedRange: ClosedRange<Int>) -> String {
        return self[integerClosedRange.lowerBound..<(integerClosedRange.upperBound + 1)]
    }
}

extension String {
    public init?(_ from: UnsafePointer<CChar>) {
        self.init(cString: from, encoding: .utf8)
    }
}

extension String {
    /// 替换字符。将`range`内的文字替换为`string`。
    public func replacingSubstring(in range: NSRange, with string: String) -> String {
        if NSMaxRange(range) > count{
            assert(false, "Relacing substring with a overflowed range.")
        }
        
        if string.count == 0 || range.length == 0 {
            return self
        }
        
        let start = self.index(startIndex, offsetBy: range.location)
        let end = self.index(startIndex, offsetBy: NSMaxRange(range))
        return self.replacingCharacters(in: start..<end, with: string)
    }
}
