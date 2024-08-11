//
//  SurveyFormEntity+CoreDataProperties.swift
//  
//
//  Created by Subhojit Chatterjee on 10/08/24.
//
//

import Foundation
import CoreData


extension SurveyFormEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SurveyFormEntity> {
        return NSFetchRequest<SurveyFormEntity>(entityName: "SurveyFormEntity")
    }

    @NSManaged public var formData: String?
    @NSManaged public var epochTime: Int64
    @NSManaged public var isDraft: Bool
    @NSManaged public var id: Int32

}
