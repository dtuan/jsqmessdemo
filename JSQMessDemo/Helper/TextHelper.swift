//
//  TextHelper.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/03/09.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import Foundation
import UIKit

struct TextSplitConfig {
    let maxW: CGFloat
    let padding: CGFloat
    var numItemPerSection: Int
    let font: UIFont!
    
    let height: CGFloat
    
    init(maxW: CGFloat, padding: CGFloat, numItemPerSection: Int, font: UIFont, height: CGFloat) {
        self.maxW = maxW
        self.padding = padding
        self.numItemPerSection = numItemPerSection
        self.font = font
        self.height = height
    }
}

class ReplyItem: CustomDebugStringConvertible {
    var text: String
    var size: CGSize
    
    init(text: String, size: CGSize) {
        self.text = text
        self.size = size
    }
    
    var debugDescription: String {
        return "[ReplyItem] \(text), size: \(size)"
    }
}

class ReplyItemGroup: CustomDebugStringConvertible {
    var items = [ReplyItem]()
    
    var debugDescription: String {
        var debugStr = "[ReplyItemGroup]"
        for item in items {
            debugStr = "\(debugStr)\n--- --- ---\(item.debugDescription)"
        }
        return debugStr
    }
}

class ReplySection: CustomDebugStringConvertible {
    var itemGroups = [ReplyItemGroup]()
    
    var debugDescription: String {
        var debugStr = "[ReplySection]"
        for group in itemGroups {
            debugStr = "\(debugStr)\n--- ---\(group.debugDescription)"
        }
        return debugStr
    }
}

func split(texts:[String]?, config: TextSplitConfig) -> [ReplySection]? {
    
    guard let texts = texts else {
        return nil
    }
    
    var result = [ReplySection]()
    
    var crtSection = ReplySection()
    result.append(crtSection)
    
    var crtGroup = ReplyItemGroup()
    crtSection.itemGroups.append(crtGroup)
    
    let additionalW = config.padding * 2
    var remainW = config.maxW
    var index = 0
    while index < texts.count {
        let text = texts[index]
        
        // Calculate width of text
        let rect = NSString(string: text).boundingRect(with: CGSize(width: 1000, height: config.height),
                                                       options: .usesFontLeading,
                                                       attributes: [NSFontAttributeName: config.font],
                                                       context: nil)
        let w = rect.width + additionalW
        if w > remainW {
            // Create new group
            crtGroup = ReplyItemGroup()
            if crtSection.itemGroups.count >= config.numItemPerSection {
                crtSection = ReplySection()
                result.append(crtSection)
            }
            crtSection.itemGroups.append(crtGroup)
            // Reset maxW
            remainW = config.maxW
        }
        let item = ReplyItem(text: text, size: CGSize(width: w, height: rect.height))
        crtGroup.items.append(item)
        
        remainW = remainW - item.size.width
            
        index += 1
        
    }
    return result
}

