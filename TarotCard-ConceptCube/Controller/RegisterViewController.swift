//
//  RegisterController.swift
//  TarotCard-ConceptCube
//
//  Created by Phan Khai on 02/06/2022.
//
import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repassTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    var userManager = UserManager()
    //Check if username is verified (check button)
    var isVerified = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        joinButton.layer.cornerRadius = 5
        joinButton.titleLabel?.font = .systemFont(ofSize: 25)
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        
        userManager.queryDelegate = self
        userManager.authDelegate = self
        setUpTextField()
        userIDTextField.becomeFirstResponder()
        
        userIDTextField.addTarget(self, action: #selector(usernameChanged(_:)), for: .editingChanged)
        setUpDatePicker()
        
    }
    
    func setUpTextField() {
        userIDTextField.delegate = self
        passwordTextField.delegate = self
        repassTextField.delegate = self
        emailTextField.delegate = self
    }
    
    //MARK: - Date Picker
    func setUpDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        //Set size
        datePicker.frame.size = CGSize(width: 0, height: 300)
        //Add Listner
        datePicker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        //Set datePicker to Text Field
        birthdayTextField.inputView = datePicker
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        birthdayTextField.text = formatDate(date: datePicker.date)
    }
    
    func formatDate(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd y"
        return formatter.string(from: date)
    }
    
    //MARK: - User ID Change
    @objc func usernameChanged(_ textfield: UITextField) {
        checkButton.backgroundColor = .clear
        self.checkButton.tintColor = .systemBlue
        isVerified = false
    }
    
    //MARK: - Button processing
    @IBAction func checkButtonPressed(_ sender: UIButton) {
        if userIDTextField.text != "" {
            userManager.checkUserID(userID: userIDTextField.text!)
        } else {
            showAlert(title: "Empty User ID", message: "Please fill in User ID Field.", buttonTitle: "Done")
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        if passwordTextField.text != repassTextField.text {
            showAlert(title: "Password does not matched.", message: nil, buttonTitle: "Done")
        }
        if userIDTextField.text != "" &&
            passwordTextField.text != "" &&
            repassTextField.text != "" &&
            emailTextField.text != "" &&
            birthdayTextField.text != "" {
            
            if isVerified == false {
                showAlert(title: "Invalid User ID", message: "Make sure your ID is unique before join us\nClick on check button to verify", buttonTitle: "Done")
            }
            else {
                view.endEditing(true)
                let alert = UIAlertController(title: "Join...", message: nil, preferredStyle: .alert)
                self.present(alert, animated: false)
                userManager.userSignUp(userID: userIDTextField.text!, password: passwordTextField.text!, email: emailTextField.text!, birthday: birthdayTextField.text!)
            }
        }
        else {
            showAlert(title: "Empty Fields.", message: "Please fill all fields", buttonTitle: "Done")
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(title: String, message: String?, buttonTitle: String) {
        self.dismiss(animated: true)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        self.present(alert, animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text! == "" {
            return false
        }
        if textField == userIDTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            repassTextField.becomeFirstResponder()
        } else if textField == repassTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            birthdayTextField.becomeFirstResponder()
        }
        return true
    }
}

//MARK: - UserManagerQueryDelegate
extension RegisterViewController: UserManagerQueryDelegate {
    func didCheckedUsername(result: Bool) {
        if result {
            DispatchQueue.main.async {
                self.showAlert(title: "User ID Already Exists", message: "Please choose another user ID.", buttonTitle: "Done")
                self.checkButton.tintColor = .systemRed
            }
        } else {
            isVerified = true
            DispatchQueue.main.async {
                self.checkButton.backgroundColor = .systemGreen
                self.checkButton.layer.cornerRadius = 5
                self.checkButton.tintColor = .white
            }
        }
    }
    
    
    func didCreateDocument() {
    }
    
    //After sign up successfully, create record that match user iD to email
    func didFailWithError(error: Error?) {
        if let e = error {
            print("User Email binding fail with \(e)")
        }
    }
}

//MARK: - UserManagerAuthDelegate
extension RegisterViewController: UserManagerAuthDelegate {
    func didSignUp() {
        DispatchQueue.main.async {
            self.dismiss(animated: true)
            print("dismiss")
            let alert = UIAlertController(title: "Join Successfully", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Done", style: .default) { uiAlertAction in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alert, animated: true)
        }
    }
    
    func didFailSignUp(with message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Sign Up Fail", message: message, buttonTitle: "Done")
        }
    }
}
