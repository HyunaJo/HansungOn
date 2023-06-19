//
//  SearchTextField.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/14.
//

import UIKit

class SearchTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override func layoutSubviews() {
            super.layoutSubviews()

            for view in subviews {
                if let button = view as? UIButton {
                    button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                    button.tintColor = UIColor(displayP3Red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
                }
            }
        }

}
