//
//  CommentModel.swift
//  eMia
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxRealm

final class CommentModel: Object {
   
   @objc dynamic var key: String?
   @objc dynamic var id: String?
   
   @objc dynamic var uid: String = ""
   @objc dynamic var author: String = ""
   @objc dynamic var text: String = ""
   @objc dynamic var postid: String = ""
   @objc dynamic var created: Double = 0

   static var rxComments = BehaviorSubject<[CommentModel]>(value: [])
   static var rxNewCommentObserved = BehaviorSubject<CommentModel?>(value: nil)

   override class func primaryKey() -> String? {
      return "id"
   }
   
   convenience init(uid: String, author: String, text: String, postid: String, created: Double? = nil, key: String? = nil, id: String? = nil) {
      self.init()
      self.key = key
      self.id = id
      self.uid = uid
      self.author = author
      self.text = text
      self.postid = postid
      self.created = created ?? Date().timeIntervalSince1970
   }
   
   convenience init(item: CommentItem) {
      self.init(uid: item.uid, author: item.author, text: item.text, postid: item.postid, created: item.created, key: item.key, id: item.id)
   }

   class var comments: [CommentModel] {
      do {
         let realm = try Realm()
         let comms = realm.objects(CommentModel.self)
         return comms.toArray().sorted(by: {$0.created > $1.created})
      } catch _ {
         return []
      }
   }
   
   func copy(_ rhs: CommentModel) {
      key = rhs.key
      id = rhs.id
      uid = rhs.uid
      author = rhs.author
      text = rhs.text
      postid = rhs.postid
      created = rhs.created
   }
   
   @discardableResult
   class func createRealm(model: CommentModel) -> Observable<CommentModel> {
      let result = DataBaseImpl.withRealm("creating") { realm -> Observable<CommentModel> in
         try realm.write {
            realm.add(model)
         }
         return .just(model)
      }
      return result ?? .error(PostServiceError.creationFailed)
   }
   
   class func deleteRealm(model: CommentModel) {
      _ = DataBaseImpl.withRealm("deleting") { realm in
         try realm.write {
            realm.delete(model)
         }
      }
   }
}

extension CommentModel {
   
   class func addComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if commentIndex(of: model) != nil {
         return
      }
      if !item.id.isEmpty {
         _ = CommentModel.createRealm(model: model)
         try? rxComments.onNext(rxComments.value() + [model])
         // TODO: Remove it
         rxNewCommentObserved.onNext(model)
      }
   }
   
   class func deleteComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if let index = commentIndex(of: model) {
         let model = comments[index]
         deleteRealm(model: model)
         do {
            var array = try rxComments.value()
            array.remove(at: index)
            rxComments.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func editComment(_  item: CommentItem) {
      let model = CommentModel(item: item)
      if let index = commentIndex(of: model) {
         //_ = CommentModel.createRealm(model: model)
         do {
            var array = try rxComments.value()
            array[index] = model
            rxComments.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func commentIndex(of model: CommentModel) -> Int? {
      let index = comments.index(where: {$0 == model})
      return index
   }
}

extension CommentModel: IdentifiableType {
   typealias Identity = String
   
   var identity: Identity {
      return id ?? ""
   }
}

extension CommentModel {
   
   func synchronize(_ completion: @escaping (Bool) -> Void) {
      let commentItem = CommentItem(uid: self.uid, author: self.author, text: self.text, postid: self.postid, created: self.created)
      commentItem.key = key ?? ""
      commentItem.id = id ?? ""
      commentItem.synchronize(completion: completion)
   }
}

func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
   return lhs.id == rhs.id
}
