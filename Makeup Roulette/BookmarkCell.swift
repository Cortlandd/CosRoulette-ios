//
//  BookmarkCell.swift
//  Makeup Roulette
//
//  Created by Cortland Walker on 5/20/19.
//  Copyright © 2019 Fedha. All rights reserved.
//

import UIKit

class BookmarkCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var _bookmarkVideoThumbnail: UIImageView!
    @IBOutlet weak var _bookmarkVideoTitle: UILabel!
    @IBOutlet weak var _bookmarkVideoChannelTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        _bookmarkVideoTitle.adjustsFontForContentSizeCategory = true
        _bookmarkVideoChannelTitle.adjustsFontForContentSizeCategory = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
