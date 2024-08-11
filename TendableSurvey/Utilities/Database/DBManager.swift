//
//  DBManager.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 10/08/24.
//

import UIKit
import Foundation
import CoreData

class DBManager {
    
    private var context : NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    
    //Saving Data
    func saveSurveyFormData(_ feed: SurveyFormDataModel) -> Bool {
        
        let surveyFormEntity = SurveyFormEntity(context: context)
        surveyFormEntity.epochTime = feed.epochTime
        surveyFormEntity.formData = feed.formData
        surveyFormEntity.isDraft = feed.isDraft
        surveyFormEntity.id = feed.id
        
        //Perfroming save data operation in DB
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    
    
    //Fetching Data
    func fetchSurveyFormData() -> [SurveyFormEntity] {
        
        var bgData: [SurveyFormEntity] = []
        
        do {
            bgData = try context.fetch(SurveyFormEntity.fetchRequest())
        } catch {
            bgData = []
        }
        
        return bgData
    }
    
    
    //Delete Data
    func deleteAllData() {
        do {
            let results = try context.fetch(SurveyFormEntity.fetchRequest())
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data has encountered error :", error)
        }
    }
    
}


struct SurveyFormDataModel {
    var epochTime: Int64
    var formData: String
    var isDraft: Bool
    var id: Int32
}
