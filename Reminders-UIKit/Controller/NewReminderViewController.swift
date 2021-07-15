import UIKit
import CoreData

final class NewReminderViewController: UITableViewController {
  @IBOutlet weak var titleTextField: UITextField!
  @IBOutlet weak var attachmentImageView: UIImageView!
  
  var context: NSManagedObjectContext?
  
  var list: List?
  var attachment: Data?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func dismissViewController(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func saveReminder(_ sender: Any) {
    guard let title = titleTextField.text else { return }
    guard let context = self.context else { return }
    guard let list = self.list else { return }
    
    let newReminder = Reminder(context: context)
    newReminder.title = title
    newReminder.list = list
    newReminder.attachment = attachment
    
    do {
      try context.save()
      dismiss(animated: true, completion: nil)
    } catch {
      fatalError("Core Data save data error")
    }
  }
}


extension NewReminderViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let attachmentsIndexPath = IndexPath(row: 0, section: 1)
    
    if indexPath == attachmentsIndexPath {
      let imagePickerController = UIImagePickerController()
      imagePickerController.delegate = self
      present(imagePickerController, animated: true, completion: nil)
    }
  }
}

extension NewReminderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    guard let image = info[.originalImage] as? UIImage else { return }
    self.attachmentImageView.image = image
    self.attachment = image.pngData()
    
    dismiss(animated: true, completion: nil)
  }
}

