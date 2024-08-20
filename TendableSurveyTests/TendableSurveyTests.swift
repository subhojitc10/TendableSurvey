//
//  TendableSurveyTests.swift
//  TendableSurveyTests
//
//  Created by Subhojit Chatterjee on 06/08/24.
//

import XCTest
import Alamofire
@testable import TendableSurvey

final class TendableSurveyTests: XCTestCase {
    
    var loginRegistrationViewController: LoginRegistrationVC!

    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        loginRegistrationViewController = storyboard.instantiateViewController(withIdentifier: "LoginRegistrationVC") as? LoginRegistrationVC

        
        _ = loginRegistrationViewController.view
    }
    
    override func tearDown() {
        loginRegistrationViewController = nil
        super.tearDown()
    }

    
    func testValidEmail() {
        loginRegistrationViewController.tfEmailId.text = "test@example.com"
        XCTAssertTrue(isValidEmail(loginRegistrationViewController.tfEmailId.text!), "Valid email should return true")
    }
    
    func testInvalidEmailNoDomain() {
        loginRegistrationViewController.tfEmailId.text = "test@com"
        XCTAssertFalse(isValidEmail(loginRegistrationViewController.tfEmailId.text!), "Email without a proper domain should return false")
    }
    
    func testEmptyEmail() {
        loginRegistrationViewController.tfEmailId.text = ""
        XCTAssertFalse(isValidEmail(loginRegistrationViewController.tfEmailId.text!), "Empty email should return false")
    }
    
    func testEmptyPassword() {
        loginRegistrationViewController.tfPassword.text = ""
        XCTAssertFalse((loginRegistrationViewController.tfPassword.text?.count ?? 0 > 0), "Empty password should return false")
    }
    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}



class TendableAPIServiceTests: XCTestCase {
    
    var networkService: TendableAPI!

    override func setUp() {
        super.setUp()
        networkService = MockNetworkService()
    }

    override func tearDown() {
        MockURLProtocol.mockData = nil
        MockURLProtocol.mockError = nil
        MockURLProtocol.responseStatusCode = 200
        super.tearDown()
    }

    func testSuccessfulNetworkCall() throws {
        let mockJSON = """
        {
            "inspection": {
                "id": 1,
                "inspectionType": {
                    "id": 1,
                    "name": "Clinical",
                    "access": "write"
                },
                "area": {
                    "id": 1,
                    "name": "Emergency ICU"
                },
                "survey": {
                    "id": 1,
                    "categories": [
                        {
                            "id": 1,
                            "name": "Drugs",
                            "questions": [
                                {
                                    "id": 1,
                                    "name": "Is the drugs trolley locked?",
                                    "answerChoices": [
                                        {
                                            "id": 1,
                                            "name": "Yes",
                                            "score": 1.0
                                        },
                                        {
                                            "id": 2,
                                            "name": "No",
                                            "score": 0.0
                                        },
                                        {
                                            "id": -1,
                                            "name": "N/A",
                                            "score": 0.0
                                        }
                                    ],
                                    "selectedAnswerChoiceId": null
                                },
                                {
                                    "id": 2,
                                    "name": "How often is the floor cleaned?",
                                    "answerChoices": [
                                        {
                                            "id": 3,
                                            "name": "Everyday",
                                            "score": 1.0
                                        },
                                        {
                                            "id": 4,
                                            "name": "Every two days",
                                            "score": 0.5
                                        },
                                        {
                                            "id": 5,
                                            "name": "Every week",
                                            "score": 0.0
                                        }
                        
                                    ],
                                    "selectedAnswerChoiceId": null
                                }
                            ]
                        },
                        {
                            "id": 2,
                            "name": "Overall Impressions",
                            "questions": [
                                {
                                    "id": 3,
                                    "name": "How many staff members are present in the ward?",
                                    "answerChoices": [
                                        {
                                            "id": 6,
                                            "name": "1-2",
                                            "score": 0.5
                                        },
                                        {
                                            "id": 7,
                                            "name": "3-6",
                                            "score": 0.5
                                        },
                                        {
                                            "id": 8,
                                            "name": "6+",
                                            "score": 0.5
                                        },
                                        {
                                            "id": -1,
                                            "name": "N/A",
                                            "score": 0.0
                                        }

                                    ],
                                    "selectedAnswerChoiceId": null
                                },
                                {
                                    "id": 4,
                                    "name": "How often are the area inspections carried?",
                                    "answerChoices": [
                                        {
                                            "id": 9,
                                            "name": "Very often",
                                            "score": 0.5
                                        },
                                        {
                                            "id": 10,
                                            "name": "Often",
                                            "score": 0.5
                                        },
                                        {
                                            "id": 11,
                                            "name": "Not very often",
                                            "score": 0.5
                                        },
                                        {
                                            "id": 12,
                                            "name": "Never",
                                            "score": 0.5
                                        }
                        
                                    ],
                                    "selectedAnswerChoiceId": null
                                }
                            ]
                        }
                    ]
                }
            }
        }

        """.data(using: .utf8)!
        MockURLProtocol.mockData = mockJSON

        let expectation = self.expectation(description: "Network call completes")
        networkService.getServiceData(url: APIEndpoints.startSurvey, method: .get, parameters: nil, encodingType: JSONEncoding.default, headers: [:]) { [weak self] (result: Result<SurveyFormModel, ErrorCases>) in
            
            switch result {
            case .success(let response):
                XCTAssertEqual(response.inspection.survey.categories[0].questions.count, 1)
                XCTAssertEqual(response.inspection.survey.categories[0].questions[0].name, "Is the drugs trolley locked?")
            case .failure(let error):
                XCTFail("Expected success but got failure: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
