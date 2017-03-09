//
//  ContainerViewController.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/02/16.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var lcReplyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var repliesView: RepliesView!
    
    fileprivate var chatVC: DemoChatViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    // test
    @IBAction func changeConstraintTapped(_ sender: Any) {
        lcReplyViewHeight.constant = lcReplyViewHeight.constant < 50 ? 260 : 40
    }
    
    func initView() {
        lcReplyViewHeight.constant = 0
        repliesView.delegate = self
    }
}

extension MainViewController: RepliesViewDelegate {
    
    func repliesView(_ repliesView: RepliesView, didSelectReply reply: String) {
        chatVC.didSelectReply(text: reply)
        repliesView.replies = nil
    }
    
    func repliesView(_ repliesView: RepliesView, didUpdateContentSize size: CGSize) {
        lcReplyViewHeight.constant = size.height
        chatVC.view.layoutIfNeeded()
    }
}

extension MainViewController : DemoChatViewControllerDelegate {
    func chatController(_ controller: DemoChatViewController, didReceiveReplies replies: [String]) {
        // This will cause replies collection view reload data
        repliesView.replies = replies
    }
}
