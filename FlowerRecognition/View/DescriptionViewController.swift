//
//  MenuViewController.swift
//  FlowerRecognition
//
//  Created by Kamil Chmiel on 09.03.2018.
//  Copyright © 2018 Kamil Chmiel. All rights reserved.
//

import UIKit
import SDWebImage

class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var imageURL: String = ""
    var name: String = ""
    var desc: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.sd_setImage(with: URL(string: imageURL))
        titleLabel.text = name
        descriptionLabel.text = desc
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
}
