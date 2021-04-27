//
//  TableViewCell.swift
//  fetch
//
//  Created by Amen Parham on 4/21/21.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet var mainImage: UIImageView!
    @IBOutlet var titleTxt: UILabel!
    @IBOutlet var locationTxt: UILabel!
    @IBOutlet var moreBtn: UIButton!
    @IBOutlet var likeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
