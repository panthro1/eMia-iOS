//
//  ReachabilityController.swift
//  eMia
//

import UIKit
import RxSwift
import SwiftyNotifications

internal let Network = ReachabilityController.sharedInstance

class ReachabilityController: NSObject {

   static let sharedInstance: ReachabilityController = {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      return appDelegate.reachabilityController
   }()
   
   private var mReachable: Bool = true
   private let disposeBag = DisposeBag()
   
   fileprivate var reachabilityNotificatin: SwiftyNotifications? = nil
	internal var observers = [Any]()
   
   override init() {
      super.init()
      registerObserver()
   }
   
   deinit {
      unregisterObserver()
   }
   
   func error(_ needAlert: Bool = true) -> Error? {
      if reachable == true {
         return nil
      }
      if needAlert {
         Alert.default.showOk("Make sure your phone has an Internet connection".localized, message: "Please try again later".localized)
      }
      let error = NSError(domain: "Internet is disconnected".localized, code: 440, userInfo: nil)
      return error
   }
   
   var reachable: Bool {
      return mReachable
   }
   
   func startMonitoringReachability() {
      
      self.reachabilityNotificatin?.dismiss()
      self.reachabilityNotificatin?.removeFromSuperview()
      self.reachabilityNotificatin = nil
      
      _ = Reactive.reachable.subscribe({ reacheble in
         guard let isReacheble = reacheble.event.element else {
            return
         }
         self.mReachable = isReacheble
         self.reachabilityChanged(to: isReacheble)
      }).disposed(by: disposeBag)
   }
   
   private func reachabilityChanged(to isReachable: Bool) {
      
      if isReachable {
         if reachabilityNotificatin != nil {
            DispatchQueue.main.async { [unowned self] in
               self.reachabilityNotificatin?.dismiss()
               self.reachabilityNotificatin?.removeFromSuperview()
               self.reachabilityNotificatin = nil
            }
            
         }
      } else {

         print("Network not reachable")
         
         DispatchQueue.main.async {
            
            if let window = AppDelegate.shared.window {
               
               self.reachabilityNotificatin?.dismiss()
               
               let notification = SwiftyNotifications.withStyle(style: .warning,
                                                                title: "Internet".localized,
                                                                subtitle: "connection lost".localized, direction: .bottom)
               window.addSubview(notification)
               notification.show()
               
               self.reachabilityNotificatin = notification
               
            }
         }
      }
   }
   
}

// MARK: - Observable

extension ReachabilityController: AnyObservable {
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      
      observers.append(
         center.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: queue) { [weak self] _ in
            guard let `self` = self else {
               return
            }
            self.startMonitoringReachability()
         }
      )
   }
   
   func unregisterObserver() {
      observers.forEach {
         NotificationCenter.default.removeObserver($0)
      }
      observers.removeAll()
   }
}