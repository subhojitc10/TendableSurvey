//
//  SavedListVC.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 10/08/24.
//

import UIKit

class SavedListVC: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var btnDraft: UIButton!
    @IBOutlet weak var btnCompleted: UIButton!
    @IBOutlet weak var labelNoData: UILabel!
    @IBOutlet weak var tableSavedFormList: UITableView!
    
    
    //MARK: - Properties
    private var savedListVM: SavedListVMProtocol?
    private var isDraft: Bool = true
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.savedListVM = SavedListVM()
        
        self.setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.savedListVM?.getSavedFormList()
        
        if self.isDraft {
            self.btnDraft.backgroundColor = UIColor(hex: "#181b35")
            self.btnDraft.titleLabel?.textColor = UIColor(hex: "#caefef")
            
            self.btnCompleted.backgroundColor = UIColor(hex: "#caefef")
            self.btnCompleted.titleLabel?.textColor = UIColor(hex: "#181b35")
            
            if self.savedListVM?.surveyDraftFormList.count == 0 {
                self.labelNoData.isHidden = false
                self.tableSavedFormList.isHidden = true
                self.labelNoData.text = "No draft data found"
            } else {
                self.labelNoData.isHidden = true
                self.tableSavedFormList.isHidden = false
            }
            
        } else {
            self.btnCompleted.backgroundColor = UIColor(hex: "#181b35")
            self.btnCompleted.titleLabel?.textColor = UIColor(hex: "#caefef")
            
            self.btnDraft.backgroundColor = UIColor(hex: "#caefef")
            self.btnDraft.titleLabel?.textColor = UIColor(hex: "#181b35")
            
            if self.savedListVM?.surveyCompletedFormList.count == 0 {
                self.labelNoData.isHidden = false
                self.tableSavedFormList.isHidden = true
                self.labelNoData.text = "No completed form data found"
            } else {
                self.labelNoData.isHidden = true
                self.tableSavedFormList.isHidden = false
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupUI() {
        
        self.navigationItem.title = "Saved Forms"
        
        //Submit Button
        self.btnDraft.layer.cornerRadius = 8
        self.btnDraft.layer.masksToBounds = true
        self.btnDraft.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        //Save Button
        self.btnCompleted.layer.cornerRadius = 8
        self.btnCompleted.layer.masksToBounds = true
        self.btnCompleted.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        //TableView
        self.tableSavedFormList.delegate = self
        self.tableSavedFormList.dataSource = self
        self.tableSavedFormList.register(SavedItemTVC.nib(), forCellReuseIdentifier: SavedItemTVC.reuseIdentifier)
        
    }

}

//MARK: - Button Actions
extension SavedListVC {
    
    @IBAction func btnDraftTouch(_ sender: Any) {
        self.isDraft = true
        self.btnDraft.backgroundColor = UIColor(hex: "#181b35")
        self.btnDraft.titleLabel?.textColor = UIColor(hex: "#caefef")
        
        self.btnCompleted.backgroundColor = UIColor(hex: "#caefef")
        self.btnCompleted.titleLabel?.textColor = UIColor(hex: "#181b35")
        
        
        if self.savedListVM?.surveyDraftFormList.count == 0 {
            self.labelNoData.isHidden = false
            self.tableSavedFormList.isHidden = true
            self.labelNoData.text = "No draft data found"
        } else {
            self.labelNoData.isHidden = true
            self.tableSavedFormList.isHidden = false
            self.tableSavedFormList.reloadData()
        }
        
    }
    
    @IBAction func btnCompletedTouch(_ sender: Any) {
        self.isDraft = false
        self.btnCompleted.backgroundColor = UIColor(hex: "#181b35")
        self.btnCompleted.titleLabel?.textColor = UIColor(hex: "#caefef")
        
        self.btnDraft.backgroundColor = UIColor(hex: "#caefef")
        self.btnDraft.titleLabel?.textColor = UIColor(hex: "#181b35")
        
        if self.savedListVM?.surveyCompletedFormList.count == 0 {
            self.labelNoData.isHidden = false
            self.tableSavedFormList.isHidden = true
            self.labelNoData.text = "No completed form data found"
        } else {
            self.labelNoData.isHidden = true
            self.tableSavedFormList.isHidden = false
            self.tableSavedFormList.reloadData()
        }
        
    }
    
}

//MARK: - UITableView Delegate
extension SavedListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isDraft {
            self.savedListVM?.surveyDraftFormList.count ?? 0
        } else {
            self.savedListVM?.surveyCompletedFormList.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableSavedFormList.dequeueReusableCell(withIdentifier: "SavedItemTVC", for: indexPath) as! SavedItemTVC
        
        var date = Date()
        if self.isDraft {
            date = Date(timeIntervalSince1970: Double(self.savedListVM?.surveyDraftFormList[indexPath.row].epochTime ?? 0))
        } else {
            date = Date(timeIntervalSince1970: Double(self.savedListVM?.surveyCompletedFormList[indexPath.row].epochTime ?? 0))
        }
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        cell.setupUI(data: dateString)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let surveyFormVC = storyboard.instantiateViewController(withIdentifier: "SurveyFormVC") as? SurveyFormVC {
            surveyFormVC.isInitial = false
            if self.isDraft {
                if let strData = self.savedListVM?.surveyDraftFormList[indexPath.row].formData {
                    if let jsonData = strData.data(using: .utf8) {
                        do {
                            let formData = try JSONDecoder().decode(SurveyFormModel.self, from: jsonData)
                            surveyFormVC.isDraftedForm = true
                            surveyFormVC.existingFormModel = formData
                        } catch {
                            self.showAlert(title: "Warning", message: "Unable to process data")
                        }
                        
                    }
                }
            } else {
                if let strData = self.savedListVM?.surveyCompletedFormList[indexPath.row].formData {
                    if let jsonData = strData.data(using: .utf8) {
                        do {
                            let formData = try JSONDecoder().decode(SurveyFormModel.self, from: jsonData)
                            surveyFormVC.isDraftedForm = false
                            surveyFormVC.existingFormModel = formData
                        } catch {
                            self.showAlert(title: "Warning", message: "Unable to process data")
                        }
                        
                    }
                }
            }
            self.navigationController?.pushViewController(surveyFormVC, animated: true)
        }
        
    }
    
    
}

//MARK: - SavedListVM Delegate
extension SavedListVC: SavedListVMDelegate {
    func loadSavedList() {
        self.tableSavedFormList.reloadData()
    }
    
}
