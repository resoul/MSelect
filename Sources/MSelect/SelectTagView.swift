import UIKit

// MARK: - SelectTagView
/// Visual representation of a selected item in multiple selection mode
public class SelectTagView: UIView {
    private let titleLabel = UILabel()
    private let removeButton = UIButton(type: .system)

    /// Callback triggered when remove button is tapped
    public var onRemove: (() -> Void)?

    /// Initialize with a selectable item
    /// - Parameter item: The item to display
    public init<T: SelectableItem>(item: T) {
        super.init(frame: .zero)
        setupView(with: item)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView<T: SelectableItem>(with item: T) {
        let itemColor = item.color ?? .systemBlue

        backgroundColor = itemColor.withAlphaComponent(0.2)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = itemColor.cgColor

        titleLabel.text = item.title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = itemColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        removeButton.setTitle("×", for: .normal)
        removeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        removeButton.tintColor = itemColor
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)

        addSubview(titleLabel)
        addSubview(removeButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            removeButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            removeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            removeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 20),
            removeButton.heightAnchor.constraint(equalToConstant: 20),

            heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    @objc private func removeButtonTapped() {
        onRemove?()
    }
}
