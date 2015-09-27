//
//  VMLyricsController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 01.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class VMLyricsController: UIViewController {
    
    var lyrics: VMLyrics! {
        didSet {
            if (lyrics != nil && lyrics.text == nil) {
                lyrics.loadText(completion: { (error: NSError!) -> Void in
                    if (self.textView != nil) {
                        self.updateUI()
                    }
                })
            }
            self.updateUI()
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleBarItem: UINavigationItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - UIViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        
        if let textView = self.textView {
            if (self.lyrics != nil) {
                textView.text = self.lyrics.text
            } else {
                textView.text = ""
            }
        }
        
        if let audio = lyrics?.audio {
            self.title = audio.title as String?
        }
        
        NSLog("self.parentViewController: \(self.parentViewController)")
        
        if let _ = self.navigationBar {
            NSLog("self.navigationBar.topItem: \(self.navigationBar.topItem)")
        
            self.navigationBar.topItem?.title = self.title
            
            if self.parentViewController is VMAudioControllsController || self.parentViewController is UINavigationController {
                self.navigationBar.hidden = true
                if let textViewTopConstraint = self.textViewTopConstraint {
                    textViewTopConstraint.active = false
                }
            } else {
                self.navigationBar.hidden = false
                if let textViewTopConstraint = self.textViewTopConstraint {
                    textViewTopConstraint.active = true
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    

}
