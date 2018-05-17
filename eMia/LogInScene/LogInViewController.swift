//
//  LogInViewController.swift
//  eMia
//

import UIKit
import RxSwift
import RxCocoa

import NVActivityIndicatorView

class LogInViewController: UIViewController {
   
   var eventHandler: LoginPresenter!
   var presenter: LoginPresenter!
   let disposeBug = DisposeBag()
   
   @IBOutlet weak var emailTextField: UITextField!
   @IBOutlet weak var passwordTextField: UITextField!

   @IBOutlet weak var signInButton: UIButton!
   @IBOutlet weak var signUpButton: UIButton!

   @IBOutlet var activityIndicatorView: NVActivityIndicatorView!

   override func viewDidLoad() {
      super.viewDidLoad()
      
      navigationItem.title = "Log In to ".localized + "\(AppConstants.ApplicationName)"
      LoginDependencies.configure(viewController: self)
      
      subscribeOnVald()
      configureView()
   }

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      eventHandler.prepare(for: segue, sender: sender)
   }
   
   private func configureView() {
      configure(signInButton)
      configure(signUpButton)
      configure(emailTextField)
      configure(passwordTextField)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case emailTextField:
         _ = emailTextField.rx.text.map { $0 ?? "" }
            .bind(to: presenter.email)
      case passwordTextField:
         _ = passwordTextField.rx.text.map {$0 ?? "" }
            .bind(to: presenter.password)
      case signInButton:
         signInButton.isEnabled = false
         signInButton.setTitle("Sign In".localized, for: .normal)
         signInButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
         signInButton.rx.tap.bind(onNext: { [weak self] in
            self?.signInButtonPressed()
         }).disposed(by: disposeBug)
      case signUpButton:
         signUpButton.isEnabled = false
         signUpButton.setTitle("Sign Up".localized, for: .normal)
         signUpButton.setTitleColor(GlobalColors.kBrandNavBarColor, for: .normal)
         signUpButton.rx.tap.bind(onNext: { [weak self] in
            self?.signUpButtonPressed()
         }).disposed(by: disposeBug)
      default:
         break
      }
   }

   private func subscribeOnVald() {
      _ = presenter.isValid.bind(to: signInButton.rx.isEnabled)
      _ = presenter.isValid.subscribe(onNext: {[unowned self] isValid in
         self.signInButton.isEnabled = isValid ? true : false
         self.signInButton.setTitleColor(isValid ? UIColor.green : UIColor.lightGray, for: .normal)
         self.signUpButton.isEnabled = isValid ? true : false
         self.signUpButton.setTitleColor(isValid ? UIColor.green : UIColor.lightGray, for: .normal)
      })
   }
   
   private func signInButtonPressed() {
      self.hideKeyboard()
      eventHandler.signIn() { error in
         guard let error = error else {
            return
         }
         switch error {
         case .emailIsAbsent:
            break
         case .emailIsWrong:
            self.emailTextField.shake()
         case .passwordIsWrong:
            Alert.default.showOk("", message: error.description)
         case .accessDenied:
            self.emailTextField.shake()
         }
      }
   }
   
   private func signUpButtonPressed() {
      self.hideKeyboard()
      eventHandler.signUp() { error in
         guard let error = error else {
            return
         }
         switch error {
         case .emailIsAbsent:
            Alert.default.showOk("", message: error.description)
         case .emailIsWrong:
            break
         case .passwordIsWrong:
            Alert.default.showOk("", message: error.description)
         case .accessDenied:
            break
         }
      }
   }
}

// MARK: - View Protocol

extension LogInViewController {
   
   func startProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.startAnimating()
      }
   }
   
   func stopProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.stopAnimating()
      }
   }
}

extension LogInViewController: UITextFieldDelegate {

   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if textField == emailTextField {
         passwordTextField.becomeFirstResponder()
      } else {
         self.hideKeyboard()
      }
      return false
   }
   
   private func hideKeyboard() {
      DispatchQueue.main.async {
         self.view.endEditing(true)
      }
   }
   
}
