import UIKit

// MARK: - SelectTableViewCell
/// Table view cell for displaying selectable items in the dropdown
public class SelectTableViewCell: UITableViewCell {
    private let checkmarkImageView = UIImageView()
    private let radioImageView = UIImageView()
    private let titleLabel = UILabel()
    private let colorView = UIView()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        selectionStyle = .none

        colorView.layer.cornerRadius = 4
        colorView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        checkmarkImageView.image = UIImage(systemName: "checkmark")
        checkmarkImageView.tintColor = .systemBlue
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.isHidden = true

        radioImageView.tintColor = .systemBlue
        radioImageView.translatesAutoresizingMaskIntoConstraints = false
        radioImageView.isHidden = true

        contentView.addSubview(colorView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(radioImageView)

        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 8),
            colorView.heightAnchor.constraint(equalToConstant: 8),

            titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),

            radioImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            radioImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            radioImageView.widthAnchor.constraint(equalToConstant: 20),
            radioImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    /// Configure the cell with a selectable item
    /// - Parameters:
    ///   - item: The item to display
    ///   - isSelected: Whether the item is currently selected
    ///   - selectionMode: The selection mode (single or multiple)
    public func configure<T: SelectableItem>(with item: T, isSelected: Bool, selectionMode: SelectionMode) {
        titleLabel.text = item.title

        if let color = item.color {
            colorView.backgroundColor = color
            colorView.isHidden = false
        } else {
            colorView.isHidden = true
        }

        switch selectionMode {
        case .single:
            checkmarkImageView.isHidden = true
            radioImageView.isHidden = false
            radioImageView.image = UIImage(systemName: isSelected ? "largecircle.fill.circle" : "circle")
        case .multiple:
            radioImageView.isHidden = true
            checkmarkImageView.isHidden = !isSelected
        }
    }
}
