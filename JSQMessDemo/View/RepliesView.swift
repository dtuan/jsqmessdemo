//
//  RepliesView.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/02/15.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import Foundation
import UIKit

protocol RepliesViewDelegate : class {
    func repliesView(_ repliesView: RepliesView, didUpdateContentSize size: CGSize)
    func repliesView(_ repliesView: RepliesView, didSelectReply reply: String)
}

class RepliesView: UIView {
    
    public weak var delegate: RepliesViewDelegate?
    
    private var contentView: UICollectionView!
    
    var replies : [String]? {
        didSet {
            self.contentView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    deinit {
        self.contentView.dataSource = nil
        self.contentView.delegate = nil
    }
    
    private func commonInit() {
        print("### RepliesView::commonInit")
        createContentView()
        
//        self.backgroundColor = UIColor.darkGray
//        self.contentView.backgroundColor = UIColor.blue
    }
    
    private func createContentView() {
        let layout = ReplyInputCollectionViewLayout()
        self.contentView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.contentView.backgroundColor = UIColor.white
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.dataSource = self
        self.contentView.delegate = self
        
        self.contentView.register(ReplyInputCell.self, forCellWithReuseIdentifier: ReplyInputCell.reuseIdentifier)
        
        self.addSubview(self.contentView)
        
        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        
        self.contentView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == self.contentView {
            let size = (replies != nil) ? self.contentView.contentSize : CGSize.zero
            self.delegate?.repliesView(self, didUpdateContentSize: size)
        }
    }
}

extension RepliesView : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let replies = self.replies {
            return replies.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReplyInputCell.reuseIdentifier, for: indexPath) as! ReplyInputCell
        
        cell.contentLabel.text = self.replies![indexPath.row]
        cell.contentLabel.frame = cell.bounds
        
        return cell
    }
}

extension RepliesView : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)!
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut], animations: {
            cell.layoutIfNeeded()
            cell.contentView.backgroundColor = UIColor(red: 204.0/255, green: 1, blue: 204.0/255, alpha: 1)
        }) { (_) in
            cell.contentView.backgroundColor = UIColor.white
            self.delegate?.repliesView(self, didSelectReply: self.replies![indexPath.row])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let boundingRect = NSString(string: self.replies![indexPath.row]).boundingRect(with: CGSize(width: collectionView.bounds.width, height: 1000),
                                                                                       options: .usesLineFragmentOrigin,
                                                                                       attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17)],
                                                                                       context: nil)
        
        let size = CGSize(width: collectionView.bounds.width - 40, height: ceil(boundingRect.height) + 10)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.frame.width, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.frame.width, height: 10)
    }
}

private class ReplyInputCollectionViewLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != self.collectionView?.bounds.width
    }
}

//////////////////////////////////////////////////////////////////////////////
// MARK: ReplyInputCell

class ReplyInputCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ReplyInputCell"
    
    var contentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.configureLabel()
        self.contentView.backgroundColor = UIColor.white
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 6
        
        self.layer.cornerRadius = 6
        self.layer.borderColor = UIColor(red: (200.0/255), green: (200.0/255), blue: (200.0/255), alpha: 1).cgColor
        self.layer.borderWidth = 1
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.6
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
        let r = CGRect(x: self.frame.width - 20, y: (self.frame.height - 15)/2, width: 15, height: 15)
        let imageView = UIImageView(frame: r)
        imageView.image = UIImage(named:"arrow-indicator.png")
        
        self.contentView.addSubview(imageView)
    }
    
    private func configureLabel() {
        self.contentLabel = UILabel()
        self.contentLabel.textAlignment = NSTextAlignment.center
        self.contentView.addSubview(self.contentLabel)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layoutIfNeeded()
//        mImage.layer.cornerRadius = mImage.frame.height/2
//    }
}
