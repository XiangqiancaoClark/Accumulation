//  SwipableCell.swift
//  Copyright (c) 2019年 Qiancaoxiang Clark. All rights reserved.

import UIKit

/// 一个支持自定义侧滑按钮的`UITableViewCell`。支持自己设置没一个侧滑菜单的样式，如果不需要系统回
/// 调则可以自己添加按钮自己控制。
/// 注意，笔者认为侧滑菜单的个数一但确定了就不会再更改，但是每个菜单`item`的状态可以进行改变。
/// 使用时，继承自`SwipableCell`，并且在`mainContentView`中添加子控件。

/// 侧滑手势开始响应的通知名字。
fileprivate let panGestrueDidBeginNotificationName = Notification.Name("QC_panGestrueDidBeginNotificationName")

@objc public protocol SwipableCellDelegate {
    /// 返回`cell`对应的侧滑菜单数量。
    /// @Parameters: `cell`中`item`的个数。
    func numberOfItemsInCell(_ cell: SwipableCell) -> UInt
    
    /// 返回`cell`中对应下标的`item`的宽度；高度会根据`cell`高度填充。
    /// @Parameters:
    ///  - cell: `item`所在的`cell`。
    ///  - index: `item`在的`cell`中对应的下标。
    ///  @Return: `item`的宽度.
    func widthForItemInCell(_ cell: SwipableCell, atIndex index: UInt) -> CGFloat
    
    /// 返回`cell`中对应下标的样式。内部会使用`UIButton`将其包装，但是你任然可以自己在容器中
    /// 添加其他的按钮，自己实现点击事件。在自行添加按钮时，需要将按钮直接放置在返回的容器中，不
    /// 能层级过深。注意：每次侧滑开始之前都会请求该方法一次，一方面可以实现更新，另外一方面是为
    /// 了尽量的减少内存消耗，因为每次消失的时候都会将其移除。
    /// @Parameters:
    ///  - cell: `item`所在的`cell`。
    ///  - index: `item`在的`cell`中对应的下标。
    ///  @Return: `item`的样式.
    func viewForItemInCell(_ cell: SwipableCell, atIndex index: UInt) -> UIView
    
    /// 当`cell`中的`item`被点击时调用。
    /// @parameters:
    ///  - cell: `item`所在的`cell`。
    ///  - index: `item`在的`cell`中对应的下标。
    @objc optional func cell(_ cell: SwipableCell, didTappedItemAtIndex index: UInt)
    
    /// 侧滑展开完成后调用。
    @objc optional func didBeginEditingCell(_ cell: SwipableCell)
    
    /// 侧滑关闭完成后调用。
    @objc optional func didEndEditingCell(_ cell: SwipableCell)
}

fileprivate struct SwipableCellConfigurations {
    // `item`个数
    let numberOfItems: UInt
    // 每个`item`的宽度
    let widthForItems: [CGFloat]
    
    // 如果有`item`则返回`true`，否则返回`false`。
    var haveItem: Bool {
        return numberOfItems > 0
    }
    
    // 所有的`item`的宽度。
    var sumOfWidth: CGFloat {
        return widthForItems.reduce(0, +)
    }
}

public class SwipableCell : UITableViewCell {
    
