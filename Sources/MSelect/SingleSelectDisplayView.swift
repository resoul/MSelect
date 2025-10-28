import UIKit

// MARK: - SingleSelectDisplayView
/// Display view for single selection mode showing the selected item
public class SingleSelectDisplayView: UIView {
    private let colorView = UIView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()

    public init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemGray6
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor

        colorView.layer.cornerRadius = 4
        colorView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label
        titleLabel.text = "Select Item"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        chevronImageView.image = UIImage(systemName: "chevron.down")
        chevronImageView.tintColor = .systemGray
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(colorView)
        addSubview(titleLabel)
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 8),
            colorView.heightAnchor.constraint(equalToConstant: 8),

            titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16),

            heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    /// Configure the view with a selectable item
    /// - Parameter item: The item to display, or nil to show placeholder
    public func configure<T: SelectableItem>(with item: T?) {
        if let item = item {
            titleLabel.text = item.title
            if let color = item.color {
                colorView.backgroundColor = color
                colorView.isHidden = false
            } else {
                colorView.isHidden = true
            }
        } else {
            titleLabel.text = "Select Item"
            colorView.isHidden = true
        }
    }

    /// Update the chevron icon based on dropdown state
    /// - Parameter isOpen: Whether the dropdown is open
    public func setDropdownState(_ isOpen: Bool) {
        let imageName = isOpen ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(systemName: imageName)
    }

    /// Update placeholder text
    /// - Parameter text: The placeholder text to display
    public func setPlaceholder(_ text: String) {
        if titleLabel.text == "Select Item" {
            titleLabel.text = text
        }
    }
}
