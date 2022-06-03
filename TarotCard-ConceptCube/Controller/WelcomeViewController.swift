//
//  ViewController.swift
//  TarotCard-ConceptCube
//
//  Created by Phan Khai on 02/06/2022.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var joinInButton: UIButton!
    
    let userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        loginButton.titleLabel?.font = .systemFont(ofSize: 25)
        joinInButton.titleLabel?.font = .systemFont(ofSize: 25)
        
        userManager.authDelegate = self
        userManager.queryDelegate = self
        
        setUpTextField()
        
        //View tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func setUpTextField() {
        userIDTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //MARK: - Button Processing
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: SegueName.LoginToRegister, sender: self)
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        login()
    }
    
    func login() {
        if userIDTextField.text != "" &&
            passwordTextField.text != "" {
            userManager.userLogin(userID: userIDTextField.text!, password: passwordTextField.text!)
        }
        else {
            showAlert(title: "Blank Field", message: "Please fill in all fields", buttonTitle: "Done")
        }
    }
    
    func showAlert(title: String, message: String?, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
        self.present(alert, animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text! == "" {
            return false
        }
        if textField == userIDTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            login()
        }
        return true
    }
}

//MARK: - UserManagerAuthDelegate

extension WelcomeViewController: UserManagerAuthDelegate {
    func didFailSignIn(with message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Login Error", message: message, buttonTitle: "Done")
        }
    }
    
    func didSignIn() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: SegueName.LoginToMain, sender: self)
            //let mainVC = UIHostingController(rootView: MainSwiftUIView())
            //self.present(mainVC, animated: true)
        }
    }
}

//MARK: - UserManagerQueryDelegate

extension WelcomeViewController: UserManagerQueryDelegate {
    func didCreateDocument() {}
    
    func didFailWithError(error: Error?) {}
    
    func didCheckedUsername(result: Bool) {
        if !result {
            DispatchQueue.main.async {
                self.showAlert(title: "User ID does not exist", message: "Please check your User ID or Sign Up using Join button", buttonTitle: "Done")
            }
        }
    }
}

