//
//  SavedItemTVC.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 10/08/24.
//

import UIKit

class SavedItemTVC: UITableViewCell {

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var labelEpoch: UILabel!
    
    static let reuseIdentifier = "SavedItemTVC"
    static func nib() -> UINib {
        return UINib(nibName: "SavedItemTVC", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.viewBG.layer.cornerRadius = 5
        self.viewBG.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupUI(data: String) {
        self.labelEpoch.text = "Form : \(data)"
    }
    
}
