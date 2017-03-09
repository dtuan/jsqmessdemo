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

class AsyncVideoMediaItem: JSQVideoMediaItem {
    var asyncImageView: UIImageView!
    
    override init!(maskAsOutgoing: Bool) {
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    init(withURL url: URL, thumbnailURL thumbnailUrl: URL, isOperator: Bool) {
        super.init()
        appliesMediaViewMaskAsOutgoing = (isOperator == false)
        
        let size = super.mediaViewDisplaySize()
    
        let addPlayIcon =  {
            let playIcon = UIImage.jsq_defaultPlay().jsq_imageMasked(with: UIColor.white)
            let imageView = UIImageView(image: playIcon)
            imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            imageView.contentMode = UIViewContentMode.center
            imageView.clipsToBounds = true
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.asyncImageView.addSubview(imageView)
        }
        
        asyncImageView = UIImageView()
        asyncImageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        asyncImageView.contentMode = .scaleAspectFill
        asyncImageView.clipsToBounds = true
        asyncImageView.layer.cornerRadius = 20
        asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
        
        let activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
        activityIndicator?.frame = asyncImageView.frame
        asyncImageView.addSubview(activityIndicator!)
        
        
        KingfisherManager.shared.cache.retrieveImage(forKey: thumbnailUrl.absoluteString, options: nil) { (image, cacheType) -> () in
            
            if let image = image {
                self.asyncImageView.image = image
                activityIndicator?.removeFromSuperview()
                addPlayIcon()
            } else {
                KingfisherManager.shared.downloader.downloadImage(with: thumbnailUrl , progressBlock: nil) { (image, error, imageURL, originalData) -> () in
                    
                    if let image = image {
                        self.asyncImageView.image = image
                        activityIndicator?.removeFromSuperview()
                        addPlayIcon()
                        KingfisherManager.shared.cache.store(image, forKey: thumbnailUrl.absoluteString)
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
