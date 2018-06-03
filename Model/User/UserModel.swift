//
//  UserModel.swift
//  eMia
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxRealm

final class UserModel: Object {

   @objc dynamic var key: String = ""
   @objc dynamic var userId: String = ""
   @objc dynamic var name: String = ""
   @objc dynamic var email: String = ""
   @objc dynamic var address: String? = nil
   @objc dynamic var _gender: Int = 0
   @objc dynamic var yearbirth: Int = 0
   @objc dynamic var tokenIOS: String? = nil
   @objc dynamic var tokenAndroid: String? = nil
   
   override class func primaryKey() -> String? {
      return "userId"
   }
   
   var gender: Gender? {
      get {
         return Gender(rawValue: self._gender)
      }
      set {
         self._gender = newValue?.rawValue ?? 0
      }
   }
   
   convenience init(name: String, email: String, address: String?, gender: Gender?, yearbirth: Int?) {
      self.init()
      self.name = name
      self.email = email
      self.address = address
      self._gender = gender == nil ? Gender.both.rawValue : gender!.rawValue
      self.yearbirth = yearbirth ?? 0
   }
   
   convenience init(key: String, userId: String, name: String, email: String, address: String?, gender: Gender?, yearbirth: Int?, tokenIOS: String?, tokenAndroid: String?) {
      self.init(name: name, email: email, address: address, gender: gender, yearbirth: yearbirth)
      self.key = key
      self.userId = userId
      self.tokenIOS = tokenIOS
      self.tokenAndroid = tokenAndroid
   }
   
   convenience init(item: UserItem) {
      self.init(key: item.key, userId: item.userId, name: item.username, email: item.email, address: item.address, gender: Gender(rawValue: item.gender), yearbirth: item.yearbirth, tokenIOS: item.tokenIOS, tokenAndroid: item.tokenAndroid)
   }
   
   func copy(_ rhs: UserModel) {
      self.key = rhs.key
      self.userId = rhs.userId
      self.name = rhs.name
      self.email = rhs.email
      self.address = rhs.address
      self._gender = rhs._gender
      self.yearbirth = rhs.yearbirth
      self.tokenIOS = rhs.tokenIOS
      self.tokenAndroid = rhs.tokenAndroid
   }
   
   @discardableResult
   class func createRealm(model: UserModel) -> Observable<UserModel> {
      let result = FetchingWorker.withRealm("creating") { realm -> Observable<UserModel> in
         try realm.write {
            realm.add(model)
         }
         return .just(model)
      }
      return result ?? .error(EmiaServiceError.creationFailed)
   }
}

extension UserModel: IdentifiableType {
   typealias Identity = String
   
   var identity : Identity {
      return userId
   }
}

extension UserModel {
   
   func synchronize(completion: @escaping (Bool) -> Void) {
      let userItem = UserItem(user: self)
      userItem.synchronize(completion: completion)
   }
}

func == (lhs: UserModel, rhs: UserModel) -> Bool {
   return lhs.key == rhs.key
}
