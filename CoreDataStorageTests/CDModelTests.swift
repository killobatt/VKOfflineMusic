//
//  VMModelTests.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 20.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import XCTest

class CDModelTests: XCTestCase {
    
    var model: CDModel!

    override func setUp() {
        super.setUp()
        let storagePath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL
        let storageURL = storagePath?.URLByAppendingPathComponent("store.sqlite")
        XCTAssertNotNil(storagePath, "")
        self.model = CDModel(storageURL: storageURL!)
        // Put setup code here. This method is called before the invocation of each test method in the class.
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

}
