import UIKit

// MARK: - SelectView
/// Main selection component that supports both single and multiple selection modes
public class SelectView<T: SelectableItem>: UIView, UITableViewDataSource, UITableViewDelegate {
    private let containerStackView = UIStackView()
    private let headerStackView = UIStackView()
    private let tagsStackView = UIStackView()
    private let singleDisplayView = SingleSelectDisplayView()
    private let dropdownTableView = UITableView()
    private let backgroundOverlay = UIView()

    private var allItems: [T] = []
    private var selectedItems: [T] = []
    private var isDropdownVisible = false

    // MARK: - Configuration Properties

    /// The selection mode (single or multiple)
    public var selectionMode: SelectionMode = .single {
        didSet {
            updateDisplayMode()
        }
    }

    /// Placeholder text shown when no item is selected
    public var placeholder: String = "Select Item" {
        didSet {
            updatePlaceholder()
        }
    }

    /// Maximum height for the dropdown list
    public var maxDropdownHeight: CGFloat = 300

    /// Number of tags per row in multiple selection mode
    public var tagsPerRow: Int = 3

    // MARK: - Callbacks

    /// Called when selection changes in multiple selection mode
    public var onSelectionChanged: (([T]) -> Void)?

    /// Called when selection changes in single selection mode
    public var onSingleSelectionChanged: ((T?) -> Void)?

    // MARK: - Initialization

    /// Initialize with items
    /// - Parameter items: Array of selectable items
    public init(items: [T]) {
        super.init(frame: .zero)
        self.allItems = items
        setupView()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor

        setupContainerStackView()
        setupSingleDisplayView()
        setupTagsStackView()
        setupDropdownTableView()
        setupBackgroundOverlay()
        updateDisplayMode()
    }

