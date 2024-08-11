//
//  SurveyFormVM.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 08/08/24.
//

import Foundation
import Alamofire

protocol SurveyFormVMResponseDelegate : AnyObject {
    
    func startIndicator()
    func stopIndicator()
    func showErrorAlert(message: String?)
    func loadSurveyForm(data: SurveyFormModel)
    func submissionSuccessAlert(message: String?)
    func formSaveSuccess(message: String?)
}

protocol SurveyFormVMProtocol : AnyObject {
    
    var responseDelegate : SurveyFormVMResponseDelegate? {get set}
    var surveyData : SurveyFormModel? {get}
    var inspectionData : InspectionModel? {get}
    var numberOfCategories : Int {get}
    
    func categories(index: Int) -> CategoryModel
    func getSurveyFormAPI()
    func submitSurveyFormAPI(params: [String: Any])
    func saveSurveyFormData(formData: SurveyFormModel, isDraft: Bool)
    func getExistingFormData(data: SurveyFormModel)
    
}

class SurveyFormVM : SurveyFormVMProtocol {

    var dbManager = DBManager()
    var responseDelegate: SurveyFormVMResponseDelegate?
    
    var surveyResData : SurveyFormModel?
    var categoriesData : [CategoryModel] = []
    var areaName : String = ""
    var inspectionType : String = ""
    var inspectionRespData : InspectionModel?
    
    var surveyData: SurveyFormModel? {
        return surveyResData
    }
    
    var inspectionData: InspectionModel? {
        return inspectionRespData
    }
    
    var numberOfCategories: Int {
        return categoriesData.count
    }
    
    func categories(index: Int) -> CategoryModel {
        return categoriesData[index]
    }
    
    func getSurveyFormAPI() {
        
        self.responseDelegate?.startIndicator()
        
        TendableAPI.instance.getServiceData(url: APIEndpoints.startSurvey, method: .get, parameters: nil, encodingType: JSONEncoding.default, headers: [:]) { [weak self] (result: Result<SurveyFormModel, ErrorCases>) in
            
            self?.responseDelegate?.stopIndicator()
            
            switch result {
            case .success(let respData):
                
                self?.surveyResData = respData
                self?.inspectionRespData = respData.inspection
                self?.categoriesData = respData.inspection.survey.categories 
                self?.responseDelegate?.loadSurveyForm(data: respData)
                
                
            case .failure(let error):
                switch error {
                case .noInternet:
                    self?.responseDelegate?.showErrorAlert(message:"")
                    
                case .baseError(let errStr):
                    self?.responseDelegate?.showErrorAlert(message: errStr)
                    
                case .forbidden(let errStr):
                    print(errStr)
                    self?.responseDelegate?.showErrorAlert(message: errStr)
                    
                default:
                    print("Error")
                }
            }
        }
        
    }
    
    func submitSurveyFormAPI(params: [String: Any]) {
        
        self.responseDelegate?.startIndicator()
        
        TendableAPI.instance.getServiceData(url: APIEndpoints.submitSurvey, method: .post, parameters: params, encodingType: JSONEncoding.default, headers: [:]) { [weak self] (result: Result<SuccessModel, ErrorCases>) in
            
            self?.responseDelegate?.stopIndicator()
            
            switch result {
            case .success(let respData):
                
                self?.responseDelegate?.submissionSuccessAlert(message: "Form submitted successfully")
                
            case .failure(let error):
                switch error {
                case .noInternet:
                    self?.responseDelegate?.showErrorAlert(message:"")
                    
                case .baseError(let errStr):
                    self?.responseDelegate?.showErrorAlert(message: errStr)
                    
                case .forbidden(let errStr):
                    print(errStr)
                    self?.responseDelegate?.showErrorAlert(message: errStr)
                    
                default:
                    print("Error")
                }
            }
        }
    }
    
    //Saving data in DB
    func saveSurveyFormData(formData: SurveyFormModel, isDraft: Bool) {
        
        do {
            let jsonData = try JSONEncoder().encode(formData)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                let currentTimeInSeconds = Int64(Date().timeIntervalSince1970)
                
                let surveyFormFeed = SurveyFormDataModel(epochTime: currentTimeInSeconds, formData: jsonString, isDraft: isDraft, id: 1)
                
                let isDataSaved = dbManager.saveSurveyFormData(surveyFormFeed)
                if isDataSaved {
                    self.responseDelegate?.formSaveSuccess(message: "Form saved successfully")
                } else {
                    self.responseDelegate?.showErrorAlert(message: "Error while saving data in Database")
                }
                
            }
        } catch {
            self.responseDelegate?.showErrorAlert(message: "Error while processing the data")
        }
        
    }
    
    
    func getExistingFormData(data: SurveyFormModel) {
        
        self.surveyResData = data
        self.categoriesData = data.inspection.survey.categories
        self.responseDelegate?.loadSurveyForm(data: data)
        
    }
    
}
