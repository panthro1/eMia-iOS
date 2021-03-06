//
//  EditPost5ViewCell.swift
//  eMia
//

import UIKit

// Comment table item

class EditPost5ViewCell: UITableViewCell, ForPostConfigurable {

   @IBOutlet weak var avatarBackgroundView: UIView!
   @IBOutlet weak var avatarImageView: UIImageView!
   @IBOutlet weak var titleLabel: UILabel!
   @IBOutlet weak var bodyLabel: UILabel!
   @IBOutlet weak var createdLabel: UILabel!
   
   override func awakeFromNib() {
      avatarBackgroundView.setAsCircle()
   }

   func configureView(for post: PostModel) -> CGFloat {
      return -1.0
   }

   override func prepareForReuse() {
      self.avatarImageView.image = nil
   }
   
   func configureView(for comment: CommentModel) {
      gPhotosManager.downloadAvatar(for: comment.uid) { image in
         self.avatarImageView.image = image
      }
      if let user = gUsersManager.getUserWith(id: comment.uid) {
         self.titleLabel.text = user.name
      } else {
         self.titleLabel.text = nil
      }
      self.bodyLabel.text = comment.text
      self.createdLabel.text = "Created".localized + " " + comment.relativeTimeToCreated()
   }
}
