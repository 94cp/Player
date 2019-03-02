//
//  AnimatablePlayOrPauseButton.swift
//  Player
//
//  Created by chenp on 2018/9/25.
//  Copyright © 2018 chenp. All rights reserved.
//
//  https://github.com/mengxianliang/XLPlayButton

import UIKit


/// 动画播放按钮type
///
/// - pause: 显示竖线，正在播放状态
/// - play: 显示三角形，未播放状态
public enum AnimatablePlayOrPauseButtonType {
    case pause
    case play
}

open class AnimatablePlayOrPauseButton: UIButton, CAAnimationDelegate {
    
    /// 三角层
    open lazy var triangleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .butt
        layer.lineJoin = .round
        return layer
    }()
    /// 左侧竖线层
    open lazy var leftLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()
    /// 右侧竖线层
    open lazy var rightLineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()
    /// 过渡弧线层
    open lazy var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()
    
    open var isAnimating = false
    
    private var _type = AnimatablePlayOrPauseButtonType.pause {
        didSet {
            switch _type {
            case .pause: // 播放->暂停
                isAnimating = true
                // 执行画弧、画三角动画
                actionInverseAnimate(duration: animationDuration)
                // 执行竖线动画
                DispatchQueue.main.asyncAfter(deadline: .seconds(animationDuration)) {
                    self.lineInverseAnimate(duration: self.positionDuration)
                }
            case .play: // 暂停->播放
                isAnimating = true
                // 执行竖线动画
                linePositiveAnimate(duration: positionDuration)
                // 执行画弧、画三角动画
                DispatchQueue.main.asyncAfter(deadline: .seconds(positionDuration)) {
                    self.actionPositiveAnimate(duration: self.animationDuration)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .seconds(animationDuration + positionDuration)) {
                self.isAnimating = false
            }
        }
    }
    
    open var type: AnimatablePlayOrPauseButtonType {
        get {
            return _type
        }
        set {
            if isAnimating || _type == newValue { return }
            _type = newValue
        }
    }
    
    /// 画弧、画三角动画时长
    open var animationDuration: TimeInterval = 0.5
    
    /// 竖线位移动画时长
    open var positionDuration: TimeInterval = 0.3
    
    /// 线条颜色
    open var lineColor: UIColor {
        get {
            if let cgColor = triangleLayer.strokeColor {
                return UIColor(cgColor: cgColor)
            } else {
                return .clear
            }
        }
        set {
            triangleLayer.strokeColor = newValue.cgColor
            leftLineLayer.strokeColor = newValue.cgColor
            rightLineLayer.strokeColor = newValue.cgColor
            circleLayer.strokeColor = newValue.cgColor
        }
    }
    
    /// 线条宽度
    open var lineWidth: CGFloat {
        get {
            return triangleLayer.lineWidth
        }
        set {
            triangleLayer.lineWidth = newValue
            leftLineLayer.lineWidth = newValue
            rightLineLayer.lineWidth = newValue
            circleLayer.lineWidth = newValue
        }
    }
    
    open override var contentEdgeInsets: UIEdgeInsets {
        didSet {
            contentSize = CGSize(width: bounds.width - contentEdgeInsets.left - contentEdgeInsets.right,
                                 height: bounds.height - contentEdgeInsets.top - contentEdgeInsets.bottom)
            lineWidth = min(contentSize.width, contentSize.height) * 0.2
        }
    }
    
    open private(set) lazy var contentSize: CGSize = bounds.size
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    public init(frame: CGRect, type: AnimatablePlayOrPauseButtonType) {
        super.init(frame: frame)
        self._type = type
        initialize()
    }
    
    private func initialize() {
        lineColor = .white
        lineWidth = min(contentSize.width, contentSize.height) * 0.2
        
        layer.addSublayer(triangleLayer)
        layer.addSublayer(leftLineLayer)
        layer.addSublayer(rightLineLayer)
        layer.addSublayer(circleLayer)
        
        switch _type {
        case .pause:
            triangleLayer.strokeEnd = 0
            leftLineLayer.strokeEnd = 1
            rightLineLayer.strokeEnd = 1
            circleLayer.strokeEnd = 0
        case .play:
            triangleLayer.strokeEnd = 1
            leftLineLayer.strokeEnd = 1
            rightLineLayer.strokeEnd = 0
            circleLayer.strokeEnd = 0
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height * 0.2))
        trianglePath.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top))
        trianglePath.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width, y: contentEdgeInsets.top + contentSize.height * 0.5))
        trianglePath.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height))
        trianglePath.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height * 0.2))
        triangleLayer.path = trianglePath.cgPath
        
        let leftLinePath = UIBezierPath()
        leftLinePath.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top))
        leftLinePath.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height))
        leftLineLayer.path = leftLinePath.cgPath

        let rightLinePath = UIBezierPath()
        rightLinePath.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.8, y: contentEdgeInsets.top + contentSize.height))
        rightLinePath.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.8, y: contentEdgeInsets.top))
        rightLineLayer.path = rightLinePath.cgPath
        
        let circlePath = UIBezierPath()
        circlePath.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.8, y: contentEdgeInsets.top + contentSize.height * 0.8))
        circlePath.addArc(withCenter: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.5, y: contentEdgeInsets.top + contentSize.height * 0.8), radius: contentSize.width * 0.3, startAngle: 0, endAngle: .pi, clockwise: true)
        circleLayer.path = circlePath.cgPath
    }

    /// 执行正向动画，即暂停->播放
    open func actionPositiveAnimate(duration: TimeInterval) {
        let halfDuration = duration / 2
        let quarterDuration = duration / 4
        
        // 执行三角动画
        triangleLayer.strokeEndAnimate(from: 0, to: 1, animationName: .triangleAnimation, duration: duration, delegate: self)
        // 执行右侧线条动画
        rightLineLayer.strokeEndAnimate(from: 1, to: 0, animationName: .rightLineAnimation, duration: quarterDuration, delegate: self)
        // 执行画弧动画
        circleLayer.strokeEndAnimate(from: 0, to: 1, animationName: nil, duration: quarterDuration, delegate: nil)
        
        // 执行逆向画弧动画
        DispatchQueue.main.asyncAfter(deadline: .seconds(quarterDuration)) {
            self.circleLayer.circleStartAnimate(from: 0, to: 1, duration: quarterDuration)
        }
        
        // 执行左侧线条缩短动画
        DispatchQueue.main.asyncAfter(deadline: .seconds(halfDuration)) {
            self.leftLineLayer.strokeEndAnimate(from: 1, to: 0, animationName: nil, duration: halfDuration, delegate: nil)
        }
    }
    
    /// 暂停->播放竖线动画
    open func linePositiveAnimate(duration: TimeInterval) {
        let halfDuration = duration / 2
        
        //左侧缩放动画
        let leftPath1 = UIBezierPath()
        leftPath1.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height * 0.4))
        leftPath1.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height))
        leftLineLayer.path = leftPath1.cgPath
        leftLineLayer.pathAnimate(with: halfDuration)
        
        //右侧竖线位移动画
        let rightPath1 = UIBezierPath()
        rightPath1.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.8, y: contentEdgeInsets.top + contentSize.height * 0.8))
        rightPath1.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.8, y: -(contentEdgeInsets.top + contentSize.height * 0.2)))
        rightLineLayer.path = rightPath1.cgPath
        rightLineLayer.pathAnimate(with: halfDuration)
        
        DispatchQueue.main.asyncAfter(deadline: .seconds(halfDuration)) {
            //左侧位移动画
            let leftPath2 = UIBezierPath()
            leftPath2.move(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.2, y: self.contentEdgeInsets.top + self.contentSize.height * 0.2))
            leftPath2.addLine(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.2, y: self.contentEdgeInsets.top + self.contentSize.height * 0.8))
            self.leftLineLayer.path = leftPath2.cgPath
            self.leftLineLayer.pathAnimate(with: halfDuration)
            
            //右侧竖线缩放动画
            let rightPath2 = UIBezierPath()
            rightPath2.move(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.8, y: self.contentEdgeInsets.top + self.contentSize.height * 0.8))
            rightPath2.addLine(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.8, y: self.contentEdgeInsets.top + self.contentSize.height * 0.2))
            self.rightLineLayer.path = rightPath2.cgPath
            self.rightLineLayer.pathAnimate(with: halfDuration)
        }
    }
    
    /// 执行逆向动画，即播放->暂停
    open func actionInverseAnimate(duration: TimeInterval) {
        let halfDuration = duration / 2
        let quarterDuration = duration / 4
        
        // 执行三角动画
        triangleLayer.strokeEndAnimate(from: 1, to: 0, animationName: .triangleAnimation, duration: duration, delegate: self)
        // 执行左侧线条动画
        leftLineLayer.strokeEndAnimate(from: 0, to: 1, animationName: nil, duration: halfDuration, delegate: nil)
        
        // 执行画弧动画
        DispatchQueue.main.asyncAfter(deadline: .seconds(halfDuration)) {
            self.circleLayer.circleStartAnimate(from: 1, to: 0, duration: quarterDuration)
        }
        
        // 执行反向画弧和右侧放大动画
        DispatchQueue.main.asyncAfter(deadline: .seconds(halfDuration + quarterDuration)) {
            self.rightLineLayer.strokeEndAnimate(from: 0, to: 1, animationName: .rightLineAnimation, duration: quarterDuration, delegate: self)
            self.circleLayer.strokeEndAnimate(from: 1, to: 0, animationName: nil, duration: quarterDuration, delegate: nil)
        }
    }
    
    /// 播放->暂停竖线动画
    open func lineInverseAnimate(duration: TimeInterval) {
        let halfDuration = duration / 2
        
        //左侧缩放动画
        let leftPath1 = UIBezierPath()
        leftPath1.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height * 0.4))
        leftPath1.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.2, y: contentEdgeInsets.top + contentSize.height))
        leftLineLayer.path = leftPath1.cgPath
        leftLineLayer.pathAnimate(with: halfDuration)
        
        //右侧竖线位移动画
        let rightPath1 = UIBezierPath()
        rightPath1.move(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.8, y: contentEdgeInsets.top + contentSize.height * 0.8))
        rightPath1.addLine(to: CGPoint(x: contentEdgeInsets.left + contentSize.width * 0.8, y: -(contentEdgeInsets.top + contentSize.height * 0.2)))
        rightLineLayer.path = rightPath1.cgPath
        rightLineLayer.pathAnimate(with: halfDuration)
        
        DispatchQueue.main.asyncAfter(deadline: .seconds(halfDuration)) {
            //左侧位移动画
            let leftPath2 = UIBezierPath()
            leftPath2.move(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.2, y: self.contentEdgeInsets.top))
            leftPath2.addLine(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.2, y: self.contentEdgeInsets.top + self.contentSize.height))
            self.leftLineLayer.path = leftPath2.cgPath
            self.leftLineLayer.pathAnimate(with: halfDuration)
            
            //右侧竖线缩放动画
            let rightPath2 = UIBezierPath()
            rightPath2.move(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.8, y: self.contentEdgeInsets.top + self.contentSize.height))
            rightPath2.addLine(to: CGPoint(x: self.contentEdgeInsets.left + self.contentSize.width * 0.8, y: self.contentEdgeInsets.top))
            self.rightLineLayer.path = rightPath2.cgPath
            self.rightLineLayer.pathAnimate(with: halfDuration)
        }
    }
    
    // MARK: - 🔥CAAnimationDelegate🔥
    
    public func animationDidStart(_ anim: CAAnimation) {
        guard let animationName = anim.value(forKey: "animationName") as? String else { return }
        if animationName == .triangleAnimation {
            triangleLayer.lineCap = .round
        } else if animationName == .rightLineAnimation {
            rightLineLayer.lineCap = .round
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let animationName = anim.value(forKey: "animationName") as? String else { return }
        if animationName == .triangleAnimation {
            triangleLayer.lineCap = .butt
        } else if animationName == .rightLineAnimation {
            rightLineLayer.lineCap = (type == .play ? .butt : .round)
        }
    }
}

