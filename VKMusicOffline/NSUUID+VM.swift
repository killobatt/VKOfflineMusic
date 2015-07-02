//
//  NSUUID+VM.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 01.07.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation

extension NSUUID {
    class var vm_syncAudioListUUID: NSUUID {
        return NSUUID(UUIDString: "00000000-0000-0000-0000-000000000000")!
    }
}
