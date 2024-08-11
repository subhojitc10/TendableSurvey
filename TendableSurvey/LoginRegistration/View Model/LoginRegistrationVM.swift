//
//  LoginVM.swift
//  TendableTest
//
//  Created by Subhojit Chatterjee on 06/08/24.
//

import Foundation
import Alamofire



protocol LoginRegistrationVMResponseDelegate: AnyObject {
    func startIndicator()
    func stopIndicator()
    func registerSuccessAlert(message: String?)
    func loginSuccessAlert(message: String?)
    func showErrorAlert(message: String?)
}

protocol LoginRegistrationVMProtocol: AnyObject {
    
    var  responseDelegate : LoginRegistrationVMResponseDelegate? {get set}
    func callRegisterAPI(params: [String: Any])
    func callLoginAPI(params: [String: Any])
}

class LoginRegistrationVM : LoginRegistrationVMProtocol {
    
    weak var responseDelegate: LoginRegistrationVMResponseDelegate?
    
    func callRegisterAPI(params: [String: Any]) {
        
        self.responseDelegate?.startIndicator()
        
        TendableAPI.instance.getServiceData(url: APIEndpoints.registerAPI, method: .post, parameters: params, encodingType: JSONEncoding.default, headers: [:]) { [weak self] (result: Result<SuccessModel, ErrorCases>) in
            
            self?.responseDelegate?.stopIndicator()
            
            switch result {
            case .success(let respData):
                print(respData)
                
                self?.responseDelegate?.registerSuccessAlert(message: "Registeration Successfull")
                
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
    
    
    func callLoginAPI(params: [String: Any]) {
        
        self.responseDelegate?.startIndicator()
        
        TendableAPI.instance.getServiceData(url: APIEndpoints.loginAPI, method: .post, parameters: params, encodingType: JSONEncoding.default, headers: [:]) { [weak self] (result: Result<SuccessModel, ErrorCases>) in
            
            self?.responseDelegate?.stopIndicator()
            
            switch result {
            case .success(let respData):
                print(respData)
                self?.responseDelegate?.loginSuccessAlert(message: "Login Successfull")
                
            case .failure(let error):
                switch error {
                case .noInternet:
                    self?.responseDelegate?.showErrorAlert(message:"")
                    
                case .baseError(let errStr):
                    self?.responseDelegate?.showErrorAlert(message: errStr)
                    
                case .forbidden(let errStr):
                    self?.responseDelegate?.showErrorAlert(message: errStr)
                    
                default:
                    print("Error")
                }
            }
        }
            
    }
    
}
