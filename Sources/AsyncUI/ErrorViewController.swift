/**
 * AsyncUI
 * Copyright (c) Luca Meghnagi 2021
 * MIT license, see LICENSE file for details
 */

import UIKit
import UIKitHelpers

final class ErrorViewController: UIViewController {
    
    private let message: String
    
    private let retry: RetryAction?
    
    init(message: String, retry: RetryAction? = nil) {
        self.message = message
        self.retry = retry
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
        let stackView = makeStackView()
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor)
        ])
    }
    
    private func makeStackView() -> UIStackView {
        UIStackView.horizontal(
            alignment: .center,
            arrangedSubviews: [
                UIStackView.vertical(
                    alignment: .center,
                    arrangedSubviews: [
                        makeRetryButton(),
                        makeMessageLabel()
                    ]
                )
            ]
        )
    }
    
    private func makeRetryButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = .tertiaryLabel
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        let image = UIImage(systemName: "arrow.clockwise", withConfiguration: configuration)
        button.addAction(UIAction { [unowned self] _ in retry?() }, for: .primaryActionTriggered)
        button.setImage(image, for: .normal)
        return button
    }
    
    private func makeMessageLabel() -> UILabel {
        UILabel.title3(
            text: message,
            weight: .semibold,
            textAlignment: .center,
            numberOfLines: 0
        )
    }
}
