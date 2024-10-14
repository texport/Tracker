import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Properties
    private var trackerCategories: ([TrackerCategory], [UUID: Bool], [UUID: Int]) = ([], [:], [:])
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var trackerService: TrackerService?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.trackerService = appDelegate.trackerService
        }
        
        self.trackerService?.onTrackersUpdated = { [weak self] in
            guard let self = self else { return }
            self.loadTrackers(for: self.datePicker.date)  // Обновляем трекеры, когда они изменяются
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Elements

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.masksToBounds = true
        return searchBar
    }()

    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "star")
        imageView.tintColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 9

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        setupViews()
        setupConstraints()
        setupCollectionView()
        setupActivityIndicator()
        setupDismissKeyboardGesture()
        loadTrackers(for: Date())
    }

    // MARK: - Setup Methods

    private func setupViews() {
        view.backgroundColor = .white

        view.addSubview(topContainerView)
        topContainerView.addSubview(titleLabel)
        topContainerView.addSubview(searchBar)

        view.addSubview(collectionView)

        view.addSubview(placeholderView)
        placeholderView.addSubview(placeholderImageView)
        placeholderView.addSubview(placeholderLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top Container View
            topContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 1),
            titleLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),

            // Search Bar
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            topContainerView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),

            // Collection View
            collectionView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Placeholder View
            placeholderView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Placeholder Image
            placeholderImageView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),

            // Placeholder Label
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor)
        ])
    }

    private func setupNavigationBar() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(named: "pluse")?.withRenderingMode(.alwaysOriginal), for: .normal)
        addButton.addTarget(self, action: #selector(addTracker), for: .touchUpInside)

        let addButtonContainer = UIView()
        addButtonContainer.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: addButtonContainer.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: addButtonContainer.trailingAnchor),
            addButton.topAnchor.constraint(equalTo: addButtonContainer.topAnchor),
            addButton.bottomAnchor.constraint(equalTo: addButtonContainer.bottomAnchor)
        ])

        guard let navigationBar = navigationController?.navigationBar else {
            print("Navigation bar не найден")
            return
        }
        
        navigationBar.addSubview(addButtonContainer)
        addButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButtonContainer.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 6),
            addButtonContainer.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor)
        ])

        let datePickerContainer = UIBarButtonItem(customView: datePicker)
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
        navigationItem.rightBarButtonItem = datePickerContainer
    }

    private func setupActions() {
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        searchBar.delegate = self
        searchBar.showsCancelButton = false
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.identifier
        )
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Загрузка данных
    private func loadTrackers(for date: Date) {
        activityIndicator.startAnimating()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            // Загружаем трекеры и категории
            guard let (trackerCategories, completedTrackers, completedCount) = self.trackerService?.fetchTrackers(for: date) else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                return
            }

            var pinnedTrackers: [Tracker] = []
            var regularCategories: [TrackerCategory] = []

            // Разделение трекеров на закрепленные и обычные
            for category in trackerCategories {
                var unpinned = [Tracker]()
                for tracker in category.trackers {
                    if tracker.isPinned {
                        pinnedTrackers.append(tracker) // Собираем все закрепленные
                    } else {
                        unpinned.append(tracker) // Оставляем обычные
                    }
                }
                if !unpinned.isEmpty {
                    // Сортируем трекеры внутри каждой категории
                    let sortedTrackers = unpinned.sorted { $0.name < $1.name }
                    regularCategories.append(TrackerCategory(title: category.title, trackers: sortedTrackers))
                }
            }

            // Сортируем все обычные категории по алфавиту
            regularCategories.sort { $0.title < $1.title }

            // Создаем категорию "Закрепленные", если есть закрепленные трекеры
            if !pinnedTrackers.isEmpty {
                let sortedPinnedTrackers = pinnedTrackers.sorted { $0.name < $1.name }
                let pinnedCategory = TrackerCategory(title: "Закрепленные", trackers: sortedPinnedTrackers)
                regularCategories.insert(pinnedCategory, at: 0) // Вставляем первой
            }

            DispatchQueue.main.async {
                // Обновляем данные и перезагружаем коллекцию
                self.trackerCategories = (regularCategories, completedTrackers, completedCount)
                self.collectionView.reloadData()
                self.updatePlaceholderVisibility()
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func updatePlaceholderVisibility() {
        let hasTrackers = !trackerCategories.0.isEmpty
        placeholderView.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers

        if !hasTrackers {
            placeholderLabel.text = "Ничего не найдено"
            placeholderImageView.image = UIImage(resource: .search)
        } else {
            placeholderLabel.text = "Что будем отслеживать?"
        }
    }
    
    private func togglePin(for tracker: Tracker) {
        trackerService?.togglePin(for: tracker.id) { [weak self] success in
            guard success, let self = self else { return }
            self.loadTrackers(for: self.datePicker.date)
        }
    }

    private func deleteTracker(_ tracker: Tracker) {
        trackerService?.deleteTracker(tracker.id) { [weak self] success in
            guard success else { return }
            self?.loadTrackers(for: self?.datePicker.date ?? Date())
        }
    }

    private func showDeleteConfirmation(for tracker: Tracker) {
        let alertController = UIAlertController(
            title: nil,
            message: "Уверены что хотите удалить трекер?",
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Actions

    @objc private func addTracker() {
        let createTrackerVC = CreateTrackerTypeViewController()
        createTrackerVC.modalPresentationStyle = .pageSheet
        createTrackerVC.modalTransitionStyle = .coverVertical

        // Обновляем список трекеров после добавления нового
        createTrackerVC.onTrackerAdded = { [weak self] in
            self?.loadTrackers(for: self?.datePicker.date ?? Date())
        }

        let navigationController = UINavigationController(rootViewController: createTrackerVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        loadTrackers(for: sender.date)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerCategories.0.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackerCategories.0[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = trackerCategories.0[indexPath.section].trackers[indexPath.item]
        let completedCount = trackerCategories.2[tracker.id] ?? 0
        let isCompleted = trackerCategories.1[tracker.id] ?? false
        let isFutureDate = datePicker.date > Date()
        
        print("Статус трекера \(tracker.name): \(isCompleted ? "выполнен" : "невыполнен")")
        
        cell.configure(with: tracker, isCompleted: isCompleted, completedCount: completedCount, isFutureDate: isFutureDate)
        
        cell.didTogglePin = { [weak self] tracker in
            self?.togglePin(for: tracker)
        }

        cell.didEditTracker = { tracker in
            // Вызов редактирования трекера
        }

        cell.didDeleteTracker = { [weak self] tracker in
            self?.showDeleteConfirmation(for: tracker)
        }
        
        cell.didTapActionButton = { [weak self] in
            guard let self = self else { return }
            self.trackerService?.completeTracker(tracker, on: self.datePicker.date)
            self.loadTrackers(for: self.datePicker.date)
        }
        
        return cell
    }

    // Заголовок секции
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCategoryHeader.identifier,
                for: indexPath
            ) as? TrackerCategoryHeader else {
                return UICollectionReusableView()
            }
            let categoryTitle = trackerCategories.0[indexPath.section].title
            header.configure(with: categoryTitle)
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    // Размер ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace: CGFloat = 16 * 2 + 9
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = floor(availableWidth / 2)
        return CGSize(width: widthPerItem, height: 148)
    }

    // Размер заголовка секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 55)
    }

    // Отступы для секции
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }

    // Межстрочный интервал
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //return 0
        .zero
    }

    // Интервал между элементами в строке
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        //return 0
        .zero
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadTrackers(for: datePicker.date)  // Загружаем все трекеры, если поле пустое
            searchBar.setShowsCancelButton(false, animated: true)  // Скрываем кнопку отмены
        } else {
            searchTrackers(by: searchText)  // Выполняем поиск
            searchBar.setShowsCancelButton(true, animated: true)  // Показываем кнопку отмены
        }
    }

    private func searchTrackers(by name: String) {
        activityIndicator.startAnimating()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            let searchedCategories: [TrackerCategory] = self.trackerService?.searchTrackers(by: name) ?? []

            DispatchQueue.main.async {
                if searchedCategories.isEmpty {
                    self.trackerCategories = ([], [:], [:])
                } else {
                    self.trackerCategories = (searchedCategories, [:], [:])
                }
                
                self.collectionView.reloadData()
                self.updatePlaceholderVisibility()
                self.activityIndicator.stopAnimating()
            }
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)  // Показываем кнопку отмены при фокусе
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        loadTrackers(for: datePicker.date)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Array {
    /// Безопасный доступ к элементу массива по индексу.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
