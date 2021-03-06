//
//  AsyncPhotoMediaItem.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/03/08.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import Kingfisher

class AsyncPhotoMediaItem: JSQPhotoMediaItem {
    var asyncImageView: UIImageView!
    var imageURL: URL!
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    init(withURL url: URL, imageSize: CGSize, isOperator: Bool) {
        super.init()
        imageURL = url
        
        appliesMediaViewMaskAsOutgoing = (isOperator == false)
        
        var size = imageSize
        if size == CGSize.zero {
            size = super.mediaViewDisplaySize()
        }
        
        asyncImageView = UIImageView()
        asyncImageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        asyncImageView.contentMode = .scaleAspectFit
        asyncImageView.clipsToBounds = true
        asyncImageView.layer.cornerRadius = 20
        asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        
        let activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
        activityIndicator?.frame = asyncImageView.frame
        asyncImageView.addSubview(activityIndicator!)
        
        
        KingfisherManager.shared.cache.retrieveImage(forKey: url.absoluteString, options: nil) { (image, cacheType) -> () in
            
            if let image = image {
                self.asyncImageView.image = image
                activityIndicator?.removeFromSuperview()
            } else {
                KingfisherManager.shared.downloader.downloadImage(with: url , progressBlock: nil) { (image, error, imageURL, originalData) -> () in
                    
                    if let image = image,
                        let imageURL = imageURL {
                        self.asyncImageView.image = image
                        activityIndicator?.removeFromSuperview()
                        KingfisherManager.shared.cache.store(image, forKey: imageURL.absoluteString)
                    }
                }
            }
        }
    }
    
    override func mediaView() -> UIView! {
        return asyncImageView
    }
    
    override func mediaViewDisplaySize() -> CGSize {
        return asyncImageView.frame.size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
