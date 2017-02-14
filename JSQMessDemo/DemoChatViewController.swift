//
//  ViewController.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/02/10.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Moya

let kRebotSenderDisplayName = "Rebot"
let kRebotSenderId = "111"

let kUserSenderDisplayName = "User"
let KUserSenderId = "222"

class DemoChatViewController: JSQMessagesViewController, UIActionSheetDelegate {

    var messages = NSMutableArray()
    var outgoingBubbleImageData: JSQMessagesBubbleImage!
    var incomingBubbleImageData: JSQMessagesBubbleImage!
    
    private lazy var uuid : String! = {
        let text = (UIDevice.current.identifierForVendor?.uuidString)!
        print("### UUID: \(text)")
        return text
    }()
    
    let provider = Networking.newDefaultNetworking()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.senderId = KUserSenderId
        self.senderDisplayName = kUserSenderDisplayName
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        let factory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImageData = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.incomingBubbleImageData = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        self.inputToolbar.contentView.textView.text = "支払い方法について" // "画像" //"支払い方法について"
        self.inputToolbar.toggleSendButtonEnabled()
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Messages view controller overridden
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)!
        self.messages.add(message)
        self.finishSendingMessage(animated: true)
        
        self.sendMessage(message)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.inputToolbar.contentView.textView .resignFirstResponder()
        let sheet = UIActionSheet(title: "Media messages", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Send photo", "Send location", "Send video", "Send video thumbnail")
        sheet.show(from: self.inputToolbar)
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    // MARK: - JSQMessagesCollectionViewDataSource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messages.object(at: indexPath.item) as! JSQMessage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messages.removeObject(at: indexPath.item)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages.object(at: indexPath.item) as! JSQMessage
        if message.senderId == self.senderId {
            return self.outgoingBubbleImageData
        }
        return self.incomingBubbleImageData
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = self.messages.object(at: indexPath.item) as! JSQMessage
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = self.messages.object(at: indexPath.item) as! JSQMessage
        
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let prevMessage = self.messages.object(at: indexPath.item - 1) as! JSQMessage
            if prevMessage.senderId == message.senderId {
                return nil
            }
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    // MARK: - UICollectionView Datasource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(self.collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg = self.messages.object(at: indexPath.item) as! JSQMessage
        if !msg.isMediaMessage {
            if msg.senderId == self.senderId {
                cell.textView.textColor = UIColor.black
            } else {
                cell.textView.textColor = UIColor.white
            }
            
            cell.textView.linkTextAttributes = [NSForegroundColorAttributeName : cell.textView.textColor!]
            
        }
        return cell
    }
    
    func shouldShowAccessoryButtonForMessage(message: JSQMessage) -> Bool {
        return message.isMediaMessage && true //UserDefaults.accessor
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////
    // Methods
    public func sendMessage(_ message: JSQMessage) {
        let text = message.text!
        print(">>> sendMessage: \(text)")
        let endpoint = KurashikiApi.chat(appid: APP_ID, content: text, userid:uuid)
        _ = self.provider.request(endpoint).filterSuccessfulStatusCodes().mapJSON().subscribe { event in
            switch event {
            case let .next(response):
                var responseTexts: [String]?
                var responseReplies: [String]?
                if let resd = response as? Dictionary<String, Any> {
                    if let texts = resd["response"] as? [String] {
                        print("================= response text")
                        for text in texts {
                            print(">\(text)")
                        }
                        
                        responseTexts = texts
                    }
                    
                    if let resReply = resd["reply"] as? [String], resReply.count > 0 {
                        print("================= response reply")
                        for res in resReply {
                            print(">\(res)")
                        }
                        responseReplies = resReply
                    }
                }
                //self.updateMessage(message, status: .success)
                self.notifiyMessageReceived(responseTexts, replies: responseReplies)
            case let .error(error):
                print("ERROR: \(type(of:error))  ### \(error)")
                //self.updateMessage(message, status: .failed)
                
                let msg = self.getErrorMessage(fromError: error as! Moya.Error)
                self.notifiyMessageReceived([msg!], replies: nil)
            default:
                break
            }
        }
    }
    
    private func getErrorMessage(fromError error: Moya.Error!) -> String! {
        //let code = (error as Moya.Error).code
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
    
    private func notifiyMessageReceived(_ messages: [String]?, replies: [String]?) {
        if let messages = messages {
            for msg in messages {
                self.addMessage(withId: kRebotSenderId, name: kRebotSenderDisplayName, text: msg)
                self.finishReceivingMessage(animated: true)
            }
        }
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            self.messages.add(message)
        }
    }
}

