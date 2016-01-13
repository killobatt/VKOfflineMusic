//
//  CDLog.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 13.01.16.
//  Copyright © 2016 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import Crashlytics

func CDLog(format: String, _ args: CVarArgType...) {
    withVaList(args) { CLSLogv(format, $0) }
}

func CDLogError(error: NSError) {
    Crashlytics.sharedInstance().recordError(error)
}


