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
            if (lyrics.text == nil) {
                lyrics.loadText(completion: { (error: NSError!) -> Void in
                    if (self.textView != nil) {
                        self.updateUI()
                    }
                })
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var textView: UITextView!
    
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
        if (self.lyrics != nil) {
            self.textView.text = self.lyrics.text
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
