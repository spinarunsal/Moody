//
//  CollectionViewCell.swift
//  Moody
//
//  Created by Pinar Unsal on 2018-05-15.
//  Copyright © 2018 S Pinar Unsal. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellimage: UIImageView!    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    var firstTemperature : Int = 0
}
