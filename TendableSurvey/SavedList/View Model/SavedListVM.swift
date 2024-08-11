//
//  SavedListVM.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 10/08/24.
//

import Foundation

protocol SavedListVMDelegate : AnyObject {
    func loadSavedList()
}

protocol SavedListVMProtocol : AnyObject {
    var delegate : SavedListVMDelegate? {get set}
    var surveyDraftFormList: [SurveyFormEntity] {get}
    var surveyCompletedFormList: [SurveyFormEntity] {get}
    func getSavedFormList()
}

class SavedListVM : SavedListVMProtocol {

    weak var delegate: SavedListVMDelegate?
    var surveyDraftFormListData: [SurveyFormEntity] = []
    var surveyCompletedFormListData: [SurveyFormEntity] = []
    var dbManager = DBManager()
    
    var surveyDraftFormList : [SurveyFormEntity] {
        return surveyDraftFormListData
    }
    
    var surveyCompletedFormList : [SurveyFormEntity] {
        return surveyCompletedFormListData
    }
    
    func getSavedFormList() {
    
        self.surveyDraftFormListData.removeAll()
        self.surveyCompletedFormListData.removeAll()
        
        let surveyFormFetchedData = dbManager.fetchSurveyFormData()
        if surveyFormFetchedData.count > 0 {
            for data in surveyFormFetchedData {
                if data.isDraft {
                    self.surveyDraftFormListData.append(data)
                } else {
                    self.surveyCompletedFormListData.append(data)
                }
                
            }
            
            self.delegate?.loadSavedList()
        }
    }
    
    
}
