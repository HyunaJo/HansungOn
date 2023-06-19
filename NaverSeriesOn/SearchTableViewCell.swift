//
//  SearchTableViewCell.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/13.
//

import UIKit


class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
