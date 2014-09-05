//
//  emojiSnappin.swift
//  Kiosk
//
//  Created by Orta on 9/5/14.
//  Copyright (c) 2014 Artsy. All rights reserved.
//

import Nimble

func 📷(snapshottable:Snapshotable) {
    expect(snapshottable).to( recordSnapshot() )
}
