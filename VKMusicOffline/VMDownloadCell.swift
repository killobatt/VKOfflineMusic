//
//  VMDownloadCell.swift
//  VKMusicOffline
//
//  Created by Guest on 20/12/14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import UIViews

class VMDownloadCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var audioArtistLabel: UILabel!
    @IBOutlet weak var audioTitleLabel: UILabel!
    @IBOutlet weak var downloadRelativeProgressLabel: UILabel!
    @IBOutlet weak var downloadSizeLabel: UILabel!
    @IBOutlet weak var suspendResumeButton: UIButton!
    @IBOutlet weak var progressView: CircleProgressView!
    
    // MARK: - Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    deinit {
        self.downloadTask.removeObserver(self, forKeyPath: "countOfBytesReceived")
        self.downloadTask.removeObserver(self, forKeyPath: "countOfBytesExpectedToReceive")
    }
    
    // MARK: - 
    
    var downloadTask: NSURLSessionTask! {
        didSet {
            if let task = self.downloadTask {
                self.audioArtistLabel.text = task.taskDescription
                self.audioTitleLabel.text = ""
                
                self.updateDownloadSizeTo(task.countOfBytesExpectedToReceive)
                self.updateProgressTo(task.countOfBytesReceived, animated:false)

                self.suspendResumeButton.selected = task.state != .Running
                
                task.addObserver(self, forKeyPath: "countOfBytesReceived", options: [], context: nil)
                task.addObserver(self, forKeyPath: "countOfBytesExpectedToReceive", options: [], context: nil)
            }
        }
    }
    
    private func updateDownloadSizeTo(countOfBytesExpectedToReceive:Int64) {
        if (countOfBytesExpectedToReceive > 0) {
            let sizeInMegabytes = Float(countOfBytesExpectedToReceive) / (1024 * 1024)
            self.downloadSizeLabel.text = NSString(format: "%.1f Mb", sizeInMegabytes) as String
        } else {
            self.downloadSizeLabel.text = ""
        }
    }
    
    private func updateProgressTo(countOfBytesReceived:Int64, animated:Bool) {
        let downloadSize = self.downloadTask.countOfBytesExpectedToReceive;
        let progress = (downloadSize == 0) ? 0 : Float(countOfBytesReceived) / Float(self.downloadTask.countOfBytesExpectedToReceive)
        self.downloadRelativeProgressLabel.text = NSString(format:"%.1f%%", progress * 100) as String
        self.progressView.setProgress(progress, animated: animated)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (keyPath == "countOfBytesReceived") {
                self.updateProgressTo(self.downloadTask.countOfBytesReceived, animated:true)
            } else if (keyPath == "countOfBytesExpectedToReceive") {
                self.updateDownloadSizeTo(self.downloadTask.countOfBytesExpectedToReceive)
            }
        })
    }
    
    @IBAction func toggleSuspendPressed(sender: AnyObject) {
        if (self.downloadTask.state == NSURLSessionTaskState.Running) {
            self.downloadTask.suspend()
            self.suspendResumeButton.selected = true
        } else {
            self.downloadTask.resume()
            self.suspendResumeButton.selected = false
        }
    }
}
