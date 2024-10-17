import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    var tracker: Tracker?
    var didTogglePin: ((Tracker) -> Void)?
    var didEditTracker: ((Tracker) -> Void)?
    var didDeleteTracker: ((Tracker) -> Void)?
    
    var didTapActionButton: (() -> Void)?
    
    
    private func setupView() {
        // Добавляем обработчик нажатия
        actionButton.addTarget(self, action: #selector(handleActionButtonTap), for: .touchUpInside)
    }
    
    // MARK: - UI Elements
    
    // Контейнер для всех элементов
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    // Фоновый вид для карточки трекера
    private lazy var backgroundCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isOpaque = true
        return view
    }()
    
    // Эмодзи трекера
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pinIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pin.fill"))
        imageView.tintColor = .white
        imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true  // По умолчанию скрыта
        return imageView
    }()
    
    // Название трекера
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.baselineAdjustment = .alignBaselines
        return label
    }()
    
    // Кнопка действия
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Счетчик выполнений
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .mainText
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Инициализация
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(backgroundCardView)
        backgroundCardView.addSubview(emojiLabel)
        backgroundCardView.addSubview(pinIcon)
        backgroundCardView.addSubview(trackerNameLabel)
        
        containerView.addSubview(actionButton)
        containerView.addSubview(counterLabel)
        
        setupConstraints()
        setupContextMenuInteraction()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Настройка констрейнтов
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Контейнер
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 148),
            
            // Фоновый вид карточки
            backgroundCardView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundCardView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundCardView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundCardView.heightAnchor.constraint(equalToConstant: 90),
            
            // Эмодзи
            emojiLabel.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            pinIcon.topAnchor.constraint(equalTo: backgroundCardView.topAnchor, constant: 12),
            pinIcon.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -4),
            pinIcon.widthAnchor.constraint(equalToConstant: 24),
            pinIcon.heightAnchor.constraint(equalToConstant: 24),
            
            // Название трекера
            trackerNameLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            trackerNameLabel.leadingAnchor.constraint(equalTo: backgroundCardView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: backgroundCardView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: backgroundCardView.bottomAnchor, constant: -12),
            trackerNameLabel.heightAnchor.constraint(equalToConstant: 34),
            
            // Кнопка действия
            actionButton.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 8),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            actionButton.widthAnchor.constraint(equalToConstant: 34),
            actionButton.heightAnchor.constraint(equalToConstant: 34),
            
            // Счетчик выполнений
            counterLabel.topAnchor.constraint(equalTo: backgroundCardView.bottomAnchor, constant: 16),
            counterLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            counterLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
        ])
    }
    
    // Обработчик нажатия на кнопку
    @objc private func handleActionButtonTap() {
        didTapActionButton?()
    }
    
    private func setupContextMenuInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        backgroundCardView.addInteraction(interaction)
    }
    
    // MARK: - Настройка ячейки
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedCount: Int, isFutureDate: Bool) {
        self.tracker = tracker
        backgroundCardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        pinIcon.isHidden = !tracker.isPinned
        trackerNameLabel.text = tracker.name
        actionButton.backgroundColor = tracker.color

        counterLabel.text = "\(completedCount) дней"

        if isFutureDate {
            // Если выбранная дата в будущем, трекер нельзя выполнить
            actionButton.setImage(UIImage(systemName: "plus"), for: .normal)
            actionButton.tintColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .black : .white
            }
            actionButton.isUserInteractionEnabled = false
            actionButton.alpha = 0.5
            actionButton.backgroundColor = tracker.color.withAlphaComponent(0.5)
        } else if isCompleted {
            // Если трекер уже выполнен в выбранный день, кнопка становится недоступной
            actionButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            actionButton.tintColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .black : .white
            }
            actionButton.isUserInteractionEnabled = false
            actionButton.alpha = 0.5
            actionButton.backgroundColor = tracker.color.withAlphaComponent(0.5)
        } else {
            // Если трекер не выполнен, кнопка активна
            actionButton.setImage(UIImage(systemName: "plus"), for: .normal)
            actionButton.tintColor = UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? .black : .white
            }
            actionButton.isUserInteractionEnabled = true
            actionButton.alpha = 1.0
            actionButton.backgroundColor = tracker.color
        }
    }

}

// MARK: - UIContextMenuInteractionDelegate
extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let tracker = tracker else { return nil }

        let pinTitle = tracker.isPinned ? "Открепить" : "Закрепить"

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let pinAction = UIAction(title: pinTitle) { [weak self] _ in
                guard let self = self, let tracker = self.tracker else { return }
                self.didTogglePin?(tracker)
            }

            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self = self, let tracker = self.tracker else { return }
                self.didEditTracker?(tracker)
            }

            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                guard let self = self, let tracker = self.tracker else { return }
                self.didDeleteTracker?(tracker)
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}
