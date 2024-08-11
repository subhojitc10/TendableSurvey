//
//  FormQACell.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 08/08/24.
//

import UIKit

protocol FormQATVCDelegate: AnyObject {
    
    func selectedAnswerID(id: Int, row: Int, section: Int)
}

class FormQATVC: UITableViewCell {
    
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var tableViewQuestionOptions: UITableView!
    
    static let reuseIdentifier = "FormQATVC"
    static func nib() -> UINib {
        return UINib(nibName: "FormQATVC", bundle: nil)
    }
    
    var questionData : QuestionModel?
    var answerOptions : [AnswerChoiceModel] = []
    weak var delegate : FormQATVCDelegate?
    var section : Int = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.tableViewQuestionOptions.delegate = self
        self.tableViewQuestionOptions.dataSource = self
        self.tableViewQuestionOptions.register(FormQAOptionsTVC.nib(), forCellReuseIdentifier: FormQAOptionsTVC.reuseIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(data : QuestionModel) {
        
        self.questionData = data
        self.lblQuestion.text = data.name
        self.answerOptions = data.answerChoices
        
        self.tableViewQuestionOptions.reloadData()
        
    }
    
}

//MARK: - UITableView Delegate
extension FormQATVC: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.answerOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewQuestionOptions.dequeueReusableCell(withIdentifier: "FormQAOptionsTVC", for: indexPath) as! FormQAOptionsTVC
        
        cell.setupUI(data: self.answerOptions[indexPath.row])
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedAnswerID(id: self.answerOptions[indexPath.row].id, row: self.tag, section: self.section)
        self.answerOptions.map{$0.isSelected = false}
        self.answerOptions[indexPath.row].isSelected = true
        self.tableViewQuestionOptions.reloadData()
        
    }
    
}
