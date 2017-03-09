//
//  Message.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/03/06.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import Foundation

enum MessageType: Int {
    case Text
    case Image
    case Link
    case Map
    case Video
}

struct Message {
    var type: MessageType
    var content: String
}
