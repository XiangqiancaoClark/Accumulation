//  UserDefaultExtensions.swift
//  Copyright (c) 2022年 Qiancaoxiang Clark. All rights reserved.

import Foundation

extension UserDefaults {
    /// 通过下标的方式访问`UserDefaults`中存储的数据。
    public subscript(k: String) -> AnyObject? {
        set { set(newValue, forKey: k) }
        get { return object(forKey: k) as AnyObject? }
    }
}
