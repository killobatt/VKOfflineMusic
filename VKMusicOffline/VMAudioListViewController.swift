//
//  DetailViewController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK
import MGSwipeCells

class VMAudioListViewController: UITableViewController, UISearchResultsUpdating, MGSwipeTableCellDelegate
{
    var audioList: VMAudioList! = nil {
        didSet {
            self.title = self.audioList.title
            if (self.searchResultsController != nil) {
                self.searchResultsController.audioList = self.audioList
            }
        }
    }
    var searchController: UISearchController!
    var searchResultsController: VMAudioListViewController!
    
    override init() {
        super.init()
        initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    deinit {
        VMAudioListPlayer.sharedInstance.removeObserver(self, forKeyPath: "currentTrackIndex")
    }
    
    func initialize() {
        VMAudioListPlayer.sharedInstance.addObserver(self, forKeyPath: "currentTrackIndex", options: nil, context: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
        if let parentViewController = self.parentViewController {
            if parentViewController is UINavigationController {
                self.searchResultsController = self.storyboard?.instantiateViewControllerWithIdentifier("VMAudioListViewController") as VMAudioListViewController
                if self.audioList != nil {
                    self.searchResultsController.audioList = self.audioList.searchResultsList
                }
                self.searchController = UISearchController(searchResultsController: self.searchResultsController)
                self.searchController.searchResultsUpdater = self.searchResultsController
                
                self.definesPresentationContext = true
                
                self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
                self.tableView.tableHeaderView = self.searchController.searchBar;
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.contentOffset = CGPointMake(0, 44)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.audioList != nil) ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (self.searchResultsController == nil) {
//            return self.audioList.filteredAudios.count
//        } else {
            return self.audioList.count
//        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: VMAudioCell
        if (VMAudioListPlayer.sharedInstance.audioList === self.audioList &&
            VMAudioListPlayer.sharedInstance.currentTrackIndex == indexPath.row) {
            cell = tableView.dequeueReusableCellWithIdentifier("VMAudioPlayingCell", forIndexPath: indexPath) as VMAudioPlayingCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("VMAudioCell", forIndexPath: indexPath) as VMAudioCell
        }
        cell.delegate = self
        
        let audio = self.audioList[indexPath.row]
        cell.audio = audio
        
        cell.rightButtons = [
            MGSwipeButton(title: "", icon: UIImage(named: "Delete"), backgroundColor: UIColor.redColor()),
            MGSwipeButton(title: "", icon: UIImage(named: "Download"), backgroundColor: UIColor.orangeColor()),
        ]
        
        if (audio.lyrics != nil) {
            cell.rightButtons.append(MGSwipeButton(title: "", icon: UIImage(named: "Lyrics"), backgroundColor: UIColor.greenColor()))
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (VMAudioListPlayer.sharedInstance.audioList === self.audioList &&
            VMAudioListPlayer.sharedInstance.currentTrackIndex == indexPath.row) {
            return 72;
        } else {
            return 52
        }

    }

    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == self.audioList.count - 1 &&
            self.audioList.hasNextPage()) {
            self.audioList.loadNextPage(completion: { (error: NSError!) -> Void in
                tableView.reloadData()
            })
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (VMAudioListPlayer.sharedInstance.audioList !== self.audioList) {
            VMAudioListPlayer.sharedInstance.audioList = self.audioList
        }
        if (VMAudioListPlayer.sharedInstance.currentTrackIndex == indexPath.row &&
            VMAudioListPlayer.sharedInstance.isPlaying) {
            VMAudioListPlayer.sharedInstance.pause()
        } else {
            VMAudioListPlayer.sharedInstance.currentTrackIndex = indexPath.row
            VMAudioListPlayer.sharedInstance.play()
            VMAudioControllsController.sharedInstance.display()
            self.tableView.reloadData()
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return self.audioList.editingEnabled()
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.audioList.deleteTrackAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return self.audioList.editingEnabled()
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        self.audioList.moveTrackFromIndex(fromIndexPath.row, toIndex:toIndexPath.row)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "showLyrics") {
            let controller = segue.destinationViewController as VMLyricsController
            let audioCell = sender as VMAudioCell
            controller.lyrics = audioCell.audio.lyrics
        } else if (segue.identifier == "showOfflineListSelection") {
            let navigationController = segue.destinationViewController as UINavigationController
            let controller = navigationController.topViewController as VMAudioListsSelectionViewController
            let audioCell = sender as VMAudioCell
            controller.audioToAdd = audioCell.audio
        }
    }
    
    @IBAction func unwindFromSegue(segue: UIStoryboardSegue) {
        
    }

    
    // MARK: - MGSwipeTableCellDelegate
    
    func swipeTableCell(cell: VMAudioCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        if let indexPath = tableView.indexPathForCell(cell) {
            if (index == 0) { // Delete
                self.audioList.deleteTrackAtIndex(indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.endUpdates()
            } else if (index == 1) { // Download
                self.performSegueWithIdentifier("showOfflineListSelection", sender: cell)
            } else if (index == 2) { // lyrics
                self.performSegueWithIdentifier("showLyrics", sender: cell)
            }
        }
        return true
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let audioListSearching = self.audioList as? VMAudioListSearching {
            audioListSearching.setSearchTerm(searchController.searchBar.text, completion: {(error: NSError!) -> Void in
                self.tableView.reloadData()
            })
            self.tableView.reloadData()
        }
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            if (object as NSObject == VMAudioListPlayer.sharedInstance) {
                if (keyPath == "currentTrackIndex") {
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - Events
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        let player = VMAudioListPlayer.sharedInstance
        if player.audioList == nil {
            player.audioList = VMAudioListManager.sharedInstance.userAudioList
        }
        if player.currentTrack == nil {
            player.currentTrackIndex = 0
        }
        
        if (event.type == UIEventType.RemoteControl) {
            switch event.subtype {
            case .RemoteControlPlay:
                player.play()
            case .RemoteControlPause:
                player.pause()
            case .RemoteControlPreviousTrack:
                player.playPreviousTrack()
            case .RemoteControlNextTrack:
                player.playNextTrack()
            default:
                NSLog("Got event unprocesed event: \(event)")
            }
        }
    }
}
