import Foundation
import CoreData

extension List {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
    return NSFetchRequest<List>(entityName: "List")
  }
  
  @NSManaged public var title: String
  @NSManaged public var reminders: Set<Reminder>
}
