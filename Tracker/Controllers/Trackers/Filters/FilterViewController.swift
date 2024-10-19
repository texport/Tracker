//
//  FilterViewController.swift
//  Tracker
//
//  Created by Sergey Ivanov on 15.10.2024.
//
import UIKit

final class FilterViewController: UIViewController {

    private let viewModel: FilterViewModel
    private var selectedIndexPath: IndexPath?

    init(viewModel: FilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.backgroundColor = .tableBackground
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        tableView.separatorStyle = .none
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.title = "Фильтры"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
    }

    private func setupTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }

        let filter = TrackerFilter.allCases[indexPath.row]
        let isSelected = viewModel.selectedFilter == filter
        let isLast = indexPath.row == TrackerFilter.allCases.count - 1

        cell.configure(with: filter.rawValue, showBottomSeparator: !isLast, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = TrackerFilter.allCases[indexPath.row]
        viewModel.selectFilter(selectedFilter)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

final class FilterCell: UITableViewCell {

    static let reuseIdentifier = "FilterCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private let bottomSeparator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(bottomSeparator)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            bottomSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    func configure(with title: String, showBottomSeparator: Bool, isSelected: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        contentView.backgroundColor = .tableBackground
        bottomSeparator.isHidden = !showBottomSeparator
    }
}
