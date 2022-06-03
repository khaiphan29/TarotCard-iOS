import Foundation

//MARK: - Delegate Protocol
protocol FirebaseModelDelegate {
    func didSignUpUser()
    func didSignIn(user: User)
    func didCompleteQuery(documentList: [UserMatchingDocData])
    func didCreateDocument()
    func didFailWithError(error: Error?, httpResponse: HTTPURLResponse?)
    func didFailSignIn(message: String)
    func didFailSignUpWithError(error: Error?, httpResponse: HTTPURLResponse?)
    func didFailSignUp(message: String)
    func didFailSignInWithError(error: Error?, httpResponse: HTTPURLResponse?)
}

extension FirebaseModelDelegate {
    func didSignUpUser() {}
    func didUpdateUser(user: User) {}
    func didCompleteQuery(documentList: [UserMatchingDocData]) {}
    func didCreateDocument() {}
    func didFailWithError(error: Error?, httpResponse: HTTPURLResponse?) {}
    func didFailSignIn(message: String) {}
    func didFailSignUpWithError(error: Error?, httpResponse: HTTPURLResponse?) {}
    func didFailSignUp(message: String) {}
    func didFailSignInWithError(error: Error?, httpResponse: HTTPURLResponse?) {}
}

struct FireBaseModel {
    let API_KEY: String
    let PROJECT_ID: String
    var delegate: FirebaseModelDelegate?

    func signUp(email:String, password:String) {
        //Create JSON data
        let json: [String: Any] = ["email": email,"password": password,"returnSecureToken":true]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        //Create URL
        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=\(API_KEY)")!
        
        //Create HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        //Create task
        //Run in background
        //Share session doesn’t have a configuration object, default section is similar to shared but customizable
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Sign Up Error")
                delegate?.didFailSignUpWithError(error: error!, httpResponse: response as? HTTPURLResponse)
                return
            }
            //print(String(data: data!, encoding: .utf8)!)
            do {
                let parseData = try JSONDecoder().decode(ErrorMessageData.self, from: data!)
                //print(parseData)
                delegate?.didFailSignUp(message: parseData.error.message)
            } catch {
                //print("complete sign up")
                delegate?.didSignUpUser()
            }
        }
        task.resume()
        
    }


    func signIn(email:String, password:String) {
        //Create JSON data
        let json: [String: Any] = ["email": email,"password": password,"returnSecureToken":true]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        //Create URL
        let url = URL(string: "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(API_KEY)")!
        
        //Create HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        //Create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                delegate?.didFailSignInWithError(error: error!, httpResponse: response as? HTTPURLResponse)
                return
            }
            do {
                let parseData = try JSONDecoder().decode(User.self, from: data!)
                delegate?.didSignIn(user: parseData)
            } catch {
                do {
                    let parseData = try JSONDecoder().decode(ErrorMessageData.self, from: data!)
                    delegate?.didFailSignIn(message: parseData.error.message)
                } catch {
                    print("JSON Sign In error: \(error)")
                }
            }
        }

        task.resume()
    }

    func createDocument(in name: String, json: [String: Any]) {
        //Create JSON data
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        //Create URL
        let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(PROJECT_ID)/databases/(default)/documents/\(name)?key=\(API_KEY)")!
        
        //Create HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData

        //Create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                delegate?.didFailWithError(error: error!, httpResponse: response as? HTTPURLResponse)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
            delegate?.didCreateDocument()
        }
        task.resume()
    }

    func queryDocument(jsonQuery: [String: Any], idToken: String? = nil) {
        //Create JSON data
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonQuery)
        
        //Create URL
        let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(PROJECT_ID)/databases/(default)/documents:runQuery?key=\(API_KEY)")!
        
        //Create HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = idToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = jsonData

        //Create task
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if error != nil {
                delegate?.didFailWithError(error: error!, httpResponse: response as? HTTPURLResponse)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print ("HTTP Query Status Code: \(httpResponse.statusCode)")
            }
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                //print(String(data: data!, encoding: .utf8)!)
                do {
                    if idToken == nil {
                        let parseData = try JSONDecoder().decode([UserMatchingDocData].self, from: data!)
                        delegate?.didCompleteQuery(documentList: parseData)
                        
                        // -- Another way is to use JSONSerialization
                        /*let jsonObj = try  JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                        print (jsonObj as? [[String:Any]])
                        print(type(of: jsonObj)) */
                    }
                } catch {
                    print("Query Parse JSON Error: \(error.localizedDescription)")
                    delegate?.didFailWithError(error: error, httpResponse: response as? HTTPURLResponse)
                }
            }
        }

        task.resume()
    }
}

