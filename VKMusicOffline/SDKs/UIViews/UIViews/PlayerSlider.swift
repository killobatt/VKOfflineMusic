//
//  PlayerSlider.swift
//  UIViews
//
//  Created by Vjacheslav Volodjko on 28.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
public class PlayerSlider: UISlider {

    @IBInspectable
    public var secondaryValue: Float = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var secondaryValueTintColor: UIColor = UIColor(white: 1.0, alpha: 0.0){
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public func setSecondaryTrackImage(image: UIImage?, forState state: UIControlState) {
        
    }
    
    public func secondaryTrackImageForState(state: UIControlState) -> UIImage? {
        return nil
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func drawRect(rect: CGRect)
    {
        super.drawRect(rect)
        
//        let trackRect = self.trackRectForBounds(self.bounds)
        let trackRect = CGRectMake(
            rect.origin.x,
            rect.origin.y + rect.size.height / 2.0 - 4.0,
            rect.size.width,
            8.0
            )
        
        let secondaryValueTrackRect = CGRectMake(
            trackRect.origin.x,
            trackRect.origin.y,
            CGRectGetWidth(trackRect) * CGFloat(self.secondaryValue / (self.maximumValue - self.minimumValue)),
            CGRectGetHeight(trackRect)
        )
        
        // draw secondary value progress
        var context = UIGraphicsGetCurrentContext()
        let colorComponents = CGColorGetComponents(self.secondaryValueTintColor.CGColor)
        CGContextSetFillColor(context, colorComponents)
        CGContextSetStrokeColor(context, colorComponents)
        CGContextFillRect(context, secondaryValueTrackRect)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
