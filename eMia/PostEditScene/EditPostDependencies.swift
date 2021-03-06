//
//  EditPostDependencies.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class EditPostDependencies: NSObject {

   static func configure(view: EditPostViewController, post: PostModel, tableView: UITableView, activityIndicator: NVActivityIndicatorView, tableViewHeight: NSLayoutConstraint) {
      let keyboardController = KeyboardController()
      let fakeField = FakeFieldController()

      let presenter = EditPostPresenter()
      presenter.keyboardController = keyboardController
      presenter.post = post
      presenter.activityIndicator = activityIndicator
      presenter.tableView = tableView
      presenter.fakeField = fakeField
      presenter.view = view.view
      presenter.tvHeightConstraint = tableViewHeight
      
      view.presenter = presenter
   }
}
