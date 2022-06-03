//
//  UserManager.swift
//  TarotCard-ConceptCube
//
//  Created by Phan Khai on 02/06/2022.
//
import Foundation

//MARK: - Delegate Protocols
protocol UserManagerAuthDelegate {
    func didSignIn()
    func didSignUp()
    func didFailSignUpWithError(error: Error?)
    func didFailSignUp(with message: String)
    func didFailSignInWithError(error: Error?)
    func didFailSignIn(with message: String)
}

extension UserManagerAuthDelegate {
    func didSignIn() {}
    func didSignUp() {}
    func didFailSignUpWithError(error: Error?) {}
    func didFailSignUp(with message: String) {}
    func didFailSignInWithError(error: Error?) {}
    func didFailSignIn(with message: String) {}
}

protocol UserManagerQueryDelegate {
    func didCheckedUsername(result: Bool)
    func didCreateDocument()
    func didFailWithError(error: Error?)
}

//MARK: - User Manager
class UserManager {
    var authDelegate: UserManagerAuthDelegate?
    var queryDelegate: UserManagerQueryDelegate?
    static var currentUser: User?
    private var isCheckingUser = false
    private var isLoggingIn = false
    private var isBindingUser = false
    
    private var firebaseModel = FireBaseModel(API_KEY: API_KEY, PROJECT_ID: PROJECT_ID)
    private var password: String?
    private var userID: String?
    private var email: String?
    private var birthday: String?
    
    init() {
        firebaseModel.delegate = self
    }
    
    //MARK: - User Interface
    func userLogin(userID: String, password: String) {
        self.password = password
        isLoggingIn = true
        checkUserID(userID: userID)
    }
    
    func userSignUp(userID: String, password: String, email: String, birthday: String) {
        self.email = email
        self.userID = userID
        self.birthday = birthday
        firebaseModel.signUp(email: email, password: password)
    }
    
    func checkUserID (userID: String) {
        if isLoggingIn == false {
            isCheckingUser = true
        }
        let json = ["structuredQuery":["select":
                                        ["fields":["fieldPath": UserMatch.emailField]],
                                      "from": ["collectionId": UserMatch.name],
                                      "where":["fieldFilter":
                                                ["field":["fieldPath": UserMatch.userIDField],
                                               "op": "EQUAL",
                                                 "value": ["stringValue": userID]]]]]
        firebaseModel.queryDocument(jsonQuery: json)
    }
    
    //MARK: - Firebase login
    private func firebaeLogin(email: String) {
        if let safePass = password {
            firebaseModel.signIn(email: email, password: safePass)
        }
    }
}

//MARK: - FirebaseModelDelegate
extension UserManager: FirebaseModelDelegate {
    func didSignUpUser() {
        //Create record that match user ID to email
        isBindingUser = true
        let recordJSON: [String: Any] = ["fields":[UserMatch.userIDField:["stringValue": userID!],
                                                   UserMatch.emailField:["stringValue": email!]]]
        firebaseModel.createDocument(in: UserMatch.name, json: recordJSON)
        
        //Create record containing user private info
        let userInfoJSON: [String: Any] = ["fields":[UserPrivate.userIDField:["stringValue": userID!],
                                                   UserPrivate.emailField:["stringValue": email!],
                                                     UserPrivate.BirthdayField: ["stringValue": birthday!]]]
        firebaseModel.createDocument(in: UserPrivate.name, json: userInfoJSON)
        
        //Reset variable
        self.birthday = nil
        self.email = nil
        self.password = nil
        self.userID = nil
    }
    
    func didFailSignUpWithError(error: Error?, httpResponse: HTTPURLResponse?) {
        authDelegate?.didFailSignUpWithError(error: error)
    }
    
    func didFailSignUp(message: String) {
        //print("Fail sign up")
        authDelegate?.didFailSignUp(with: message)
    }
    
    func didSignIn(user: User) {
        UserManager.currentUser = user
        authDelegate?.didSignIn()
    }
    
    func didFailSignIn(message: String) {
        authDelegate?.didFailSignIn(with: message)
    }
    
    //MARK: - Query handler
    func didCompleteQuery(documentList: [UserMatchingDocData]) {
        if isCheckingUser {
            queryDelegate?.didCheckedUsername(result: true)
            isCheckingUser = false
        }
        else {
            firebaeLogin(email: documentList[0].document.fields.email.stringValue)
        }
    }
    
    func didCreateDocument() {
        if isBindingUser {
            print(isBindingUser)
            authDelegate?.didSignUp()
            isBindingUser = false
        }
    }
    
    func didFailWithError(error: Error?, httpResponse: HTTPURLResponse?) {
        //Response for login and signup
        if isCheckingUser || isLoggingIn {
            //print ("return to Checker")
            queryDelegate?.didCheckedUsername(result: false)
            isCheckingUser = false
            isLoggingIn = false
        } else {
            queryDelegate?.didFailWithError(error: error)
        }   
    }
}
