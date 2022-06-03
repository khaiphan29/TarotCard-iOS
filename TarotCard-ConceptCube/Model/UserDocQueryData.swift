

struct UserMatchingDocData: Codable {
    let document: UserDocument
}

struct UserDocument: Codable {
    let name: String
    let fields: UserFieldData
}

struct UserFieldData: Codable {
    let email: UserData
}

struct UserData: Codable {
    let stringValue: String
}
