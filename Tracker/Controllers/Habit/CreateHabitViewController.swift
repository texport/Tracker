import UIKit

final class CreateHabitViewController: UIViewController, UITextViewDelegate, ScheduleViewControllerDelegate {

    init(tracker: Tracker? = nil, category: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось получить AppDelegate")
        }

        self.trackerStore = TrackerStore(context: appDelegate.persistentContainer.viewContext)
        self.categoryStore = TrackerCategoryStore(context: appDelegate.persistentContainer.viewContext)
        self.recordStore = TrackerRecordStore(context: appDelegate.persistentContainer.viewContext)
        self.trackerService = TrackerService(trackerStore: trackerStore, categoryStore: categoryStore, recordStore: recordStore)
        self.tracker = tracker
        self.selectedCategory = category  // Сохраняем выбранную категорию

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tracker: Tracker?
    var onTrackerAdded: (() -> Void)?
    
    private var selectedDays: [DayOfWeek] = []
    let createHabitView = CreateHabitView()
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let trackerService: TrackerService
    
    private let maxNameLength = 38
    private var optionsTopConstraint: NSLayoutConstraint?
    private var selectedCategory: String?
    
    private var emoji: String = ""
    private var color: UIColor = UIColor(resource: .launchScreenBackground)

    // MARK: - View Lifecycle

    override func loadView() {
        view = createHabitView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        setupTextViewDelegate()
        setupInitialConstraints()
        setupEmojiSelection()
        setupColorSelection()
        createHabitView.updateSelectedDaysLabel(with: "")
        updateCreateButtonState()
        
        if isEditingTracker {
            setupForEditing()
        }
    }

    // MARK: - Setup

    func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.title = isEditingTracker ? "Редактирование привычки" : "Новая привычка"
        
