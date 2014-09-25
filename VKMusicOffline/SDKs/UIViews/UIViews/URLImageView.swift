//
//  URLImageView.swift
//  VkMessanger
//
//  Created by Vjacheslav Volodko on 11.07.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

@IBDesignable
public class URLImageView: UIImageView {

    @IBInspectable
    public var imageURL : NSURL! {
        willSet (newImageURL) {
            self.loadImageWithURL(newImageURL)
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        // Drawing code
    }
    */
    
    
    private func loadImageWithURL(url: NSURL!) {
        if let imgURL = url {
            let defaults = NSUserDefaults.standardUserDefaults()
            let imageDataOpt = defaults.objectForKey(imgURL.absoluteString!) as NSData!
            if let imageData = imageDataOpt {
                self.image = UIImage(data: imageData)
                self.layoutIfNeeded()
            } else {
                var request = NSURLRequest(URL: imgURL)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(),
                completionHandler:{(response:NSURLResponse!, responseData:NSData!, error:NSError!) in
                    defaults.setObject(responseData, forKey:imgURL.absoluteString!)
                    self.image = UIImage(data: responseData)
                })
            }
        }
    }
}
