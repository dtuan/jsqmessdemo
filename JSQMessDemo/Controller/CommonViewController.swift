//
//  CommonViewController.swift
//  kurashiki
//
//  Created by Tuan Do on 12/20/16.
//  Copyright © 2016 Resola. All rights reserved.
//

import UIKit

protocol CommonControllerDelegate : class {
    func viewController(didClose viewController: UIViewController)
}

class CommonViewController: UIViewController {

    weak var delegate: CommonControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func close() {
        self.dismiss(animated: true) { [weak self] in
            if let mydelegate = self?.delegate, let myself = self {
                mydelegate.viewController(didClose: myself)
            }
        }
    }
}
