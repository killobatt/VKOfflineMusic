//
//  VMModelTests.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 20.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import XCTest
import CoreData
import CoreDataStorage

class CDModelTests: XCTestCase {
    
    var model: CDModel!

    override func setUp() {
        super.setUp()
        let storagePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL
        let storageFileName = NSUUID().UUIDString.stringByAppendingPathExtension("sqlite")
        let storageURL = storagePath?.URLByAppendingPathComponent(storageFileName!)
        XCTAssertNotNil(storagePath, "")
        self.model = CDModel(storageURL: storageURL!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testModelURLisNotNil() {
        // given 
        
        // when
        let modelURL = self.model.modelFileURL
        
        // then
        XCTAssertNotNil(modelURL, "Model URL should not be nil")
    }

    func testThatModelIsInitializedCorrectly() {
        // given
        
        // when 
        
        // then
        XCTAssertNotNil(self.model.persistentStoreCoordinator, "persistentStoreCoordinator should not be nil")
        XCTAssertNotNil(self.model.model, "managed object model should not be nil")
        XCTAssertNotNil(self.model.mainContext, "mainContext should not be nil")
    }

    func testAudioListAdding() {
        // given 
        self.model.addAudioList(title: "Metallica")
        
        // when
        let audioLists = self.model.audioLists
        let audioList = audioLists.filter({$0.title == "Metallica"}).first! as CDAudioList
        
        // then
        XCTAssertNotNil(audioList, "audio list should be created")
        XCTAssertNotNil(audioList.title, "audio list title should be created")
        XCTAssertEqual(audioList.title!, "Metallica", "Title should be correct")
    }
    
    func testAudioListRemoving() {
        // given 
        let audioList = self.model.addAudioList(title: "Metallica")
        
        // when 
        self.model.deleteObject(audioList)
        
        // then
        let fetchRequest = NSFetchRequest(entityName: CDAudioList.entityName())
        var error: NSError? = nil
        let results = self.model.mainContext.executeFetchRequest(fetchRequest, error: &error) as! [CDAudioList]
        XCTAssertNil(error, "")
        let index = find(results.map{$0.title!}, "Metallica")
        XCTAssertNil(index)
    }
    
    func testAudioAdding() {
        // given
        let audio = CDAudio(managedObjectContext: self.model.mainContext)
        audio.title = "Nothing else matters"
        
        // when
        let allAudios = self.model.allAudios
        let fetchedAudio = allAudios.filter({$0.title == "Nothing else matters"}).first! as CDAudio
        
        // then
        XCTAssertNotNil(fetchedAudio);
        XCTAssertNotNil(fetchedAudio.title);
        XCTAssertEqual(fetchedAudio.title!, "Nothing else matters");
    }
    
    func testAudioRemoving() {
        // given
        let audio = CDAudio(managedObjectContext: self.model.mainContext)
        audio.title = "Nothing else matters"
        
        // when
        self.model.deleteObject(audio)
        
        // then
        let allAudios = self.model.allAudios
        let fetchedAudio = allAudios.filter({$0.title == "Nothing else matters"}).first as CDAudio?
        XCTAssertNil(fetchedAudio)
    }
    
    func testUniqueAudiosFromList() {
        // given
        let audioList1 = self.model.addAudioList(title: "Metallica")
        
        let audio1 = CDAudio(managedObjectContext: self.model.mainContext)
        audio1.title = "Nothing else matters"
        audioList1.addAudiosObject(audio1)
        
        let audio2 = CDAudio(managedObjectContext: self.model.mainContext)
        audio2.title = "Phantom of the opera"
        audioList1.addAudiosObject(audio2)
        
        let audioList2 = self.model.addAudioList(title: "Nightwish")
        
        let audio3 = CDAudio(managedObjectContext: self.model.mainContext)
        audio3.title = "Wishmaster"
        audioList2.addAudiosObject(audio3)
        
        audioList2.addAudiosObject(audio2)
        
        
        // when 
        let audios = self.model.uniqueAudiosFromAudioList(audioList1)
        
        // then 
        XCTAssertEqual(audios.count, 1, "")
        XCTAssertNotNil(audios.first?.title, "")
        XCTAssertEqual(audios.first!.title!, "Nothing else matters", "")
    }
    
    func testAudioListRemovingWithAudios() {
        // given
        let audioList1 = self.model.addAudioList(title: "Metallica")
        
        let audio1 = CDAudio(managedObjectContext: self.model.mainContext)
        audio1.title = "Nothing else matters"
        audioList1.addAudiosObject(audio1)
        
        let audio2 = CDAudio(managedObjectContext: self.model.mainContext)
        audio2.title = "Phantom of the opera"
        audioList1.addAudiosObject(audio2)
        
        let audioList2 = self.model.addAudioList(title: "Nightwish")
        
        let audio3 = CDAudio(managedObjectContext: self.model.mainContext)
        audio3.title = "Wishmaster"
        audioList2.addAudiosObject(audio3)
        
        audioList2.addAudiosObject(audio2)
        
        // when
        self.model.deleteObject(audioList1)
        
        // then
        let allAudios = self.model.allAudios
        var fetchedAudio = allAudios.filter({$0.title == "Nothing else matters"}).first as CDAudio?
        XCTAssertNil(fetchedAudio)
        
        // then
        fetchedAudio = allAudios.filter({$0.title == "Phantom of the opera"}).first as CDAudio?
        XCTAssertNotNil(fetchedAudio)
    }
    
    func testGetAudioByID() {
        // given
        let audio = CDAudio(managedObjectContext: self.model.mainContext)
        audio.title = "Nothing else matters"
        audio.id = 100500
        
        // when
        let fetchedAudio = self.model.audioWithID(100500)
        
        // then
        XCTAssertNotNil(fetchedAudio)
        XCTAssertNotNil(fetchedAudio?.id)
        XCTAssertNotNil(fetchedAudio?.title)
        XCTAssertEqual(fetchedAudio!.id!, 100500)
        XCTAssertEqual(fetchedAudio!.title!, "Nothing else matters")
    }
}
