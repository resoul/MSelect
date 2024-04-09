//
//  Account.swift
//  iOS
//

struct Account: Codable {
    let uuid: String
    let username: String
    let fullName: String
    let profilePicture: String
    let isPrivate: Bool
    let biography: String
    let media: Int
    let followers: Int
    let following: Int
    
    enum CodingKeys: String, CodingKey {
        case uuid, username, fullName, profilePicture, isPrivate, biography, media, followers, following
    }
}
