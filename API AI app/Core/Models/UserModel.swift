import Foundation
import SwiftData

@Model
final class UserModel {
    @Attribute(.unique) var appleUserID: String
    var fullName: String
    var email: String
    var isPro: Bool
    var weeklyUsage: Int
    var createdAt: Date

    init(appleUserID: String, fullName: String, email: String) {
        self.appleUserID = appleUserID
        self.fullName = fullName
        self.email = email
        self.isPro = false
        self.weeklyUsage = 0
        self.createdAt = Date()
    }
}
