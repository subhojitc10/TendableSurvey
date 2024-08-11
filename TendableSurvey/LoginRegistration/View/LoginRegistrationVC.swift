//
//  LoginVC.swift
//  TendableSurvey
//
//  Created by Subhojit Chatterjee on 06/08/24.
//

import UIKit

class LoginRegistrationVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLoginWrapper: UIView!
    @IBOutlet weak var viewEmailBackground: UIView!
    @IBOutlet weak var tfEmailId: UITextField!
    @IBOutlet weak var viewPasswordBackground: UIView!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnShowPassword: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnAlreadyUser: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    //MARK: - Properties
    private var isRegistered: Bool = false
    private var showPassword: Bool = true
    private var loginRegisterVM: LoginRegistrationVMProtocol?
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginRegisterVM = LoginRegistrationVM()
        self.loginRegisterVM?.responseDelegate = self
        
        self.setupUI()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupUI() {
        
        //Wrapper View
        self.viewLoginWrapper.layer.cornerRadius = 40.0
        self.viewLoginWrapper.layer.masksToBounds = true
        self.viewLoginWrapper.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        //Activity Indicator
        self.indicatorView.isHidden = true
        
        //Email id Text field
        self.tfEmailId.placeholder = "Enter Email Id"
        self.tfEmailId.textColor = UIColor(hex: "#181b35")
        self.tfEmailId.autocorrectionType = .no
        self.tfEmailId.addDoneButtonOnKeyboard()
        
        self.viewEmailBackground.layer.cornerRadius = 10
        self.viewEmailBackground.layer.masksToBounds = true
        self.viewEmailBackground.layer.borderWidth = 0.5
        self.viewEmailBackground.layer.borderColor = UIColor(hex: "#181b35")?.cgColor

        //Password Text field
        self.tfPassword.placeholder = "Enter password"
        self.tfPassword.textColor = UIColor(hex: "#181b35")
        self.tfPassword.autocorrectionType = .no
        self.tfPassword.addDoneButtonOnKeyboard()
        
        self.viewPasswordBackground.layer.cornerRadius = 10
        self.viewPasswordBackground.layer.masksToBounds = true
        self.viewPasswordBackground.layer.borderWidth = 0.5
        self.viewPasswordBackground.layer.borderColor = UIColor(hex: "#181b35")?.cgColor
        
        
        //Submit Button
        self.btnSubmit.layer.cornerRadius = 8
        self.btnSubmit.layer.masksToBounds = true
        
        
    }
    
    fileprivate func validateInput() -> Bool {
        
        if tfEmailId.text?.count ?? 0 <= 0 {
            self.showAlert(title: "Warning", message: "Please enter the emailID")
            return false
        }
        
        if tfPassword.text?.count ?? 0 <= 0 {
            self.showAlert(title: "Warning", message: "Please enter the password")
            return false
        }
        
        if !isValidEmail(tfEmailId.text ?? "") {
            self.showAlert(title: "Warning", message: "Invalid EmailId")
            return false
        }
        
        return true
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            if self.view.frame.origin.y == 0 {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin.y -= keyboardHeight
                }
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }
    
    
}

//MARK: - Button Actions
extension LoginRegistrationVC {
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func showPasswordBtnTouch(_ sender: Any) {
        
        if self.showPassword {
            self.showPassword = false
            self.btnShowPassword.setImage(UIImage(systemName: "eye"), for: .normal)
            self.tfPassword.isSecureTextEntry = false
            
        } else {
            self.showPassword = true
            self.btnShowPassword.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            self.tfPassword.isSecureTextEntry = true
            
        }
    }
    
    @IBAction func submitBtnTouch(_ sender: Any) {
        
        if validateInput() {
            var params : [String:Any] = [:]
            params["email"] = tfEmailId.text
            params["password"] = tfPassword.text
            if self.isRegistered {
                self.loginRegisterVM?.callLoginAPI(params: params)
            } else {
                self.loginRegisterVM?.callRegisterAPI(params: params)
            }
        }
    }
    
    @IBAction func btnAlreadyUserLoginTouch(_ sender: Any) {
        
        self.tfPassword.resignFirstResponder()
        self.tfEmailId.resignFirstResponder()
        self.tfEmailId.text = ""
        self.tfPassword.text = ""
        
        if !self.isRegistered {
            //Register to Login
            self.isRegistered = true
            
            self.lblTitle.text = "Login"
            self.btnAlreadyUser.setTitle("New User? Register", for: .normal)
            self.btnSubmit.setTitle("LOGIN", for: .normal)
        } else {
            //Register to Login
            self.isRegistered = false
            
            self.lblTitle.text = "Register"
            self.btnAlreadyUser.setTitle("Already User? Login", for: .normal)
            self.btnSubmit.setTitle("REGISTER", for: .normal)
        }
    }
    
}


//MARK: - LoginVMResponse Delegate
extension LoginRegistrationVC : LoginRegistrationVMResponseDelegate {
    
    func startIndicator() {
        
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }
    
    func stopIndicator() {
        
        self.indicatorView.stopAnimating()
        self.indicatorView.isHidden = true
        
    }
    
    func registerSuccessAlert(message: String?) {
        
        self.tfPassword.resignFirstResponder()
        self.tfEmailId.resignFirstResponder()
        
        self.showAlert(title: "Successfull", message: message ?? "")
        self.isRegistered = true
        self.tfEmailId.text = ""
        self.tfPassword.text = ""
        self.lblTitle.text = "Login"
        self.btnAlreadyUser.setTitle("New User? Register", for: .normal)
        self.btnSubmit.setTitle("LOGIN", for: .normal)
        
    }
    
    func loginSuccessAlert(message: String?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let surveyFormVC = storyboard.instantiateViewController(withIdentifier: "SurveyFormVC") as? SurveyFormVC {
            surveyFormVC.isInitial = true
            self.navigationController?.pushViewController(surveyFormVC, animated: true)
            
            var dbManager = DBManager()
            dbManager.deleteAllData()
        }
        
    }
    
    func showErrorAlert(message: String?) {
        self.showAlert(title: "Warning", message: message ?? "")
    }
    
    
}
