//
//  SurveyFormVC.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 08/08/24.
//

import UIKit

class SurveyFormVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var lblInspectionAreaVal: UILabel!
    @IBOutlet weak var lblInspectionTypeVal: UILabel!
    @IBOutlet weak var tableViewSurveyForm: UITableView!
    @IBOutlet weak var constraintTableBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var btnDraft: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    //MARK: - Properties
    private var surveyFormVM: SurveyFormVMProtocol?
    private var surveyFormData : SurveyFormModel?
    
    internal var isInitial: Bool? = true
    internal var isDraftedForm: Bool? = true
    internal var existingFormModel : SurveyFormModel?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.surveyFormVM = SurveyFormVM()
        self.surveyFormVM?.responseDelegate = self
        
        self.setupUI()
        
        if self.isInitial ?? false {
            self.surveyFormVM?.getSurveyFormAPI()
        } else {
            if let existingData = existingFormModel {
                self.surveyFormVM?.getExistingFormData(data: existingData)
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isInitial ?? false {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isInitial ?? false {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    fileprivate func setupUI() {
        
        if self.isInitial ?? false {
            //Hidden
        } else {
            self.navigationItem.title = "Draft Form"
        }
        
        //Activity Indicator
        self.indicatorView.isHidden = true
        
        //TableView
        self.tableViewSurveyForm.delegate = self
        self.tableViewSurveyForm.dataSource = self
        self.tableViewSurveyForm.register(FormQATVC.nib(), forCellReuseIdentifier: FormQATVC.reuseIdentifier)
        self.tableViewSurveyForm.rowHeight = UITableView.automaticDimension
        self.tableViewSurveyForm.estimatedRowHeight = 120.0
        
        //Submit Button
        self.btnSubmit.layer.cornerRadius = 8
        self.btnSubmit.layer.masksToBounds = true
        
        //Save Button
        self.btnSave.layer.cornerRadius = 8
        self.btnSave.layer.masksToBounds = true
        
        //Draft Button
        self.btnDraft.layer.cornerRadius = 8
        self.btnDraft.layer.masksToBounds = true
        
        //Refresh Button
        self.btnRefresh.layer.cornerRadius = 8
        self.btnRefresh.layer.masksToBounds = true
        
        if self.isInitial ?? false {
            self.btnSave.isHidden = false
            self.btnSubmit.isHidden = false
            self.btnDraft.isHidden = false
            self.btnRefresh.isHidden = false
            self.constraintTableBottomSpace.constant = 120
        } else {
            if self.isDraftedForm ?? false {
                self.btnSave.isHidden = false
                self.btnSubmit.isHidden = false
                self.btnDraft.isHidden = true
                self.btnRefresh.isHidden = true
                self.constraintTableBottomSpace.constant = 120
            } else {
                self.btnSave.isHidden = true
                self.btnSubmit.isHidden = true
                self.btnDraft.isHidden = true
                self.btnRefresh.isHidden = true
                self.constraintTableBottomSpace.constant = 0
            }
        }
        
    }
    
    fileprivate func validateForm(formData: SurveyFormModel, isSubmit: Bool) -> Bool {
        
        var ansCount = 0
        var quesCount = 0
        
        let categories = formData.inspection.survey.categories
        for category in categories {
            let questions = category.questions
            quesCount += questions.count
            for question in questions {
                let options = question.answerChoices
                for option in options {
                    if option.id == question.selectedAnswerChoiceID {
                        ansCount += 1
                    }
                }
            }
        }
        
        if isSubmit {
            if quesCount == ansCount {
                return true
            } else {
                return false
            }
        } else {
            if ansCount > 0  {
                return true
            } else {
                return false
            }
        }
    }
    
    
}

//MARK: - Button Actions
extension SurveyFormVC {
    
    @IBAction func btnRefreshTouch(_ sender: Any) {
        self.surveyFormVM?.getSurveyFormAPI()
    }
    
    @IBAction func btnDraftsTouch(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let savedListVC = storyboard.instantiateViewController(withIdentifier: "SavedListVC") as? SavedListVC {
            self.navigationController?.pushViewController(savedListVC, animated: true)
        }
    }
    
    @IBAction func btnSaveTouch(_ sender: Any) {
        
        if let data = self.surveyFormVM?.surveyData, self.validateForm(formData: data, isSubmit: false) {
            self.surveyFormVM?.saveSurveyFormData(formData: data, isDraft: true)
        } else {
            self.showAlert(title: "Warning", message: "Please select at least one answer to save the form as draft")
        }
        
    }
    
    @IBAction func btnSubmiTouch(_ sender: Any) {
        
        if let data = self.surveyFormVM?.surveyData, self.validateForm(formData: data, isSubmit: true) {
            
            do {
                let jsonData = try JSONEncoder().encode(self.surveyFormVM?.surveyData)
                
                let parameters: [String: Any] = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
                self.surveyFormVM?.submitSurveyFormAPI(params: parameters)
                
                if let data = self.surveyFormVM?.surveyData {
                    self.surveyFormVM?.saveSurveyFormData(formData: data, isDraft: false)
                }
                
            } catch {
                print("Error serializing model to JSON: \(error)")
            }
        } else {
            self.showAlert(title: "Warning", message: "Please fill in the form completely before submission")
        }
        
    }
    
    @IBAction func btnLogoutTouch(_ sender: Any) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginRegisterVC = storyboard.instantiateViewController(withIdentifier: "LoginRegistrationVC") as! LoginRegistrationVC
        
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = loginRegisterVC
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
        } else {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = loginRegisterVC
                UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
        }
        
    }
    
}

//MARK: - SurveyFormVMResponse Delegate
extension SurveyFormVC : SurveyFormVMResponseDelegate {
    
    
    func submissionSuccessAlert(message: String?) {
        
        self.showAlert(title: "Successfull", message: message ?? "")
        
        if self.isInitial ?? false {
            //To get fresh form
            self.surveyFormVM?.getSurveyFormAPI()
        } else {
            self.btnSave.isHidden = true
            self.btnSubmit.isHidden = true
            self.constraintTableBottomSpace.constant = 0
        }
    }
    
    func loadSurveyForm(data: SurveyFormModel) {
        
        self.surveyFormData = data
        self.lblInspectionAreaVal.text = self.surveyFormVM?.surveyData?.inspection.area.name
        self.lblInspectionTypeVal.text = self.surveyFormVM?.surveyData?.inspection.inspectionType.name
        
        
        self.tableViewSurveyForm.reloadData()
    }
    
    func formSaveSuccess(message: String?) {
        self.showAlert(title: "Successfull", message: message ?? "")
    }
    
    func startIndicator() {
        
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
        
    }
    
    func stopIndicator() {
        
        self.indicatorView.stopAnimating()
        self.indicatorView.isHidden = true
        
    }
    
    func showErrorAlert(message: String?) {
        self.showAlert(title: "Warning", message: message ?? "")
    }
    
    
}


//MARK: - TableView Delegate
extension SurveyFormVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.surveyFormVM?.numberOfCategories ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView()
        sectionHeaderView.backgroundColor = UIColor(hex: "#99DBDF")
        
        let labelSectionHeader = UILabel()
        labelSectionHeader.translatesAutoresizingMaskIntoConstraints = false
        labelSectionHeader.text = self.surveyFormVM?.categories(index: section).name
        labelSectionHeader.textColor = UIColor(hex: "#181b35")
        labelSectionHeader.font = UIFont.boldSystemFont(ofSize: 16)
        
        sectionHeaderView.addSubview(labelSectionHeader)
        
        NSLayoutConstraint.activate([
            labelSectionHeader.leadingAnchor.constraint(equalTo: sectionHeaderView.leadingAnchor, constant: 16),
            labelSectionHeader.centerYAnchor.constraint(equalTo: sectionHeaderView.centerYAnchor)
        ])
        
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.surveyFormVM?.categories(index: section).questions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewSurveyForm.dequeueReusableCell(withIdentifier: "FormQATVC", for: indexPath) as! FormQATVC
        
        if let question = self.surveyFormVM?.categories(index: indexPath.section).questions[indexPath.row] {
            cell.setupUI(data: question)
        }
        cell.selectionStyle = .none
        cell.delegate = self
        cell.tag = indexPath.row
        cell.section = indexPath.section
        return cell
        
    }
    
}

//MARK: - FormQATVC Delegate
extension SurveyFormVC : FormQATVCDelegate {
    func selectedAnswerID(id: Int, row: Int, section: Int) {
        
        self.surveyFormVM?.surveyData?.inspection.survey.categories[section].questions[row].selectedAnswerChoiceID = id
        self.tableViewSurveyForm.reloadData()
        
    }
}