    // `item`的配置信息。
    private var _configurations: SwipableCellConfigurations!
    // 用于`cell`内容布局的容器视图。
    private lazy var _mainContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addGestureRecognizer(_panGesture)
        self.contentView.addSubview(view)
        return view
    } ()
    // 单击手势。单击时收起侧滑菜单。
    private lazy var _tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(_onTap(_:)))
        return tap
    } ()
    // 侧滑手势。
    private lazy var _panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(_onPan(_:)))
        pan.delegate = self
        return pan
    } ()
    /// 持有新添加的`item`容器视图。
    private weak var _buttonContainerView: UIView?
    /// 是否为打开状态，`true`表示为打开状态，否则为关闭状态。
    private var _isOpend: Bool = false
    
    // 继承`cell`时，子视图的容器视图。
    var mainContentView: UIView {
        return _mainContentView
    }
    
    weak var delegate: SwipableCellDelegate? {
        willSet { _setDelegate(newValue) }
    }
    
    
    // MARK: - 布局
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        /// 因为`contentView`是在`tableView`完全初始化出来后才会布局的。
        /// 保证只在初始化时设置一次其`frame`。
        if _mainContentView.frame == .zero {
            _mainContentView.frame = contentView.bounds
        }
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        _close()
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        /// 当被添加到`tableView`时，监听滚动，关闭侧滑菜单。
        if newSuperview != nil {
            newSuperview?.addObserver(
                self,
                forKeyPath: "contentOffset",
                options: .new,
                context: nil)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(_onNotification(_:)),
                name: panGestrueDidBeginNotificationName,
                object: nil)
        } else {
            newSuperview?.removeObserver(self, forKeyPath: "contentOffset")
            NotificationCenter.default.removeObserver(
                self,
                name: panGestrueDidBeginNotificationName,
                object: nil)
        }
    }
    
    
    // MARK: - 响应方法
    
    @objc private func _onTap(_ tap: UITapGestureRecognizer) {
        _close()
    }
    
    @objc private func _onPan(_ pan: UIPanGestureRecognizer) {
        // 获取侧滑手势的速度。大于0表示向右，小于0表示向左。
        let velocity = pan.velocity(in: pan.view)
        
        switch pan.state {
        case .began:
            /// 通知其他已经处于打开状态的`cell`关闭侧滑菜单。
            NotificationCenter.default.post(name: panGestrueDidBeginNotificationName, object: self)
        case .changed:
            let translation = pan.translation(in: pan.view)
            /// 这里保证了一但侧滑向左有显示侧滑菜单的情况就要一定能够有一个菜单视图能够显示。
            /// 例如：开始向右侧滑，然后向左侧滑的情况。
            if translation.x < 0 {
                /// 添加侧滑菜单。如果已经添加了则不再重复添加，如果没有则新添加。
                _buttonContainerView == nil ? (_buttonContainerView = _addItems()) : ()
                
                /// 如果侧滑超过了所有`item`的宽，则不在对其进行位移，保证刚好所有的`item`显示完全。
                if abs(translation.x) > _configurations.sumOfWidth {
                    _mainContentView.frame = contentView.frame
                        .offsetBy(dx: -_configurations.sumOfWidth, dy: 0)
                    return
                }
            }
            
            /// 避免打开状态下，继续左滑。
            if _isOpend && (_mainContentView.x + translation.x) < -_configurations.sumOfWidth  { return }
            
            /// 如果为打开状态，则手势跟随关闭。否则为打开。
            if _isOpend {
                let toRect = contentView.frame
                    .offsetBy(dx: -_configurations.sumOfWidth, dy: 0)
                    .offsetBy(dx: max(0, min(translation.x, _configurations.sumOfWidth)), dy: 0)
                _mainContentView.frame = toRect
            } else {
                _mainContentView.frame = contentView.frame
                        .offsetBy(dx: min(0, translation.x), dy: 0)
            }
        case .cancelled, .ended:
            /// 如果有向右滑动的趋势，则关闭。否则就打开。
            if velocity.x > 0 {
                _close()
            } else {
                _open()
            }
        default: break
        }
    }
    
    @objc private func _onButton(_ button: UIButton) {
        let indexString = (button.object as! String)
            .replacingOccurrences(of: "button-tag:", with: "")
        let index = UInt(indexString)!
        /// 通过代理传递点击事件。
        delegate?.cell?(self, didTappedItemAtIndex: index)
        _close()
    }
    
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?) {
            if keyPath == "contentOffset" && _isOpend {
                _close()
            }
    }
    
    @objc private func _onNotification(_ notice: Notification) {
        /// 如果不是当前响应手势的`cell`，并且为打开状态，则关闭侧滑菜单。
        if let otherCell = notice.object as? SwipableCell,
           otherCell != self, _isOpend {
            _close()
        }
    }
    
    @objc private func _onSubButton(_ sender: UIButton) {
        _close()
    }
    
    // MARK: - Protocol
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        /// 只处理添加的侧滑手势
        if gestureRecognizer != _panGesture {
            return true
        }
        
        let velocity = _panGesture.velocity(in: _panGesture.view)
        /// 只有侧滑手势的水平速度大于垂直速度的三倍才响应。
        if abs(velocity.x) > 3 * abs(velocity.y) {
            return true
        }
        
        return false
    }
    
    
    // MARK: - 私用方法
    // MARK: - 打开/关闭侧滑菜单
    
    private func _open() {
        _isOpend = true
        /// 获取`_mainContentView`偏移后的`frame`。
        let mainContentDestRect = contentView.frame
            .offsetBy(dx: -_configurations.sumOfWidth, dy: 0)
        UIView.animate(withDuration: 0.25) {
            self._mainContentView.frame = mainContentDestRect
        } completion: { _ in
            self._mainContentView.addGestureRecognizer(self._tapGesture)
            self.delegate?.didBeginEditingCell?(self)
        }
    }
    
    private func _close() {
        _isOpend = false
        UIView.animate(withDuration: 0.25) {
            self._mainContentView.frame = self.contentView.bounds
        } completion: { _ in
            self._removeItems()
            self._mainContentView.removeGestureRecognizer(self._tapGesture)
            self.delegate?.didEndEditingCell?(self)
        }
    }
    
    // MARK: - Others
    
    private func _setDelegate(_ delegate: SwipableCellDelegate?) {
        /// 如果设置的代理对象为`nil`则直接断言报错。
        guard let delegate = delegate else {
            assert(false, "You have set a nil delegate for SwipableCell.")
        }
        
        /// 1.获取`item`数量。
        let numberOfItems = delegate.numberOfItemsInCell(self)
        
        // 2.获取每个`item`的宽度。如果没有`item`，则为宽度数组为空数组。并移除侧滑手势。
        if numberOfItems == 0 {
            _configurations = SwipableCellConfigurations(
                numberOfItems: numberOfItems,
                widthForItems: [])
            _mainContentView.removeGestureRecognizer(_panGesture)
        } else {
            var widthForItems = [CGFloat] ()
            for idx in 0..<numberOfItems {
                let width = delegate.widthForItemInCell(self, atIndex: idx)
                assert(width != 0, "You have set a zero width item in SwipableCell.")
                widthForItems.append(width)
            }
            _configurations = SwipableCellConfigurations(
                numberOfItems: numberOfItems,
                widthForItems: widthForItems)
        }
    }
    
    private func _addItems() -> UIView? {
        /// 如果没有`item`需要显示。
        if !_configurations.haveItem { return nil }
        
        let view = UIView(frame: contentView.bounds)
        /// 添加`item`。
        var sumOfWidth: CGFloat = 0
        for idx in 0..<_configurations.numberOfItems {
            /// 如果返回的视图为空，则断言报错。
            guard let content = delegate?.viewForItemInCell(self, atIndex: idx) else {
                assert(false, "You have returned a nil view in SwipableCell.")
            }
            
            /// 添加按钮
            let width = _configurations.widthForItems[Int(idx)]
            sumOfWidth += width
            let button = UIButton(type: .custom)
            button.frame = CGRect(
                x: view.width - sumOfWidth,
                y: 0,
                width: width,
                height: view.height)
            content.frame = button.bounds
            /// 如果包含有按钮，那么则不响应代理的回调。
            let contentSubButtons = content.subviews
                .filter { $0 is UIButton } as! [UIButton]
            content.isUserInteractionEnabled = contentSubButtons.count > 0
            /// 添加内部点击事件，方便关闭菜单。
            for subButton in contentSubButtons {
                subButton.addTarget(
                    self, action:
                        #selector(_onSubButton(_:)),
                    for: .touchUpInside)
            }
            button.addSubview(content)
            button.object = "button-tag:\(idx)"
            button.addTarget(self, action: #selector(_onButton(_:)), for: .touchUpInside)
            view.clipsToBounds = true
            view.addSubview(button)
        }
        /// 将添加的按钮插入到主视图下方。
        contentView.insertSubview(view, belowSubview: _mainContentView)
        return view
    }
    
    /// 移除已经添加的按钮容器视图。
    private func _removeItems() {
        _buttonContainerView?.removeFromSuperview()
    }
    
}
