//
//  VMSplitViewController.swift
//  VKMusicOffline
//
//  Created by Guest on 18/01/15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class VMSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Events
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        let player = VMAudioListPlayer.sharedInstance
        if player.audioList == nil {
            // TODO: tracks are not loaded here; we need a allways existing offline track list?
            player.setAudioList(VMAudioListManager.sharedInstance.userAudioList, currentTrackIndex: 0)
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
            case .RemoteControlTogglePlayPause:     // received from headphones controlls
                if (player.isPlaying) {
                    player.pause()
                } else {
                    player.play()
                }
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
