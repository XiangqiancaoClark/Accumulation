//  QCUITextStrategy.swift
//  Copyright (c) 2019年 Qiancaoxiang Clark. All rights reserved.

import UIKit

/// 用于控制字符输入的策略。
public protocol QCUITextStrategy {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool
}


// MARK: - 控制最大输入字符数的策略

public class UITextFieldMaxLengthStrategy : QCUITextStrategy {
    private let maxLength: Int
    
    init(_ maxLength: Int) {
        self.maxLength = maxLength
    }
    
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            if maxLength < Int.max {
                /// 在中文输入过程中，输入多个字母其实是一个汉字，这个时候`markedTextRange`不为空，并
                /// 且应该不影响其输入。
                /// `range.length == 0`的判断是因为在输入中文的过程中，拼音输入完成后，会选择对应的中
                /// 文，这个时候就需要对其进行判断是否超长了。
                if textField.markedTextRange != nil && range.length == 0 {
                    return true
                }
                
                /// 如果`range`超过了字符串的最大长度，需要调整到范围内做处理。
                if NSMaxRange(range) > textField.length {
                    let length = range.length - (NSMaxRange(range) - textField.length)
                    let range = NSMakeRange(range.location, length)
                    if range.length > 0 {
                        if let textRange = textField.textRangeFromNSRange(range) {
                            textField.replace(textRange, withText: string)
                        }
                        return false
                    }
                }
                
                /// 允许删除。删除按钮时`string`为空，`range.length`等于`1`。
                if string.isEmpty && range.length > 0 {
                    return true
                }
                
                /// 如果超过最大字符范围，则需要裁减`string`的内容。
                /// 为什么这里要减去`range.length`呢？
                /// 因为`range`是此时实实在在按下的符号，在输入中文时，这里是被选中的，而当完成输入时，这部分内容会被
                /// `string`所替换。所以实际长度应该是`textField.length + string.count`，但是此时输入的中文并
                /// 没有选则，表示还在输入中，不应该就此中断输入。
                if textField.length + string.count - range.length > maxLength {
                    /// 确认要替换的文字了，此时可能会超出限制长度，需要将其修改到规定长度内。
                    let allowLength = maxLength - (textField.length - range.length)
                    let allowText = string[0..<allowLength]
                    textField.text = textField.text?.replacingSubstring(in: range, with: allowText)
                    
                    /// 文字修改完后，需要保持光标的相对位置不变。
                    /// 由于系统会在下一个`runloop`到来的时候重置，所以这里也放在队列中等待下一次`runloop`执行，避
                    /// 免被系统的覆盖。
                    /// Refer: https://blog.csdn.net/weixin_42163902/article/details/104075478
                    /// 这里按原文使用`DispatchQueue.main.asyncAfter(deadline: .now())`依然OK，只是目前这种
                    /// 写法感觉要简单点。
                    DispatchQueue.main.async {
                        let cursorRange = NSMakeRange(range.location + allowText.count, 0)
                        textField.selectedTextRange = textField.textRangeFromNSRange(cursorRange)
                    }
                    
                    return false
                }
                
            }
            return true
        }
}


// MARK: - 电话号输入策略

/// 电话号格式：### #### #### ，中间为分隔符

public class UITextFieldPhoneNumberStrategy : NSObject, QCUITextStrategy {
    enum Separator : String {
        /// 空格分隔符。
        case blank = " "
        /// 横线分隔符。
        case line = "-"
    }
    
    private let _separator: Separator
    private weak var _textField: UITextField!
    private let _pairClass: _UITextFieldPhoneNumberStrategyRuntimeClass
    
    init(_ separator: Separator = .blank, textField: QCUITextField) {
        /// 设置数字键盘。
        textField.keyboardType = .numberPad
        _separator = separator
        _textField = textField
        
        /// 通过`runtime`实现`KVO`的原理来静止输入框的粘贴复制功能。
        _pairClass = _UITextFieldPhoneNumberStrategyRuntimeClass
            .strategyRuntimeClassObject(for: textField)
        _pairClass.overrideFunctions()
    }
    
    /// Refer: https://stackoverflow.com/questions/51784571/cursor-goes-to-end-after-setting-text-to-uitextfield-inside-shouldchangecharacte
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            /// 只能输入数字。
            guard CharacterSet(charactersIn: "0123456789")
                    .isSuperset(of: CharacterSet(charactersIn: string)) else {
                return false
            }
            
            
            
            return true
        }
    
}


fileprivate class _UITextFieldPhoneNumberStrategyRuntimeClass : NSObject {
    static let subclassPrefix = "__UITextFieldPhoneNumberStrategy_"
    
    var objectClass: AnyClass!
    var subclass: AnyClass!
    
    class func strategyRuntimeClassObject(for object: UITextField) -> Self {
        let objectClass: AnyClass = object_getClass(type(of: object))!
        let subclassName = _UITextFieldPhoneNumberStrategyRuntimeClass.subclassPrefix
        + String(class_getName(objectClass))!
        guard let subclass = objc_allocateClassPair(objectClass, subclassName, 0) else {
            assert(false, "When the copy and paste function of the phone number input box is disabled, the creation of the derived class fails!")
        }
        objc_registerClassPair(subclass)
        object_setClass(object, subclass)
        
        let runtimeClass = _UITextFieldPhoneNumberStrategyRuntimeClass()
        runtimeClass.objectClass = objectClass
        runtimeClass.subclass = subclass
        return runtimeClass as! Self
    }
    
    func overrideFunctions() {
        let classSelector = NSSelectorFromString("class")
        let classMethod = class_getInstanceMethod(objectClass, classSelector)!
        let classOverrideMethod = class_getInstanceMethod(
            _UITextFieldPhoneNumberStrategyRuntimeClass.self,
            #selector(__override_class_function(_:_:)))!
        let classMethodOverrideIMP = method_getImplementation(classOverrideMethod)
        class_addMethod(subclass, classSelector, classMethodOverrideIMP, method_getTypeEncoding(classMethod))
    }
    
    @objc func __override_class_function(_ self: Any, _ selector: Selector) -> AnyClass {
        return class_getSuperclass(object_getClass(self))!
    }
}
