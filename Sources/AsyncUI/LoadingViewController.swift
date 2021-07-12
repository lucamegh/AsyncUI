/**
 * AsyncUI
 * Copyright (c) Luca Meghnagi 2021
 * MIT license, see LICENSE file for details
 */

import UIKit
import UIKitHelpers

final class LoadingViewController: UIViewController {
    
    private let message: String?
    
    init(message: String?) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
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
                        makeActivityIndicatorView(),
                        makeMessageLabel()
                    ]
                )
            ]
        )
    }
    
    private func makeActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.startAnimating()
        activityIndicatorView.color = .secondaryLabel
        return activityIndicatorView
    }
    
    private func makeMessageLabel() -> UILabel {
        UILabel.subheadline(
            text: message?.uppercased(),
            textColor: .secondaryLabel,
            textAlignment: .center
        )
    }
}
