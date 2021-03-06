//
//  NewPostViewController.swift
//  eMia
//

import UIKit
import IQKeyboardManagerSwift

class NewPostViewController: UIViewController {
   
   var presenter: NewPostPresenting!
   
   @IBOutlet weak var saveButton: UIButton!
   @IBOutlet weak var tableView: UITableView!
   @IBOutlet weak var fakeTextField: UITextField!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      NewPostDependencies.configure(view: self, tableView: tableView, fakeTextField: fakeTextField)
      
      navigationItem.title = presenter.title
      configureView()
   }
   
   private func configureView() {
      configure(tableView)
      configure(saveButton)
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case tableView:
         tableView.rowHeight = UITableViewAutomaticDimension
         tableView.estimatedRowHeight = 140
         tableView.delegate = self
         tableView.dataSource = self
      case saveButton:
         saveButton.setAsCircle()
         saveButton.backgroundColor = GlobalColors.kBrandNavBarColor
      default:
         break
      }
   }
   
   @IBAction func backButtonPressed(_ sender: Any) {
      close()
   }
   
   @IBAction func saveButtonPressed(_ sender: Any) {
      presenter.save { [weak self] in
         guard let `self` = self else { return }
         self.close()
      }
   }
   
   private func close() {
      self.navigationController?.popViewController(animated: true)
   }
}

// MARK: - TableView delegate protocol implementation

extension NewPostViewController: UITableViewDelegate, UITableViewDataSource {
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return presenter.numberOfRows
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return presenter.heightCell(for: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return presenter.cell(for: indexPath)
   }
}
