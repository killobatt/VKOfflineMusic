//
//  DetailViewController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VKSdkFramework
import MGSwipeTableCell

class VMAudioListViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate, VMAudioListDelegate
{
    
    @IBOutlet weak var playingNowButtonItem: UIBarButtonItem!
    
    var audioList: VMAudioList! = nil {
        didSet {
            audioList.delegate = self
            self.title = self.audioList.title as String?
            if (self.searchResultsController != nil) {
                self.searchResultsController.audioList = self.audioList
            }
        }
    }
    var searchController: UISearchController!
    var searchResultsController: VMAudioListViewController!
    var player: VMAudioListPlayer {
        return VMAudioListPlayer.sharedInstance
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit {
        VMAudioListPlayer.sharedInstance.removeObserver(self, forKeyPath: "currentTrackIndex")
    }
    
    func initialize() {
        VMAudioListPlayer.sharedInstance.addObserver(self, forKeyPath: "currentTrackIndex", options: [.New], context: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
        if let parentViewController = self.parentViewController {
            if parentViewController is UINavigationController {
                self.searchResultsController = self.storyboard?.instantiateViewControllerWithIdentifier("VMAudioListViewController") as! VMAudioListViewController
                if self.audioList != nil {
                    self.searchResultsController.audioList = self.audioList.searchResultsList
                }
                self.searchController = UISearchController(searchResultsController: self.searchResultsController)
                self.searchController.searchResultsUpdater = self.searchResultsController
                self.searchController.delegate = self
                
                self.definesPresentationContext = true
                
                self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
                self.tableView.tableHeaderView = self.searchController.searchBar;
                
                self.playingNowButtonItem.enabled = self.player.currentTrack != nil
            }
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "pullToRefresh:", forControlEvents: .ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        if let searchTerm = (self.audioList as? VMAudioListSearching)?.searchTerm {
            if let searchController = self.searchController {
                searchController.searchBar.text = searchTerm
            }
        }
        
        if (self.player.audioList != nil &&
            self.player.audioList == self.audioList &&
            self.player.currentTrack != nil) {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.player.currentTrackIndex, inSection: 0), atScrollPosition: .Middle, animated: false)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func playingNowPressed(sender: AnyObject) {
        if (VMAudioListPlayer.sharedInstance.currentTrack == nil) {
            return
        }
        
        switch (UIDevice.currentDevice().userInterfaceIdiom) {
        case .Pad:
            self.performSegueWithIdentifier("playingNowPopover", sender: sender)
        default:
            self.performSegueWithIdentifier("playingNowPush", sender: sender)
        }
    }
    
    @IBAction func pullToRefresh(sender: AnyObject) {
        self.audioList.reload()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.audioList != nil) ? 1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let audio = self.audioList[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VMAudioCell", forIndexPath: indexPath) as! VMAudioCell
        cell.audio = audio
        cell.rightButtons = []
        
        if self.audioList is VMOfflineAudioList {
            let button = MGSwipeButton(title: "", icon: UIImage(named: "Delete"),
                backgroundColor: UIColor.redColor())
            button.callback = {(sender: MGSwipeTableCell!) -> Bool in
                self.audioList.deleteTrackAtIndex(indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                tableView.endUpdates()
                return true
            }
            cell.rightButtons.append(button)
        } else {
            let button = MGSwipeButton(title: "", icon: UIImage(named: "Download"),
                backgroundColor: UIColor.orangeColor())
            button.callback = {(sender: MGSwipeTableCell!) -> Bool in
                self.performSegueWithIdentifier("showOfflineListSelection", sender: sender)
                return true
            }
            cell.rightButtons.append(button)
        }
        
        if (audio.lyrics != nil) {
            let button = MGSwipeButton(title: "", icon: UIImage(named: "Lyrics"),
                backgroundColor: UIColor.greenColor())
            button.callback = {(sender: MGSwipeTableCell!) -> Bool in
                self.performSegueWithIdentifier("showLyrics", sender: cell)
                return true
            }
            cell.rightButtons.append(button)
        }
        
        return cell
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
        let player = VMAudioListPlayer.sharedInstance
        if (player.audioList !== self.audioList) {
            player.setAudioList(self.audioList, currentTrackIndex: indexPath.row)
            player.play()
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            return
        }
        
        if (player.currentTrackIndex == indexPath.row) {
            if (player.isPlaying) {
                player.pause()
            } else {
                player.play()
            }
        } else {
            player.currentTrackIndex = indexPath.row
            player.play()
        }
        self.tableView.reloadData()
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
            let controller = segue.destinationViewController as! VMLyricsController
            let audioCell = sender as! VMAudioCell
            controller.lyrics = audioCell.audio?.lyrics
        } else if (segue.identifier == "showOfflineListSelection") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! VMAudioListsSelectionViewController
            let audioCell = sender as! VMAudioCell
            controller.audioToAdd = audioCell.audio
        }
    }
    
    @IBAction func unwindFromSegue(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - UISearchControllerDelegate
    
    func willPresentSearchController(searchController: UISearchController) {
        
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        if let searchTerm = (self.audioList as? VMAudioListSearching)?.searchTerm {
            if let searchController = self.searchController {
                searchController.searchBar.text = searchTerm
            }
        }
    }
    
    func didDismissSearchController(searchController: UISearchController) {
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if (searchController.searchBar.text == "") {
            self.tableView.reloadData()
            return
        }
        if let audioListSearching = self.audioList as? VMAudioListSearching {
            if let oldSearchTerm = audioListSearching.searchTerm {
                if searchController.searchBar.text == oldSearchTerm {
                    self.tableView.reloadData()
                    return
                }
            }
            audioListSearching.setSearchTerm(searchController.searchBar.text, completion: {(error: NSError!) -> Void in
                self.tableView.reloadData()
            })
            self.tableView.reloadData()
        }
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if (object as! NSObject == VMAudioListPlayer.sharedInstance) {
                if (keyPath == "currentTrackIndex") {
                    self.tableView.reloadData()
                    self.playingNowButtonItem.enabled = self.player.currentTrack != nil
                }
            }
    }
    
    // MARK: - VMAudioListDelegate
    
    func audioListWasReloaded(audioList: VMAudioList) {
        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
    
    func audioListWillChange(audioList: VMAudioList) {
        self.refreshControl?.endRefreshing()
        self.tableView.beginUpdates()
    }
    
    func autioList(audioList: VMAudioList, didChangeWithInfo changeInfo: VMAudioListChangeInfo) {
        let insertedIndexPaths: [NSIndexPath] = changeInfo.insertedAudios.keys.map { NSIndexPath(forRow: $0, inSection: 0) }
        self.tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: UITableViewRowAnimation.Top)
        
        let removedIndexPaths: [NSIndexPath] = changeInfo.removedAudios.keys.map { NSIndexPath(forRow: $0, inSection: 0) }
        self.tableView.deleteRowsAtIndexPaths(removedIndexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
        
        for move in changeInfo.movedAudios {
            self.tableView.moveRowAtIndexPath(NSIndexPath(forRow: move.from, inSection: 0),
                toIndexPath: NSIndexPath(forRow: move.to, inSection: 0))
        }
        
        self.tableView.endUpdates()
    }
}