    private func setupContainerStackView() {
        containerStackView.axis = .vertical
        containerStackView.spacing = 12
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerStackView)

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    private func setupSingleDisplayView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        singleDisplayView.addGestureRecognizer(tapGesture)
        singleDisplayView.isUserInteractionEnabled = true
    }

    private func setupTagsStackView() {
        tagsStackView.axis = .vertical
        tagsStackView.spacing = 8
    }

    private func setupBackgroundOverlay() {
        backgroundOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backgroundOverlay.alpha = 0
        backgroundOverlay.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundOverlay.addGestureRecognizer(tapGesture)
    }

    private func setupDropdownTableView() {
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.register(SelectTableViewCell.self, forCellReuseIdentifier: "SelectCell")
        dropdownTableView.layer.cornerRadius = 8
        dropdownTableView.layer.borderWidth = 1
        dropdownTableView.layer.borderColor = UIColor.systemGray4.cgColor
        dropdownTableView.backgroundColor = .systemBackground
        dropdownTableView.translatesAutoresizingMaskIntoConstraints = false
        dropdownTableView.isHidden = true
    }

    // MARK: - Display Mode Updates

    private func updateDisplayMode() {
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        switch selectionMode {
        case .single:
            containerStackView.addArrangedSubview(singleDisplayView)
            updateSingleDisplayView()
        case .multiple:
            setupMultipleHeader()
            containerStackView.addArrangedSubview(headerStackView)
            containerStackView.addArrangedSubview(tagsStackView)
            updateTagsView()
        }
    }

    private func setupMultipleHeader() {
        headerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        headerStackView.axis = .horizontal
        headerStackView.distribution = .fillProportionally
        headerStackView.alignment = .center

        let titleLabel = UILabel()
        titleLabel.text = placeholder
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.isUserInteractionEnabled = true

        let selectButton = UIButton(type: .system)
        selectButton.setTitle("▼", for: .normal)
        selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        selectButton.addTarget(self, action: #selector(toggleDropdown), for: .touchUpInside)
        selectButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            selectButton.widthAnchor.constraint(equalToConstant: 30),
            selectButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDropdown))
        titleLabel.addGestureRecognizer(titleTapGesture)

        headerStackView.addArrangedSubview(titleLabel)
        headerStackView.addArrangedSubview(selectButton)
    }

    private func updateSingleDisplayView() {
        let selectedItem = selectedItems.first
        singleDisplayView.configure(with: selectedItem)
        singleDisplayView.setDropdownState(isDropdownVisible)
    }

    private func updateTagsView() {
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if selectedItems.isEmpty {
            tagsStackView.isHidden = true
            return
        }

        tagsStackView.isHidden = false

        var currentRowStackView: UIStackView?

        for item in selectedItems {
            if currentRowStackView == nil {
                currentRowStackView = createRowStackView()
                tagsStackView.addArrangedSubview(currentRowStackView!)
            }

            let tagView = SelectTagView(item: item)
            tagView.onRemove = { [weak self] in
                self?.removeItem(item)
            }

            currentRowStackView!.addArrangedSubview(tagView)

            if currentRowStackView!.arrangedSubviews.count >= tagsPerRow {
                currentRowStackView = nil
            }
        }
    }

    private func createRowStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView
    }

    private func updatePlaceholder() {
        if selectionMode == .single {
            singleDisplayView.setPlaceholder(placeholder)
        } else {
            updateDisplayMode()
        }
    }

    // MARK: - Item Management

    private func removeItem(_ item: T) {
        selectedItems.removeAll { $0.id == item.id }
        updateTagsView()
        dropdownTableView.reloadData()
        notifySelectionChanged()
    }

    private func notifySelectionChanged() {
        switch selectionMode {
        case .single:
            onSingleSelectionChanged?(selectedItems.first)
        case .multiple:
            onSelectionChanged?(selectedItems)
        }
    }

    // MARK: - Public Methods

    /// Set the available items for selection
    /// - Parameter items: Array of selectable items
    public func setItems(_ items: [T]) {
        allItems = items
        dropdownTableView.reloadData()
    }

    /// Set multiple selected items (for multiple selection mode)
    /// - Parameter items: Array of items to select
    public func setSelectedItems(_ items: [T]) {
        selectedItems = items
        updateDisplayMode()
        dropdownTableView.reloadData()
    }

    /// Set single selected item (for single selection mode)
    /// - Parameter item: The item to select, or nil to clear selection
    public func setSelectedItem(_ item: T?) {
        if let item = item {
            selectedItems = [item]
        } else {
            selectedItems = []
        }
        updateDisplayMode()
        dropdownTableView.reloadData()
    }

    /// Get currently selected items
    /// - Returns: Array of selected items
    public func getSelectedItems() -> [T] {
        return selectedItems
    }

    /// Get currently selected item (for single selection mode)
    /// - Returns: The selected item or nil
    public func getSelectedItem() -> T? {
        return selectedItems.first
    }

    /// Clear all selections
    public func clearSelection() {
        selectedItems = []
        updateDisplayMode()
        dropdownTableView.reloadData()
        notifySelectionChanged()
    }

    // MARK: - Dropdown Management

    @objc private func toggleDropdown() {
        if isDropdownVisible {
            hideDropdown()
        } else {
            showDropdown()
        }
    }

    @objc private func backgroundTapped() {
        hideDropdown()
    }

    private func showDropdown() {
        guard let window = self.window else { return }

        isDropdownVisible = true

        if selectionMode == .single {
            singleDisplayView.setDropdownState(true)
        } else {
            if let selectButton = headerStackView.arrangedSubviews.last as? UIButton {
                selectButton.setTitle("▲", for: .normal)
            }
        }

        backgroundOverlay.frame = window.bounds
        backgroundOverlay.isHidden = false
        window.addSubview(backgroundOverlay)

        let globalFrame = self.convert(self.bounds, to: window)
        dropdownTableView.frame = CGRect(
            x: globalFrame.origin.x,
            y: globalFrame.maxY + 4,
            width: globalFrame.width,
            height: min(maxDropdownHeight, CGFloat(allItems.count * 50))
        )

        dropdownTableView.isHidden = false
        window.addSubview(dropdownTableView)

        UIView.animate(withDuration: 0.2) {
            self.backgroundOverlay.alpha = 1
        }
    }

    private func hideDropdown() {
        isDropdownVisible = false

        if selectionMode == .single {
            singleDisplayView.setDropdownState(false)
        } else {
            if let selectButton = headerStackView.arrangedSubviews.last as? UIButton {
                selectButton.setTitle("▼", for: .normal)
            }
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundOverlay.alpha = 0
        }) { _ in
            self.backgroundOverlay.isHidden = true
            self.backgroundOverlay.removeFromSuperview()
            self.dropdownTableView.isHidden = true
            self.dropdownTableView.removeFromSuperview()
        }
    }

    // MARK: - TableView DataSource & Delegate
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCell", for: indexPath) as! SelectTableViewCell
        let item = allItems[indexPath.row]
        let isSelected = selectedItems.contains { $0.id == item.id }
        cell.configure(with: item, isSelected: isSelected, selectionMode: selectionMode)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = allItems[indexPath.row]

        switch selectionMode {
        case .single:
            selectedItems = [item]
            updateSingleDisplayView()
            tableView.reloadData()
            hideDropdown()
        case .multiple:
            if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
                selectedItems.remove(at: index)
            } else {
                selectedItems.append(item)
            }
            updateTagsView()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        notifySelectionChanged()
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
