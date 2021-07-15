import UIKit

final class ReminderCell: UITableViewCell {
  static let reuseIdentifier = String(describing: ReminderCell.self)
  
  func configure(with reminder: Reminder) {
    self.textLabel?.text = reminder.title
  }
}

