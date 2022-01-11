//  ExceedButton.swift
//  Copyright (c) 2019年 Qiancaoxiang Clark. All rights reserved.

import UIKit

/// 设置按钮的热区，可以超过/缩小其点击范围。

public class ExceedButton : UIButton {
    
    // 热区范围。`nil`表示默认不进行更改。注意：热区是以按钮中心为中点的区域。
    var hotSize: CGSize?
    
    /// 响应链会传递到该方法，返回`false`则不会响应对应的事件，返回`true`则会响应对应事件。
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let hotSize = hotSize else {
            return super.point(inside: point, with: event)
        }
        
        let hotRect = CGRect(
            x: (self.width - hotSize.width) / 2,
            y: (self.height - hotSize.height) / 2,
            width: hotSize.width,
            height: hotSize.height)
        return hotRect.contains(point)
    }
    
}