private extension CAShapeLayer {
    
    func strokeEndAnimate(from fromValue: CGFloat, to toValue: CGFloat, animationName: String?, duration: TimeInterval, delegate: CAAnimationDelegate?) {
        let strokeEndAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        strokeEndAnimation.fromValue = fromValue
        strokeEndAnimation.toValue = toValue
        strokeEndAnimation.duration = duration
        strokeEndAnimation.fillMode = .forwards
        strokeEndAnimation.isRemovedOnCompletion = false
        strokeEndAnimation.setValue(animationName, forKey: "animationName")
        strokeEndAnimation.delegate = delegate
        add(strokeEndAnimation, forKey: nil)
    }
    
    func circleStartAnimate(from fromValue: CGFloat, to toValue: CGFloat, duration: TimeInterval) {
        let circleAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeStart))
        circleAnimation.duration = duration
        circleAnimation.fromValue = fromValue
        circleAnimation.toValue = toValue
        circleAnimation.fillMode = .forwards
        circleAnimation.isRemovedOnCompletion = false
        add(circleAnimation, forKey: nil)
    }
    
    func pathAnimate(with duration: TimeInterval) {
        let pathAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        pathAnimation.duration = duration
        pathAnimation.fillMode = .forwards
        pathAnimation.isRemovedOnCompletion = false
        add(pathAnimation, forKey: nil)
    }
}

private extension String {
    static let triangleAnimation = "TriangleAnimation"
    static let rightLineAnimation = "RightLineAnimation"
}
