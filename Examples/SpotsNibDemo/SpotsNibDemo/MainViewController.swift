//
//  MainViewController.swift
//  SpotsNibDemo
//
//  Created by Aashish Dhawan on 12/12/16.
//  Copyright © 2016 Hyper. All rights reserved.
//

import Foundation
import UIKit
import Spots

open class MainViewController: Controller {

    convenience init(title: String, spots: [Spotable]) {
        self.init(spots: spots)
        self.title = title
    }
}
