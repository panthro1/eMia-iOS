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
      self.key = rhs.key
      self.userId = rhs.userId
      self.name = rhs.name
      self.email = rhs.email
      self.address = rhs.address
      self.mGender = rhs.mGender
      self.yearbirth = rhs.yearbirth
      self.tokenIOS = rhs.tokenIOS
      self.tokenAndroid = rhs.tokenAndroid
   }
   
   @discardableResult
   class func createRealm(model: UserModel) -> Observable<UserModel> {
      let result = DataBaseImpl.withRealm("creating") { realm -> Observable<UserModel> in
         try realm.write {
            realm.add(model)
         }
         return .just(model)
      }
      return result ?? .error(PostServiceError.creationFailed)
   }
   
   @discardableResult
   class func deleteRealm(model: UserModel) -> Observable<Void> {
      let result = DataBaseImpl.withRealm("deleting") { realm-> Observable<Void> in
         try realm.write {
            realm.delete(model)
         }
         return .empty()
      }
      return result ?? .error(PostServiceError.deletionUserFailed(model))
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
         _ = UserModel.createRealm(model: model)
         try? rxUsers.onNext(rxUsers.value() + [model])
      }
   }
   
   class func deleteUser(_ item: UserItem) {
      let model = UserModel(item: item)
      if let index = usersIndex(of: model) {
         let model = UserModel.users[index]
         deleteRealm(model: model)
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
         // If the user alteady exists, it's replacing him
         //_ = UserModel.createRealm(model: model)
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
