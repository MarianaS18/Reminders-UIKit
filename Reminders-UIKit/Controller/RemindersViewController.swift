import UIKit
import CoreData

class RemindersViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  var list: List?
  var context: NSManagedObjectContext?
  
  private lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    let predicate = NSPredicate(format: "%K == %@", "list.title", self.list!.title)
    fetchRequest.predicate = predicate
    
    let frc = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.context!,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    
    frc.delegate = self
    return frc
  }()
  
  lazy var dataSource: UITableViewDiffableDataSource<String, NSManagedObjectID> = {
    let dataSource = UITableViewDiffableDataSource<String, NSManagedObjectID>(tableView: tableView) {
      (tableView, indexPath, objectId) -> UITableViewCell? in
      guard let reminder = try? self.context?.existingObject(with: objectId) as? Reminder else { return nil }
      
      let cell = UITableViewCell(style: .default, reuseIdentifier: "ReminderCell")
      cell.textLabel?.text = reminder.title
      return cell
    }
    
    tableView.dataSource = dataSource
    return dataSource
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Core Data fetch error")
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    let remindersSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
    dataSource.apply(remindersSnapshot)
  }
}

extension RemindersViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "addNewReminder": handleAddNewReminderSegue(segue)
    default:
      return
    }
  }
}

// MARK: - Setup Code -
extension RemindersViewController {
  private func handleAddNewReminderSegue(_ segue: UIStoryboardSegue) {
    guard let newReminderViewController = (segue.destination as? UINavigationController)?.topViewController as? NewReminderViewController else {
      return
    }
    
    newReminderViewController.context = self.context
    newReminderViewController.list = self.list
  }
}

// MARK: - Table View -
extension RemindersViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
