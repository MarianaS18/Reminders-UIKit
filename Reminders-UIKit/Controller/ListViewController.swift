import UIKit
import CoreData

class ListViewController: UITableViewController, NSFetchedResultsControllerDelegate {
  var context: NSManagedObjectContext?
  
  private lazy var fetchResultsController: NSFetchedResultsController<List> = {
    let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
    fetchRequest.fetchLimit = 20
    
    let sortDescriptor = NSSortDescriptor(key: "title", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    let frc = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.context!,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    
    frc.delegate = self
    return frc
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    
    do {
      try fetchResultsController.performFetch()
    } catch {
      fatalError("Core Data fetch error")
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showDetail":
      if let controller = (segue.destination as? UINavigationController)?.topViewController as? RemindersViewController {
        handleShowDetailSegue(remindersViewController: controller)
      }
    case "addNewList":
      if let controller = (segue.destination as? UINavigationController)?.topViewController as? NewListViewController {
        handleAddNewListSegue(newListViewController: controller)
      }
    default: return
    }
  }
  
  // MARK: - Fetched Results Controller Delegate -
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    guard let list = anObject as? List else { return }
    
    switch type {
    case .insert:
      guard let newIndexPath = newIndexPath else { return }
      tableView.insertRows(at: [newIndexPath], with: .fade)
    case .delete:
      guard let indexPath = indexPath else { return }
      tableView.deleteRows(at: [indexPath], with: .fade)
    case .update:
      guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) else { return }
      cell.textLabel?.text = list.title
    case .move:
      guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
      tableView.moveRow(at: indexPath, to: newIndexPath)
    default: return
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}

extension ListViewController {
  private func setupViews() {
    navigationItem.leftBarButtonItem = editButtonItem
  }
  
  private func handleShowDetailSegue(remindersViewController: RemindersViewController) {
    guard let indexPath = tableView.indexPathForSelectedRow else {
      return
    }
    
    remindersViewController.context = self.context
    
    let list = fetchResultsController.object(at: indexPath)
    remindersViewController.list = list
  }
  
  private func handleAddNewListSegue(newListViewController: NewListViewController) {
    newListViewController.context = self.context
  }
}

// MARK: - Table View -
extension ListViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchResultsController.sections?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sectionInfo = fetchResultsController.sections?[section] else { return 0 }
    return sectionInfo.numberOfObjects
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
    let list = fetchResultsController.object(at: indexPath)
    cell.textLabel?.text = list.title
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let list = fetchResultsController.object(at: indexPath)
      context?.delete(list)
      
      try? context?.save()
    }
  }
}
