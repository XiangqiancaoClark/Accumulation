//  NSRangeExtensions.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

import Foundation

extension NSRange {
    /// 转化为区间。
    public func toClosedRange() -> ClosedRange<Int> {
        return self.location...NSMaxRange(self)
    }
}