        guard let navigationBar = navigationController?.navigationBar else {
            print("NavigationController отсутствует")
            return
        }
        
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
    }

    private func setupActions() {
        createHabitView.clearButton.addTarget(self, action: #selector(clearTextView), for: .touchUpInside)
        createHabitView.cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createHabitView.createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        let categoryTapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        createHabitView.categoryView.addGestureRecognizer(categoryTapGesture)

        let scheduleTapGesture = UITapGestureRecognizer(target: self, action: #selector(scheduleTapped))
        createHabitView.scheduleView.addGestureRecognizer(scheduleTapGesture)
    }

    private func setupTextViewDelegate() {
        createHabitView.trackerNameTextView.delegate = self
    }

    private func setupInitialConstraints() {
        optionsTopConstraint = createHabitView.optionsContainer.topAnchor.constraint(equalTo: createHabitView.trackerNameContainer.bottomAnchor, constant: 24)
        optionsTopConstraint?.isActive = true
    }
    
    private func setupEmojiSelection() {
        createHabitView.onEmojiSelected = { [weak self] selectedEmoji in
            self?.emoji = selectedEmoji // Обновляем выбранное эмодзи
            self?.updateCreateButtonState() // Обновляем состояние кнопки "Создать"
            print("Выбранное эмодзи: \(selectedEmoji)")
        }
    }
    
    private func setupColorSelection() {
        createHabitView.onColorSelected = { [weak self] selectedColor in
            self?.color = selectedColor // Обновляем выбранный цвет
            self?.updateCreateButtonState() // Обновляем состояние кнопки "Создать"
            print("Выбранный цвет: \(selectedColor)")
        }
    }

    // MARK: - Actions

    @objc private func clearTextView() {
        createHabitView.trackerNameTextView.text = ""
        createHabitView.clearButton.isHidden = true
        createHabitView.placeholderLabel.isHidden = false
        createHabitView.errorLabel.isHidden = true
        updateOptionsContainerSpacing(hasError: false)
        updateCreateButtonState()
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func createButtonTapped() {
        guard let trackerName = createHabitView.trackerNameTextView.text, !trackerName.isEmpty else {
            print("Название трекера не заполнено!")
            return
        }

        guard let selectedCategory = selectedCategory else {
            print("Категория не выбрана!")
            return
        }

        let selectedDaysStrings = selectedDays.map { $0.rawValue }

        guard let category = categoryStore.addCategory(title: selectedCategory) else {
            print("Не получается создать категорию")
            return
        }

        // Проверяем, выполняем ли мы редактирование
        if let tracker = tracker {
            // Обновление существующего трекера
            trackerStore.updateTracker(
                tracker.id,
                newName: trackerName,
                newColor: color,
                newEmoji: emoji
            ) { [weak self] success in
                if success {
                    print("Трекер успешно обновлен")
                    self?.onTrackerAdded?()
                    self?.closeAllModals()
                } else {
                    print("Не удалось обновить трекер")
                }
            }
        } else {
            // Создание нового трекера
            guard let newTracker = trackerStore.addTracker(
                name: trackerName,
                color: color,
                emoji: emoji,
                schedule: selectedDaysStrings,
                category: category,
                type: .habit
            ) else {
                print("Не удалось создать трекер")
                return
            }
            print("Трекер создан: \(newTracker.name)")
            onTrackerAdded?()
            closeAllModals()
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func scheduleTapped() {
        view.endEditing(true)
        let scheduleVC = ScheduleViewController(selectedDays: selectedDays)
        scheduleVC.delegate = self
        let navController = UINavigationController(rootViewController: scheduleVC)
        present(navController, animated: true, completion: nil)
    }

    @objc private func categoryTapped() {
        let categoryStore = categoryStore
        let categoryViewModel = CategoryViewModel(categoryStore: categoryStore)
        let categoryViewController = CategoryViewController(viewModel: categoryViewModel, selectedCategory: selectedCategory)
        
        categoryViewController.onCategorySelected = { [weak self] selectedCategory in
            print("Выбранная категория в CreateEventViewController: \(selectedCategory)")
            self?.selectedCategory = selectedCategory
            self?.createHabitView.updateSelectedCategoryLabel(with: selectedCategory)
            self?.updateCreateButtonState()
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigationController?.pushViewController(categoryViewController, animated: true)
    }
    
    // MARK: - ScheduleViewControllerDelegate
    
    func didSelectDays(_ days: [String]) {
        print("didSelectDays called with days: \(days)")
        if days.count == DayOfWeek.allCases.count {
            createHabitView.updateSelectedDaysLabel(with: "Каждый день")
        } else {
            createHabitView.updateSelectedDaysLabel(with: days.joined(separator: ", "))
        }
        // Преобразуем строки обратно в DayOfWeek и сохраняем выбранные дни
        selectedDays = days.compactMap { DayOfWeek(rawValue: $0) }
        
        // Обновляем состояние кнопки
        updateCreateButtonState()
    }

    private func updateOptionsContainerSpacing(hasError: Bool) {
        optionsTopConstraint?.isActive = false

        if hasError {
            optionsTopConstraint = createHabitView.optionsContainer.topAnchor.constraint(equalTo: createHabitView.errorLabel.bottomAnchor, constant: 32)
        } else {
            optionsTopConstraint = createHabitView.optionsContainer.topAnchor.constraint(equalTo: createHabitView.trackerNameContainer.bottomAnchor, constant: 24)
        }

        optionsTopConstraint?.isActive = true

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        let textCount = textView.text.count
        createHabitView.clearButton.isHidden = textCount == 0
        createHabitView.placeholderLabel.isHidden = textCount > 0

        if textCount >= maxNameLength {
            createHabitView.errorLabel.isHidden = false
            updateOptionsContainerSpacing(hasError: true)
        } else {
            createHabitView.errorLabel.isHidden = true
            updateOptionsContainerSpacing(hasError: false)
        }

        updateCreateButtonState()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newLength = currentText.count + text.count - range.length
        return newLength <= maxNameLength
    }

    // MARK: - Вспомогательные методы
    
    private func updateCreateButtonState() {
        print("Обновление состояния кнопки 'Создать'")
        let isNameEntered = !(createHabitView.trackerNameTextView.text?.isEmpty ?? true)
        let isCategorySelected = selectedCategory != nil
        let isSelectedDays = selectedDays.count >= 1
        let isEmojiSelected = !emoji.isEmpty // Проверка на выбор эмодзи
        let isColorSelected = color != UIColor(resource: .launchScreenBackground) // Проверка на выбор цвета
        
        // Кнопка активируется только если введено название, выбрана категория, расписание, эмодзи и цвет
        createHabitView.createButton.isEnabled = isNameEntered && isCategorySelected && isSelectedDays && isEmojiSelected && isColorSelected
        print("Кнопка активна: \(createHabitView.createButton.isEnabled)")
        createHabitView.createButton.backgroundColor = createHabitView.createButton.isEnabled ? UIColor(named: "createButtonActive") : UIColor(named: "createButtonNone")
    }
    
    private var isEditingTracker: Bool {
        return tracker != nil
    }
    
    private func setupForEditing() {
        guard let tracker else { return }

        // Устанавливаем название и скрываем плейсхолдер
        createHabitView.trackerNameTextView.text = tracker.name
        createHabitView.placeholderLabel.isHidden = !tracker.name.isEmpty

        // Обновляем выбранную категорию
        if let savedCategory = selectedCategory {
            createHabitView.updateSelectedCategoryLabel(with: savedCategory)
        }

        // Обновляем расписание
        createHabitView.updateSelectedDaysLabel(with: tracker.schedule.joined(separator: ", "))
        selectedDays = tracker.schedule.compactMap { DayOfWeek(rawValue: $0) }

        // Устанавливаем выбранный эмодзи
        emoji = tracker.emoji
        if let emojiIndex = createHabitView.emojis.firstIndex(of: emoji) {
            createHabitView.selectedEmojiIndex = IndexPath(item: emojiIndex, section: 0)
            createHabitView.emojiCollectionView.reloadData()
        }

        // Сравнение и установка цвета
        color = tracker.color
        if let colorIndex = createHabitView.colors.firstIndex(where: { $0.isEqualToColor(tracker.color) }) {
            createHabitView.selectedColorIndex = IndexPath(item: colorIndex, section: 0)
            createHabitView.colorCollectionView.reloadData()
        }

        // Обновляем кнопку для редактирования
        createHabitView.createButton.setTitle("Сохранить", for: .normal)

        // Устанавливаем количество выполнений
        let completionCount = trackerService.countCompleted(for: tracker)
        createHabitView.updateCompletedDaysLabel(with: completionCount)
    }
    
    private func closeAllModals() {
        if let presentingVC = presentingViewController?.presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

@available(iOS 17, *)
#Preview {
    CreateHabitViewController()
}

extension UIColor {
    func isEqualToColor(_ otherColor: UIColor) -> Bool {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        otherColor.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2
    }
}
