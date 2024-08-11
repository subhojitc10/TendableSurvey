//
//  FormQAOptionsCell.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 08/08/24.
//

import UIKit

class FormQAOptionsTVC: UITableViewCell {
    
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var imgViewRadio: UIImageView!
    @IBOutlet weak var lblAnswer: UILabel!
    
    static let reuseIdentifier = "FormQAOptionsTVC"
    static func nib() -> UINib {
        return UINib(nibName: "FormQAOptionsTVC", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewBg.layer.cornerRadius = 10.0
        self.viewBg.layer.masksToBounds = true
        self.viewBg.layer.borderWidth = 0.5
        self.viewBg.layer.borderColor = UIColor(hex: "#181b35")?.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(data : AnswerChoiceModel) {
        
        self.lblAnswer.text = data.name
        self.imgViewRadio.image = data.isSelected ?? false ? UIImage(systemName: "circle.fill") : UIImage(systemName: "circle")
    }
    
}
