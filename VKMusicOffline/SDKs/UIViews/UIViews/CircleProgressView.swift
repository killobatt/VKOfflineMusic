//
//  CircleProgressView.swift
//  UIViews
//
//  Created by Guest on 27/11/14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
public class CircleProgressView: UIView {

    @IBInspectable  // 0.0 .. 1.0, default is 0.0. values outside are pinned.
    public var progress: Float = 0.0 {
        didSet {
            self.progressLayer.strokeStart = 0.0
            self.progressLayer.strokeEnd = CGFloat(self.progress)
        }
    }
    
    @IBInspectable
    public var radius: CGFloat = 20.0
    
    @IBInspectable
    public var progressTintColor: UIColor = UIColor.blueColor() {
        didSet {
            self.progressLayer.strokeColor = self.progressTintColor.CGColor
        }
    }
    
    @IBInspectable
    public var trackTintColor: UIColor = UIColor.grayColor() {
        didSet {
            self.trackLayer.strokeColor = self.trackTintColor.CGColor
        }
    }
    
    @IBInspectable
    public var trackLineWidth: CGFloat = 2.0 {
        didSet {
            self.trackLayer.lineWidth = self.trackLineWidth
            self.progressLayer.lineWidth = self.trackLineWidth
        }
    }
    
    // MARK: - Animation
    
    private var isAnimated = false
    
    private var progressEndValue: Float = 0 // progress value that will be set after animation is complete
    
    public func setProgress(progress: Float, animated: Bool) {
        if (animated) {
            if (self.isAnimated) {
                NSLog("CircleProgressView Trying to set progress \(progress) animated while other animation is running")
                return
            }
            
            self.isAnimated = true
            self.progressEndValue = progress
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = self.progress
            animation.toValue = self.progressEndValue
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.duration = 0.1
            animation.delegate = self
            self.progressLayer.addAnimation(animation, forKey: "progress")
        } else {
            self.progress = progress
        }
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.progress = self.progressEndValue
        self.isAnimated = false
    }
    
    // MARK: - Overrides
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayers()
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(2.0 * self.radius, 2.0 * self.radius)
    }
    
    override public var bounds : CGRect {
        didSet {
            let center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5)
            self.trackLayer.position = center
            self.progressLayer.position = center
        }
    }
    
    // MARK: - Drawing
    
    private var trackLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    
    private func setupLayers() {
        let center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5)
        let path = UIBezierPath(arcCenter: CGPointZero, radius: self.radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(1.5 * M_PI), clockwise: true)
        self.trackLayer = CAShapeLayer()
        self.trackLayer.path = path.CGPath
        self.trackLayer.fillColor = UIColor.clearColor().CGColor
        self.trackLayer.strokeColor = self.trackTintColor.CGColor
        self.trackLayer.allowsEdgeAntialiasing = true
        self.trackLayer.lineWidth = self.trackLineWidth
        self.trackLayer.position = center
        self.layer.addSublayer(self.trackLayer)
        
        self.progressLayer = CAShapeLayer()
        self.progressLayer.path = path.CGPath
        self.progressLayer.fillColor = UIColor.clearColor().CGColor
        self.progressLayer.strokeColor = self.progressTintColor.CGColor
        self.progressLayer.strokeEnd = CGFloat(self.progress)
        self.progressLayer.allowsEdgeAntialiasing = true
        self.progressLayer.lineWidth = self.trackLineWidth
        self.progressLayer.position = center
        self.layer.addSublayer(self.progressLayer)
    }
    
}