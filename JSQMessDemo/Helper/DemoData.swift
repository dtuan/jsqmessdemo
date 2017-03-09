//
//  DemoData.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/02/15.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import Foundation
import CoreLocation
import JSQMessagesViewController
import Moya
import SwiftSoup

let kRebotSenderDisplayName = "Rebot"
let kRebotSenderId = "111"

let kUserSenderDisplayName = "User"
let KUserSenderId = "222"

protocol DemoDataDelegate : class {
    func data(_ data: DemoData, didReceiveMessages messages:[JSQMessage], replies: [String]?)
    func data(_ data: DemoData, didUpdateMediaMessage message: JSQMessage)
}

class DemoData {
    
    var avatars: [String: JSQMessagesAvatarImage]!
    var users: [String: String]!
    
    public weak var delegate: DemoDataDelegate?
    
    private lazy var uuid : String! = {
        let text = (UIDevice.current.identifierForVendor?.uuidString)!
        print("### UUID: \(text)")
        return text
    }()
    
    private let provider = Networking.newDefaultNetworking()
    
    private var messages = [JSQMessage]()

    init() {
        let botImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"character_01.png"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))!
        self.avatars = [kRebotSenderId: botImage]
        self.users = [kRebotSenderId : kRebotSenderDisplayName,
            KUserSenderId : kUserSenderDisplayName]
    }
    
    public var count : Int {
        get { return messages.count }
    }
    
    public subscript(index: Int) -> JSQMessage {
        return messages[index]
    }
    
    public func addMessage(_ message: JSQMessage) {
        messages.append(message)
    }
    
    public func addMessage(withId id: String, name: String, text: String) -> JSQMessage? {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            self.addMessage(message)
            return message
        }
        return nil
    }
    
    public func addAndSendMessage(_ message: JSQMessage) {
        self.addMessage(message)
        self.sendMessage(message)
    }
    
    public func removeMessage(at index: Int) {
        self.messages.remove(at: index)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////
    // Connect server
    public func sendMessage(_ message: JSQMessage) {
        let text = message.text!
        print(">>> sendMessage: \(text)")
        let endpoint = KurashikiApi.chat(appid: APP_ID, content: text, userid:uuid)
        _ = self.provider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().subscribe { event in
            var responseContent = [Array<Element>]()
            switch event {
            case let .next(response):
                var responseReplies: [String]?
                
                
                if let resd = response as? Dictionary<String, Any> {
                   print("===================== response\n\(resd)")
                   if let texts = resd["response"] as? [String] {
                        for text in texts {
                            let eles = try! self.processHtmlContent(html: text)
                            if let eles = eles {
                                responseContent.append(eles)
                            }
                        }
                    }
                    
                    if let resReply = resd["reply"] as? [String], resReply.count > 0 {
                        responseReplies = resReply
                    }
                }
                self.notifiyResponseReceived(responseContent, replies: responseReplies)
            case let .error(error):
                print("ERROR: \(type(of:error))  ### \(error)")
                let msg = self.getErrorMessage(fromError: error as! Moya.Error)
                let eles = try! self.processHtmlContent(html: msg!)
                if let eles = eles {
                    responseContent.append(eles)
                }
                
                self.notifiyResponseReceived(responseContent, replies: nil)
            default:
                break
            }
        }
    }
    
    private func getErrorMessage(fromError error: Moya.Error!) -> String! {
        if Networking.isInternetAvailable() {
            var code = -1
            if let res = error.response {
                code = res.statusCode
            }
            return "Oops something went wrong. Please wait a while and do it again! (\(code))"
        } else {
            return "We need internet connection to communicate!"
        }
    }
    
    func processHtmlContent(html: String) throws -> Array<Element>?{
        let doc: Document = try! SwiftSoup.parse(html)
        guard let body = doc.body() else {
            return nil
        }
        
        // Wrap text in "text" tag and remove empty text node
        var emptyNodes =  Array<TextNode>()
        
        let textNodes = body.textNodes()
        for text in textNodes {
            let str = text.text().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if str.characters.count > 0 {
                try! text.wrap("<text></text>")
            }
            else {
                emptyNodes.append(text)
            }
        }
        
        for emptyNode in emptyNodes {
            try! body.removeChild(emptyNode)
        }
        
        // Group tag together
        let children = body.children().array()
        var groupEle: Element?
        for child in children {
            let tagName = child.tagName()
            // Group "img" tag together
            if tagName == "img" {
                if groupEle != nil && groupEle?.tagName() != "imgs" {
                    groupEle = nil
                }
                
                if groupEle == nil {
                    groupEle = try! child.wrap("<imgs></imgs>").parent()
                }
                else {
                    try! groupEle!.addChildren(child)
                }
            }
            else {
                if groupEle != nil && groupEle?.tagName() == "imgs" {
                    groupEle = nil
                }
                
                // Group "a", "text", "map" tag together
                if tagName != "video" { // a, text, map
                    if groupEle == nil {
                        groupEle = try! child.wrap("<gtext></gtext>").parent()
                    }
                    else {
                        try! groupEle!.addChildren(child)
                    }
                }
                else if groupEle != nil {
                    groupEle = nil
                }
            }
        }
        
        return body.children().array()
    }
    
    private func notifiyResponseReceived(_ elements: [Array<Element>], replies: [String]?) {
        var jsqMsgs = [JSQMessage]()
        
        for group in elements {
            for ele in group {
                switch ele.tagName() {
                case "gtext": // This contain "a", "text", "map"
                    let children = ele.children().array()
                    for child in children {
                        let tagName = child.tagName()
                        switch tagName {
                        case "text":
                            let message = JSQMessage(senderId: kRebotSenderId, senderDisplayName: kRebotSenderDisplayName, date: Date.distantPast, text: try! child.text())
                            jsqMsgs.append(message!)
                            
                        case "a":
                            let href = try! child.attr("href")
                            let message = JSQMessage(senderId: kRebotSenderId, senderDisplayName: kRebotSenderDisplayName, date: Date.distantPast, text: href)
                            jsqMsgs.append(message!)
                            
                        case "map":
                            //let text = try! child.text()
                            let lat = CLLocationDegrees(try! child.attr("lat"))
                            let lon = CLLocationDegrees(try! child.attr("lon"))
                            let loc = CLLocation(latitude: lat!, longitude: lon!)
                            let item = JSQLocationMediaItem()
                            item.appliesMediaViewMaskAsOutgoing = false
                            
                            let message = JSQMessage(senderId: kRebotSenderId, senderDisplayName: kRebotSenderDisplayName, date: Date.distantPast, media: item)
                            item.setLocation(loc, withCompletionHandler: { 
                                self.delegate?.data(self, didUpdateMediaMessage: message!)
                            })
                            jsqMsgs.append(message!)
                            
                        default:
                            break
                        }
                    }
                case "imgs":
                    for node in ele.children().array() {
                        let linkHref: String = try! node.attr("src")
                        //init(withURL url: URL, imageSize: CGSize, isOperator: Bool)
                        if let url = URL(string:linkHref) {
                            let item = AsyncPhotoMediaItem(withURL: url, imageSize: CGSize.zero, isOperator: true)
                            let message = JSQMessage(senderId: kRebotSenderId, senderDisplayName: kRebotSenderDisplayName, date: Date.distantPast, media: item)
                            jsqMsgs.append(message!)
                        }
                    }
                    break
                    
                case "video":
                    let linkHref: String = try! ele.attr("src")
                    if let url = URL(string: linkHref),
                       let thumbnail = getImageThumbnailUrl(linkHref) {
                        let item = AsyncVideoMediaItem(withURL: url, thumbnailURL: thumbnail, isOperator: true)
                        let message = JSQMessage(senderId: kRebotSenderId, senderDisplayName: kRebotSenderDisplayName, date: Date.distantPast, media: item)
                        jsqMsgs.append(message!)
                    }
                    break
                    
                default:
                    break
                }
            }
            
        }
        
        messages.append(contentsOf: jsqMsgs)
        
        if let delegate = self.delegate {
            delegate.data(self, didReceiveMessages: jsqMsgs, replies: replies)
        }
    }
    
    private func getImageThumbnailUrl(_ url: String) -> URL? {
        // Examples: "https://youtu.be/CD8bfVaGfEM"
        if let range = url.range(of: "https://youtu.be/") {
            let videoid = url.substring(from: range.upperBound)
            return URL(string: "https://img.youtube.com/vi/\(videoid)/hqdefault.jpg")
        }
        return nil
    }
}
