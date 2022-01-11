//  QCUITextField.swift
//  Copyright (c) 2019年 Qiancaoxiang Clark. All rights reserved.

import UIKit

/// 实现`UITextField`的占位符颜色和最大输入长度的功能。

/// `UITextField`默认的`placeholder`颜色。
public let UITextFieldDefaultPlaceholderColor = UIColor(red: 0.24, green: 0.24, blue: 0.25, alpha: 0.3)

public class QCUITextField : UITextField {
    
    public override var placeholder: String? {
        get { super.placeholder }
        
        set {
            if newValue != super.placeholder {
                super.placeholder = newValue
                _updatePlaceholderDisplay()
            }
        }
    }
    /// 占位符的颜色。
    @IBInspectable var placeholderColor: UIColor {
        didSet { _updatePlaceholderDisplay() }
    }
    /// 控制字符输入的策略。
    private var delegator: _QCUITextFieldDelegator?
    
    public override init(frame: CGRect) {
        placeholderColor = UITextFieldDefaultPlaceholderColor
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        placeholderColor = UITextFieldDefaultPlaceholderColor
        super.init(coder: coder)
    }
    
    /// 设置输入控制的策略。该策略遵循`QCUITextFieldStrategy`协议。如果设置了则会修改`delegate`的
    /// 指向，使用时请勿再次重置`delegate`，否则会导致策略失效。
    /// @Parameter strategy: 实现策略的对象，提供了最大字符输入的策略`UITextFieldMaxLengthStrategy`。
    public func setStrategy(_ strategy: QCUITextStrategy) {
        delegator = _QCUITextFieldDelegator(self, strategy: strategy)
        super.delegate = delegator
    }
    
    
    // MARK: - 私有方法
    
    private func _updatePlaceholderDisplay() {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor : placeholderColor])
    }
    
}


// MARK: - 实现代理方法

fileprivate class _QCUITextFieldDelegator : NSObject, UITextFieldDelegate {
    
    weak var textField: QCUITextField!
    var strategy: QCUITextStrategy!
    
    init(_ textField: QCUITextField, strategy: QCUITextStrategy) {
        self.textField = textField
        self.strategy = strategy
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
        return strategy != nil ?
        strategy.textField(
            textField,
            shouldChangeCharactersIn: range,
            replacementString: string) : true
    }
    
}
