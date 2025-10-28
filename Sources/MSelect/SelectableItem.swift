import UIKit

// MARK: - SelectableItem Protocol
/// Protocol that defines requirements for items that can be used with the Select component
public protocol SelectableItem {
    /// Unique identifier for the item
    var id: String { get }
    /// Display title for the item
    var title: String { get }
    /// Color associated with the item (optional)
    var color: UIColor? { get }
}
