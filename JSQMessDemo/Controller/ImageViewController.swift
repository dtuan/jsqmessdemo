//
//  ImageViewController.swift
//  JSQMessDemo
//
//  Created by Do Tuan on 2017/03/13.
//  Copyright © 2017 Do Tuan. All rights reserved.
//

import UIKit
import AlamofireImage

let defaultSpotImageName = "picture.png"

class ImageViewController: CommonViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    let loadingIndicator = UIActivityIndicatorView()
    var defaultImage: UIImage!
    
    var imageUrl: URL!

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultImage = Image(named: defaultSpotImageName)
        loadImage()
    }

    func loadImage() {
        print("load image: \(imageUrl.absoluteString)")
        showLoading()
        imageView.af_setImage(withURL: imageUrl,
                              placeholderImage: nil,
                              filter: nil,
                              progress: nil,
                              progressQueue: DispatchQueue.main,
                              imageTransition: .noTransition, runImageTransitionIfCached: false) { response in
                                self.hideLoading()
                                if self.imageView.image == nil {
                                    self.imageView.image = self.defaultImage
                                    self.imageView.accessibilityLabel = defaultSpotImageName
                                    self.imageView.contentMode = .center
                                } else {
                                    self.imageView.accessibilityLabel = "\(self.imageUrl.lastPathComponent)"
                                }
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showLoading() {
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        view.addSubview(loadingIndicator)
        
        loadingIndicator.startAnimating()
    }
    
    private func hideLoading() {
        loadingIndicator.stopAnimating()
    }

}
