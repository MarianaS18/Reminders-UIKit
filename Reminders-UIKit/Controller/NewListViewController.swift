import UIKit
import CoreData

final class NewListViewController: UIViewController {
  @IBOutlet weak var doneButton: UIBarButtonItem!
  @IBOutlet weak var textField: UITextField!
  
  var context: NSManagedObjectContext?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func done(_ sender: Any) {
    guard let title = textField.text else { return }
    guard let context = self.context else { return }
    
    let newList = List(context: context)
    newList.title = title
    
    do {
      try context.save()
      dismiss(animated: true, completion: nil)
    } catch {
      fatalError("Core Data save error")
    }
  }
  
  @IBAction func cancel(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
}

extension NewListViewController: UITextFieldDelegate {
  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    guard let text = textField.text else { return true }
    let length = text.count - range.length + string.count
    
    if length > 0 {
      doneButton.isEnabled = true
    } else {
      doneButton.isEnabled = false
    }
    
    return true
  }
}
