//
//  ContainerViewController.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/02/16.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MainViewController: UIViewController {

    @IBOutlet weak var lcReplyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var repliesView: RepliesView!
    
    fileprivate var chatVC: DemoChatViewController!
    fileprivate var isKeyboardVisible: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.keyboardWillChangeFrame(notification:)), name: NSNotification.Name(rawValue: JSQMessagesKeyboardControllerNotificationKeyboardDidChangeFrame), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "chatController" {
            self.chatVC = segue.destination as! DemoChatViewController
            self.chatVC.chatDelegate = self
        }
    }
    
    private func initView() {
        repliesView.delegate = self
        repliesView.isHidden = true
        isKeyboardVisible = false
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        if isKeyboardVisible == chatVC.keyboardController.keyboardIsVisible {
            return
        }
        
        isKeyboardVisible = chatVC.keyboardController.keyboardIsVisible
        
        repliesView.isHidden = isKeyboardVisible
        if !repliesView.isHidden && lcReplyViewHeight.constant != 0 {
            chatVC.jsq_setToolbarBottomLayoutGuideConstant(constant: lcReplyViewHeight.constant)
        }
    }
}

extension MainViewController: RepliesViewDelegate {
    
    func repliesView(_ repliesView: RepliesView, didSelectReply reply: String) {
        chatVC.didSelectReply(text: reply)
        repliesView.replies = nil
    }
    
    func repliesView(_ repliesView: RepliesView, didUpdateContentSize size: CGSize) {
        lcReplyViewHeight.constant = size.height
        repliesView.isHidden = (size.height == 0)
        if !isKeyboardVisible {
            chatVC.jsq_setToolbarBottomLayoutGuideConstant(constant: lcReplyViewHeight.constant)
            chatVC.finishReceivingMessage()
        }
    }
}

extension MainViewController : DemoChatViewControllerDelegate {
    func chatController(_ controller: DemoChatViewController, didReceiveReplies replies: [String]?) {
        // This will cause replies collection view reload data
        repliesView.replies = replies
    }
}
