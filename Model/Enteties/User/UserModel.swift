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
   @objc dynamic var address: String?
   @objc dynamic var mGender: Int = 0
   @objc dynamic var yearbirth: Int = 0
   @objc dynamic var tokenIOS: String?
   @objc dynamic var tokenAndroid: String?

   static var rxUsers = BehaviorSubject<[UserModel]>(value: [])
   
   override class func primaryKey() -> String? {
      return "userId"
   }
   
   var gender: Gender? {
      get {
         return Gender(rawValue: self.mGender)
      }
      set {
         self.mGender = newValue?.rawValue ?? 0
      }
   }
   
   convenience init(name: String, email: String, address: String?, gender: Gender?, yearbirth: Int?) {
      self.init()
      self.name = name
      self.email = email
      self.address = address
      self.mGender = gender == nil ? Gender.both.rawValue : gender!.rawValue
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
      key = rhs.key
      userId = rhs.userId
      name = rhs.name
      email = rhs.email
      address = rhs.address
      mGender = rhs.mGender
      yearbirth = rhs.yearbirth
      tokenIOS = rhs.tokenIOS
      tokenAndroid = rhs.tokenAndroid
   }
   
   class var users: [UserModel] {
      do {
         let realm = try Realm()
         let users = realm.objects(UserModel.self)
         return users.toArray()
      } catch _ {
         return []
      }
   }
}

extension UserModel {

   class func addUser(_ item: UserItem) {
      let model = UserModel(item: item)
      if usersIndex(of: model) != nil {
         return
      }
      if model.userId.isEmpty == false {
         _ = Realm.createRealm(model: model)
         try? rxUsers.onNext(rxUsers.value() + [model])
      }
   }
   
   class func deleteUser(_ item: UserItem) {
      let model = UserModel(item: item)
      if let index = usersIndex(of: model) {
         let model = UserModel.users[index]
         Realm.deleteRealm(model: model)
         do {
            var array = try rxUsers.value()
            array.remove(at: index)
            rxUsers.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func editUser(_  item: UserItem) {
      let model = UserModel(item: item)
      if let index = usersIndex(of: model) {
         do {
            var array = try rxUsers.value()
            array[index] = model
            rxUsers.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func usersIndex(of item: UserModel) -> Int? {
      return UserModel.users.index(where: {$0 == item})
   }
   
}

extension UserModel: IdentifiableType {
   typealias Identity = String
   
   var identity: Identity {
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
