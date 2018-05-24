# SwipableCell

* A Reduser-based swipable cell
* support UITableView
* support ASTableNode from [Texture](https://github.com/TextureGroup/Texture)

### Requirements

- Swift 4.1, iOS 9

### Installation

- With Cocoapods:

```ruby
pod 'SwipableCell', '~> 0.1.2'
# Then, run the following command:
$ pod install
```

### Example

<img width="250" height="445" src="https://raw.githubusercontent.com/ChaselAn/SoapBubble/master/SoapBubble.gif"/>

### How to use

#### UITableView

* tableView

```swift
class DemoTableView: UITableView, SwipeTableViewCellDelegate {

    func swipe_tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath) -> [SwipedAction] {
        let deleteAction = SwipedAction(title: "delete") { (_) in
            // delete
        }
        deleteAction.needConfirm = .custom(title: "confirm delete?")
        let unreadAction = SwipedAction(title: "unread") { (_) in
        }
        unreadAction.backgroundColor = .gray

        if indexPath.row % 3 == 0 {
            deleteAction.preferredWidth = 100
        }

        if indexPath.row % 2 == 1 {
            return [unreadAction, deleteAction]
        } else {
            return [deleteAction]
        }
    }

    func swipe_tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
```

* cell

```swift
class DemoTableViewCell: SwipableCell {
	// do something
}
tableView.register(DemoTableViewCell.self, forCellReuseIdentifier: "DemoTableViewCell")
```

or

```swift
tableView.register(SwipableCell.self, forCellReuseIdentifier: "DemoTableViewCell")
```

#### ASTableNode

* tableNode

```swift
import AsyncDisplayKit
extension TestASTableView: ASTableNode, ASTableNodeSwipableDelegate {

    public func swipe_tableNode(_ tableNode: ASTableNode, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func swipe_tableNode(_ tableNode: ASTableNode, editActionsOptionsForRowAt indexPath: IndexPath) -> [SwipedAction] {

        guard let cell = tableNode.nodeForRow(at: indexPath) as? TextureDemoCellNode else { return [] }
        let deleteAction = SwipedAction(title: "delete", backgroundColor: #colorLiteral(red: 1, green: 0.01568627451, blue: 0.3450980392, alpha: 1), titleColor: UIColor.white, titleFont: UIFont.systemFont(ofSize: 17, weight: .medium), preferredWidth: nil, handler: { (_) in
            // delete
        })
        deleteAction.needConfirm = .custom(title: "confirm delete?")

        let markAction: SwipedAction

        let markAsRead = SwipedAction(title: "unread", handler: { (_) in
            cell.hideSwipe(animated: true)
        })
        markAction = markAsRead

        markAction.backgroundColor = #colorLiteral(red: 0.8117647059, green: 0.8117647059, blue: 0.8117647059, alpha: 1)
        markAction.titleFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        markAction.horizontalMargin = 24
        deleteAction.horizontalMargin = 24

        return [markAction, deleteAction]
    }
}
```

* cellNode

```swift
class TextureDemoCellNode: SwipableCellNode {

    override init(tableNode: ASTableNode) {
        super.init(tableNode: tableNode)

        // do something

    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        // layout
    }
}
extension TestASTableViewController: ASTableDataSource {

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = TextureDemoCellNode(tableNode: tableNode)
        return cell
    }
}
```

or

```swift
extension TestASTableViewController: ASTableDataSource {

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let cell = SwipableCellNode(tableNode: tableNode)
        return cell
    }
}
```

### Note

* The current version is temporarily dependent on [Texture](https://github.com/TextureGroup/Texture), and later versions will be stripped out. Use on demand.