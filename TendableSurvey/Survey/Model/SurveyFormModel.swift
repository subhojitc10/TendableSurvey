//
//  SurveyFormModel.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 08/08/24.
//

import UIKit

// MARK: - SurveyFormModel
class SurveyFormModel: Codable {
    var inspection: InspectionModel

    init(inspection: InspectionModel) {
        self.inspection = inspection
    }
}

// MARK: - Inspection
class InspectionModel: Codable {
    var area: Area
    var id: Int
    var inspectionType: InspectionType
    var survey: Survey

    init(area: Area, id: Int, inspectionType: InspectionType, survey: Survey) {
        self.area = area
        self.id = id
        self.inspectionType = inspectionType
        self.survey = survey
    }
}

// MARK: - Area
class Area: Codable {
    var id: Int
    var name: String

    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

// MARK: - InspectionType
class InspectionType: Codable {
    var access: String
    var id: Int
    var name: String

    init(access: String, id: Int, name: String) {
        self.access = access
        self.id = id
        self.name = name
    }
}

// MARK: - Survey
class Survey: Codable {
    var categories: [CategoryModel]
    var id: Int

    init(categories: [CategoryModel], id: Int) {
        self.categories = categories
        self.id = id
    }
}

// MARK: - Category
class CategoryModel: Codable {
    var id: Int
    var name: String
    var questions: [QuestionModel]

    init(id: Int, name: String, questions: [QuestionModel]) {
        self.id = id
        self.name = name
        self.questions = questions
    }
}

// MARK: - Question
class QuestionModel: Codable {
    var answerChoices: [AnswerChoiceModel]
    var id: Int
    var name: String
    var selectedAnswerChoiceID: Int

    enum CodingKeys: String, CodingKey {
        case answerChoices, id, name
        case selectedAnswerChoiceID = "selectedAnswerChoiceId"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.answerChoices = try container.decodeIfPresent([AnswerChoiceModel].self, forKey: .answerChoices) ?? []
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.selectedAnswerChoiceID = try container.decodeIfPresent(Int.self, forKey: .selectedAnswerChoiceID) ?? 0
    }

    init(answerChoices: [AnswerChoiceModel], id: Int, name: String, selectedAnswerChoiceID: Int) {
        self.answerChoices = answerChoices
        self.id = id
        self.name = name
        self.selectedAnswerChoiceID = selectedAnswerChoiceID
    }
}

// MARK: - AnswerChoice
class AnswerChoiceModel: Codable {
    var id: Int
    var name: String
    var score: Double
    var isSelected: Bool? = false
    
    init(id: Int, name: String, score: Double) {
        self.id = id
        self.name = name
        self.score = score
    }
}

