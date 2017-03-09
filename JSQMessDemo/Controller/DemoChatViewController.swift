//
//  ViewController.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/02/10.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController
import Moya

protocol DemoChatViewControllerDelegate: class {
    func chatController(_ controller: DemoChatViewController, didReceiveReplies replies: [String]?)
}

class DemoChatViewController: JSQMessagesViewController, UIActionSheetDelegate {

    weak var chatDelegate: DemoChatViewControllerDelegate?
    
    let messageData = DemoData()
    
    // Override from parent
    var toolbarBottomLayoutGuide: NSLayoutConstraint!
    
    var outgoingBubbleImageData: JSQMessagesBubbleImage!
    var incomingBubbleImageData: JSQMessagesBubbleImage!
    
    fileprivate var storeReplies: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        messageData.delegate = self
        
        // User info
        self.senderId = KUserSenderId
        self.senderDisplayName = kUserSenderDisplayName
        
        // No user avatar
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        // Message bubble setting
        let factory = JSQMessagesBubbleImageFactory()
        self.outgoingBubbleImageData = factory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
        self.incomingBubbleImageData = factory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleGreen())
        
        // Remove accessory button
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        self.inputToolbar.contentView.textView.text = "動画" //"返品したい" //"画像" //"支払い方法について"
        self.inputToolbar.toggleSendButtonEnabled()
        
        NotificationCenter.default.addObserver(self, selector: #selector(DemoChatViewController.keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // Override super private method
    func jsq_setToolbarBottomLayoutGuideConstant(constant: CGFloat) {
        toolbarBottomLayoutGuide.constant = constant
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
        self.jsq_updateCollectionViewInsets()
    }
    
    
    func jsq_updateCollectionViewInsets() {
        self.jsq_setCollectionViewInsetsTopValue(top: self.topLayoutGuide.length + self.topContentAdditionalInset, bottomValue: self.collectionView.frame.maxY - self.inputToolbar.frame.minY)
    }
    
    func jsq_setCollectionViewInsetsTopValue(top: CGFloat, bottomValue bottom: CGFloat) {
        let insets = UIEdgeInsetsMake(top, 0, bottom, 0)
        self.collectionView.contentInset = insets
        self.collectionView.scrollIndicatorInsets = insets
        
    }
    // END of override
    
    func didSelectReply(text: String) {
        if let message = JSQMessage(senderId: KUserSenderId, senderDisplayName: kUserSenderDisplayName, date: Date.distantPast, text: text) {
            self.messageData.addAndSendMessage(message)
            self.finishSendingMessage(animated: true)
        }
    }
    
    // MARK: - Messages view controller overridden
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text) {
            // Forward event to clear replies
            chatDelegate?.chatController(self, didReceiveReplies: nil)
            
            self.messageData.addAndSendMessage(message)
            self.finishSendingMessage(animated: true)
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    // MARK: - JSQMessagesCollectionViewDataSource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.messageData[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didDeleteMessageAt indexPath: IndexPath!) {
        self.messageData.removeMessage(at: indexPath.item)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messageData[indexPath.item]
        if message.senderId == self.senderId {
            return self.outgoingBubbleImageData
        }
        return self.incomingBubbleImageData
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messageData[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        return self.messageData.avatars[message.senderId]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: self.messageData[indexPath.item].date)
        }
        
        return nil;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if self.messageData[indexPath.item].senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            if self.messageData[indexPath.item - 1].senderId == self.messageData[indexPath.item].senderId {
                return nil
            }
        }
        
        return NSAttributedString(string: self.messageData[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    // MARK: - UICollectionView Datasource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageData.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(self.collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let msg = self.messageData[indexPath.item]
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
}

extension DemoChatViewController : DemoDataDelegate {
    
    @objc func keyboardDidHide(notification: NSNotification) {
        // Forward event
        chatDelegate?.chatController(self, didReceiveReplies: storeReplies)
    }
    
    func data(_ data: DemoData, didReceiveMessages messages: [JSQMessage], replies: [String]?) {
        self.storeReplies = replies
        
        if replies != nil {
            self.inputToolbar.contentView.textView.resignFirstResponder()
            // Wait keyboard hide to start show replies
            if !keyboardController.keyboardIsVisible {
                chatDelegate?.chatController(self, didReceiveReplies: storeReplies)
            }
        }
        else {
            self.finishReceivingMessage(animated: true)
        }
    }
    
    func data(_ data: DemoData, didUpdateMediaMessage message: JSQMessage) {
        self.collectionView.reloadData()
    }
}



