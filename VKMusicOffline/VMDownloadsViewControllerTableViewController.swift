//
//  VMDownloadsViewControllerTableViewController.swift
//  VKMusicOffline
//
//  Created by Guest on 26/11/14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class VMDownloadsViewController: UITableViewController, VMAudioDownloadManagerProgressDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Downloads"
        
        self.downloadManager.progressDelegate = self
        self.downloadManager.getAudioDownloadTaskList { (downloadTasks:[AnyObject]) -> Void in
            var tasks = Array<NSURLSessionDownloadTask>()
            for task in downloadTasks {
                if let downloadTask = task as? NSURLSessionDownloadTask {
                    tasks.append(downloadTask)
                }
            }
            self.downloadTasks = tasks
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - model
    
    var downloadTasks: Array<NSURLSessionDownloadTask> = []
    
    // MARK: - Dependancies
    
    var audioListManager: VMAudioListManager {
        return VMAudioListManager.sharedInstance
    }
    
    var downloadManager: VMAudioDownloadManager {
        return self.audioListManager.downloadManager
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloadTasks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("downloadCell", forIndexPath: indexPath) as! VMDownloadCell
        
        let downloadTask = self.downloadTasks[indexPath.row]
        if let
            audioID = self.downloadManager.audioIDForTask(downloadTask),
            audio = self.audioListManager.model.audioWithID(audioID) {
                cell.audio = audio
                cell.downloadTask = downloadTask
        }
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return NSLocalizedString("cancel", tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.downloadTasks[indexPath.row].cancel()
            self.downloadTasks.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    //  Mark: - VMAudioDownloadManagerProgressDelegate
    
    func downloadManager(downloadManager: VMAudioDownloadManager, loadedBytes bytesLoaded: Int64, fromTotalBytes totalBytes: Int64, forAudioWithID audioID: NSNumber, andTask task:NSURLSessionDownloadTask) {
        if let index = find(self.downloadTasks, task) {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation:.None)
        }
    }
    
    func downloadManager(downloadManager: VMAudioDownloadManager, didLoadAudioWithID audioID: NSNumber, andTask task: NSURLSessionDownloadTask) {
        if let index = find(self.downloadTasks, task) {
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation:.None)
        }
    }

}
