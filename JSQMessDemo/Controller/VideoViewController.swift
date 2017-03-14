//
//  VideoViewController.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/03/13.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import UIKit

class VideoViewController: CommonViewController, UIWebViewDelegate {
    
    @IBOutlet weak var myWebView: UIWebView!
    var url: String!
    
    let loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myWebView.scrollView.bounces = false
        myWebView.mediaPlaybackRequiresUserAction = false
        
        // Do any additional setup after loading the view.
        loadUrl()
    }
    
    private func loadUrl() {
        
        if url.range(of: "?") == nil {
            url.append("?autoplay=1")
        }
        
        if let url = URL(string: url) {
            showLoading()
            let request = URLRequest(url: url)
            myWebView.loadRequest(request)
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //print("*** shouldLoad: \(request.url?.absoluteString)")
        if request.url?.absoluteString == "about:blank" {
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideLoading()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("*** ERROR: \(error.localizedDescription)")
        hideLoading()
    }
    
    private func showLoading() {
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(loadingIndicator)
        
        loadingIndicator.startAnimating()
    }
    
    private func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    @IBAction func closeDidTap(sender: Any) {
        close()
    }
}
