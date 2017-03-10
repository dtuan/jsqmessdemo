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
    
    var maxHeight: CGFloat = 0 {
        didSet {
            // Update config number of item per page
            splitConfig.numItemPerSection = Int((maxHeight - 20 - 10 - 10) / 45)
            sectionHeight = CGFloat((splitConfig.numItemPerSection * 45) + 20)
            print("numItemPerSection: \(splitConfig.numItemPerSection)")
        }
    }
    
    public weak var delegate: RepliesViewDelegate?
    
    fileprivate var contentView: UICollectionView!
    fileprivate var contentViewBottomConstraint: NSLayoutConstraint!
    fileprivate var pageControl: UIPageControl!
    
    fileprivate var itemSections: [ReplySection]?
    fileprivate var splitConfig: TextSplitConfig!
    fileprivate var hasPageControl = true
    
    fileprivate var sectionHeight: CGFloat = 0
    
    var replies : [String]? {
        didSet {
            itemSections = split(texts: replies, config: splitConfig)
            pageControl.numberOfPages = itemSections?.count ?? 0
            pageControl.currentPage = 0
            
            hasPageControl = false
            var maxItem = 0
            if let sections = itemSections {
                for s in sections {
                    maxItem = max(s.itemGroups.count, maxItem)
                }
                hasPageControl = (sections.count > 1)
            }
            sectionHeight = CGFloat(maxItem * 45)
            sectionHeight = hasPageControl ? sectionHeight + 20 : sectionHeight
            
            pageControl.isHidden = !hasPageControl
            contentViewBottomConstraint.constant = hasPageControl ? -20 : 0

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
        backgroundColor = UIColor.white
        createContentView()
        createPageControl()
        
        splitConfig = TextSplitConfig(maxW: self.frame.width - 20, padding: 20, numItemPerSection: 4, font: UIFont.systemFont(ofSize: 17), height: 40)
        
//        self.backgroundColor = UIColor.darkGray
//        self.contentView.backgroundColor = UIColor.blue
    }
    
    private func createContentView() {
        let layout = ReplyInputCollectionViewLayout()
        layout.scrollDirection = .horizontal
        
        contentView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.isPagingEnabled = true
        contentView.dataSource = self
        contentView.delegate = self
        
        contentView.register(ReplySectionCell.self, forCellWithReuseIdentifier: ReplySectionCell.reuseIdentifier)
        
        addSubview(contentView)
        
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        contentViewBottomConstraint = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -20)
        addConstraint(contentViewBottomConstraint)
        
        contentView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
    }
    
    private func createPageControl() {
        pageControl = UIPageControl(frame: CGRect.zero)
        addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.backgroundColor = UIColor.clear
        
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.groupTableViewBackground
        pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        
        pageControl.addTarget(self, action: #selector(RepliesView.pageControlValueChanged(sender:)), for: .valueChanged)
        
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
    }
    
    @objc private func pageControlValueChanged(sender: UIPageControl) {
        contentView.scrollToItem(at: IndexPath(item: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let observedObject = object as? UICollectionView, observedObject == self.contentView {
            let h = (replies != nil) ? CGFloat(sectionHeight + 20) : 0
            let size = CGSize(width: contentView.frame.width, height: h)
            self.delegate?.repliesView(self, didUpdateContentSize: size)
        }
    }
}

extension RepliesView : UICollectionViewDataSource, ReplySectionCellDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (itemSections != nil) ? itemSections!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReplySectionCell.reuseIdentifier, for: indexPath) as! ReplySectionCell
        
        let section = self.itemSections![indexPath.row]
        cell.configure(section)
        cell.cellDelegate = self
        return cell
    }
    
    func cell(_ cell: ReplySectionCell, didSelectReply reply: String, sender: UIButton) {
        delegate?.repliesView(self, didSelectReply: reply)
    }
}

extension RepliesView : UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(ceil(contentView.contentOffset.x / contentView.bounds.size.width))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.width = size.width - 20
        size.height = hasPageControl ? sectionHeight - 20 : sectionHeight
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

private class ReplyInputCollectionViewLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.width != self.collectionView?.bounds.width
    }
}

//////////////////////////////////////////////////////////////////////////////
// MARK: ReplyInputCell
// Each cell include a tableview

protocol ReplySectionCellDelegate: class {
    func cell(_ cell: ReplySectionCell, didSelectReply reply: String, sender: UIButton)
}

class ReplySectionCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, ReplyItemCellDelegate {
    
    static let reuseIdentifier = "ReplyInputCell"
    
    weak var cellDelegate: ReplySectionCellDelegate?
    var contentTableView: UITableView!
    
    var replies: ReplySection!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        
        clipsToBounds = true
        
        contentTableView = UITableView(frame: CGRect.zero)
        contentTableView.separatorStyle = .none
        contentTableView.bounces = false
        contentTableView.dataSource = self
        contentTableView.delegate = self
        contentTableView.register(ReplyItemCell.self, forCellReuseIdentifier: ReplyItemCell.reuseIdentifier)
        addSubview(contentTableView)
        
        contentTableView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: contentTableView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: contentTableView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: contentTableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: contentTableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
    }
    
    func configure(_ section: ReplySection) {
        //self.contentView.backgroundColor = UIColor.randomColor()
        self.replies = section
        contentTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.itemGroups.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReplyItemCell.reuseIdentifier, for: indexPath) as! ReplyItemCell
        
        cell.configure(replies.itemGroups[indexPath.row])
        cell.cellDelegate = self
        
        return cell
    }
    
    func cell(_ cell: ReplyItemCell, didSelectReply reply: String, sender: UIButton) {
        cellDelegate?.cell(self, didSelectReply: reply, sender: sender)
    }
}

//////////////////////////////////////////////////////////////////////////////
// MARK: ReplyItemCell
// Include multiple reply item
protocol ReplyItemCellDelegate: class {
    func cell(_ cell: ReplyItemCell, didSelectReply reply: String, sender: UIButton)
}

class ReplyItemCell: UITableViewCell {
    static let reuseIdentifier = "ReplyItemCell"
    
    static let normalBackgroundColor = UIColor(red: 243/255.0, green: 243/255.0, blue: 243/255.0, alpha: 1)
    static let highlightedBackgroundColor = UIColor(red: 204/255.0, green: 1, blue: 204/255.0, alpha: 1)
    
    weak var cellDelegate: ReplyItemCellDelegate?
    
    var cellTableView: UITableView!
    
    var itemGroup: ReplyItemGroup!
    private var childButtons = [UIButton]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        selectionStyle = .none
    }
    
    func configure(_ itemGroup: ReplyItemGroup) {
        self.itemGroup = itemGroup
        
        for btn in childButtons {
            btn.removeFromSuperview()
        }
        childButtons.removeAll()
        
        // Create button for each items
        var x: CGFloat = 0
        let count = CGFloat(itemGroup.items.count)
        let padding: CGFloat = 10
        let h = bounds.height - 5
        let w = bounds.width - (count - 1) * padding
        
        // Adjust size for button
        let sumw = itemGroup.items.reduce(0.0) { $0 + $1.size.width }
        let remainw = w - sumw
        
        for item in itemGroup.items {
            let additionw = remainw / count
            item.size.width = item.size.width + additionw
        }
        
        for item in itemGroup.items {
            let button = UIButton(frame: CGRect(x: x, y: 0, width: item.size.width, height: h))
            self.addSubview(button)
            button.addTarget(self, action: #selector(ReplyItemCell.itemTouchUpInside(sender:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(ReplyItemCell.itemTouchDown(sender:)), for: .touchDown)
            button.addTarget(self, action: #selector(ReplyItemCell.itemTouchUpOutside(sender:)), for: .touchUpOutside)
            
            button.layer.cornerRadius = 7.0
            
            button.backgroundColor = ReplyItemCell.normalBackgroundColor
            
            button.setTitle(item.text, for: .normal)
            button.setTitleColor(UIColor.black, for: .normal)
            
            childButtons.append(button)
            
            x = x + item.size.width + padding
        }
    }
    
    @objc private func itemTouchUpInside(sender: UIButton) {
        sender.backgroundColor = ReplyItemCell.normalBackgroundColor
        
        let text = sender.titleLabel?.text
        cellDelegate?.cell(self, didSelectReply: text!, sender: sender)
    }
    
    @objc private func itemTouchDown(sender: UIButton) {
        sender.backgroundColor = ReplyItemCell.highlightedBackgroundColor
    }
    
    @objc private func itemTouchUpOutside(sender: UIButton) {
        sender.backgroundColor = ReplyItemCell.normalBackgroundColor
    }
}
