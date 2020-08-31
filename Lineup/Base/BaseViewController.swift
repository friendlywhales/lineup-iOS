//
//  BaseViewController.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit
import Photos

class BaseViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUp()
    }

    func setUp() { }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
}
