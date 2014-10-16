//
//  VMAudioListsSelectionViewController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 16.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class VMAudioListsSelectionViewController: UITableViewController {

    var audioToAdd: VMAudio?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Create new list
    
    func showCreateNewListDialog() {
        let alertController = UIAlertController(title: "Создать новый список",
            message: "Введите имя списка", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Создать", style: .Default) { (action: UIAlertAction!) -> Void in
            let textField = alertController.textFields![0] as UITextField
            let audioList = VMAudioListManager.sharedInstance.addOfflineAudioList(textField.text)
            audioList.addAudio(self.audioToAdd!)
            VMAudioListManager.sharedInstance.saveOfflineAudioLists()
            self.dismissViewControllerAnimated(true, completion: {(_) in })
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (_) in }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) -> Void in
            textField.placeholder = "Имя списка"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification,
                object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (_) -> Void in
                okAction.enabled = textField.text != ""
            })
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VMAudioListManager.sharedInstance.offlineAudioLists.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row < VMAudioListManager.sharedInstance.offlineAudioLists.count) {
            let cell = tableView.dequeueReusableCellWithIdentifier("VMMenuAudioListCell", forIndexPath: indexPath) as VMMenuAudioListCell
            cell.audioList = VMAudioListManager.sharedInstance.offlineAudioLists[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("AddNewListCell", forIndexPath: indexPath) as UITableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row < VMAudioListManager.sharedInstance.offlineAudioLists.count) {
            let audioList = VMAudioListManager.sharedInstance.offlineAudioLists[indexPath.row]
            audioList.addAudio(self.audioToAdd!)
            VMAudioListManager.sharedInstance.saveOfflineAudioLists()
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.showCreateNewListDialog()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}