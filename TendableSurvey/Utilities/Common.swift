//
//  Common.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 07/08/24.
//

import Foundation

enum APIEndpoints {
    
    static let registerAPI = "api/register"
    static let loginAPI = "api/login"
    static let startSurvey = "api/inspections/start"
    static let submitSurvey = "api/inspections/submit"
    
}

func isValidEmail(_ email: String) -> Bool {
    // Define the regex pattern for a valid email
    let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
    
    // Create a predicate with the regex pattern
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    
    // Evaluate the email string with the predicate
    return emailPredicate.evaluate(with: email)
}
