//
//  StatisticController.swift
//  Tracker
//
//  Created by Sergey Ivanov on 18.10.2024.
//

import UIKit

final class StatisticViewController: UIViewController {
    private var trackerService: TrackerService?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.trackerService = appDelegate.trackerService
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        placeholderVisability()
        
        applyGradientBorder()
        configureCounters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        placeholderVisability()
        configureCounters()
    }

    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mainBackground
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("label_statistics", comment: "")
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .mainText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mainBackground
        return view
    }()

    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "statistic")
        imageView.tintColor = .lightGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .mainText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bodyContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mainBackground
        return view
    }()
    
    private lazy var countDoneTrackers: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .mainBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true  // Чтобы уголки корректно отображались
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1).cgColor,  // #FD4C49
            UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1).cgColor, // #46E69D
            UIColor(red: 0.0, green: 123/255, blue: 250/255, alpha: 1).cgColor // #007BFA
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        return gradient
    }()
    
    private lazy var borderShapeLayer: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        return shape
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .mainText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var counterName: UILabel = {
        let label = UILabel()
        label.text = "Трекеров завершено"
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .mainText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupViews() {
        view.addSubview(topContainerView)
        topContainerView.addSubview(titleLabel)
        
        view.addSubview(placeholderView)
        placeholderView.addSubview(placeholderImageView)
        placeholderView.addSubview(placeholderLabel)
        
        view.addSubview(bodyContainerView)
        bodyContainerView.addSubview(countDoneTrackers)
        countDoneTrackers.addSubview(countLabel)
        countDoneTrackers.addSubview(counterName)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top Container View
            topContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainerView.heightAnchor.constraint(equalToConstant: 138),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16),
            
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
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            
            // BodyContainerView View
            bodyContainerView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            bodyContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bodyContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bodyContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            countDoneTrackers.topAnchor.constraint(equalTo: bodyContainerView.topAnchor, constant: 24),
            countDoneTrackers.leadingAnchor.constraint(equalTo: bodyContainerView.leadingAnchor, constant: 16),
            countDoneTrackers.trailingAnchor.constraint(equalTo: bodyContainerView.trailingAnchor, constant: -16),
            countDoneTrackers.heightAnchor.constraint(equalToConstant: 90),
            
            countLabel.topAnchor.constraint(equalTo: countDoneTrackers.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: countDoneTrackers.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: countDoneTrackers.trailingAnchor, constant: -12),
            countLabel.heightAnchor.constraint(equalToConstant: 41),
            
            counterName.topAnchor.constraint(equalTo: countLabel.bottomAnchor),
            counterName.leadingAnchor.constraint(equalTo: countDoneTrackers.leadingAnchor, constant: 12),
            counterName.trailingAnchor.constraint(equalTo: countDoneTrackers.trailingAnchor, constant: -12),
            counterName.heightAnchor.constraint(equalToConstant: 18)
        ])
        
        view.layoutIfNeeded()
        applyGradientBorder()
    }
    
    private func placeholderVisability() {
        let isFinished = self.isFinished()
        bodyContainerView.isHidden = !isFinished
        placeholderView.isHidden = isFinished
    }
    
    private func applyGradientBorder() {
        gradientLayer.frame = countDoneTrackers.bounds
        borderShapeLayer.path = UIBezierPath(roundedRect: countDoneTrackers.bounds.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 16).cgPath
        countDoneTrackers.layer.insertSublayer(gradientLayer, at: 0)
        gradientLayer.mask = borderShapeLayer
    }
    
    private func configureCounters() {
        countLabel.text = String(trackerService?.getAllCountCompleted() ?? 0)
    }

    private func isFinished() -> Bool {
        return (trackerService?.getAllCountCompleted() ?? 0) > 0
    }
}
