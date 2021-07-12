/**
 * AsyncUI
 * Copyright (c) Luca Meghnagi 2021
 * MIT license, see LICENSE file for details
 */

import Combine
import CombineHelpers
import LoadingState
import Portal
import UIKit
import UIKitHelpers

public final class AsyncContentViewController<Content, Error: Swift.Error>: UIViewController {
    
    public var transitionProvider: TransitionProvider? = .fixed(.default)
    
    private lazy var containerViewController = ContainerViewController(
        content: viewControllerProvider(context).viewController(for: state)
    )
    
    private var context: Context {
        let retry = RetryAction { [weak self] in self?.loadContent() }
        return Context(retry: retry)
    }
    
    private var loadingCancellable: AnyCancellable?
    
    private var contentCancellable: AnyCancellable?
    
    @Published private var state = State.idle
    
    private let content: () -> AnyPublisher<Content, Error>
    
    private let viewControllerProvider: (Context) -> ViewControllerProvider
    
    fileprivate init(
        content: @escaping () -> AnyPublisher<Content, Error>,
        viewControllerProvider: @escaping (Context) -> ViewControllerProvider
    ) {
        self.content = content
        self.viewControllerProvider = viewControllerProvider
        super.init(nibName: nil, bundle: nil)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        install(containerViewController)
        loadContent()
    }
    
    private func loadContent() {
        state = .inProgress
        loadingCancellable = content().asResult().sink { [unowned self] result in
            state = .finished(result)
        }
    }
    
    private func setUp() {
        contentCancellable = $state.sink { [unowned self] state in
            let transition = transitionProvider?.transition(for: state)
            containerViewController.setContent(
                viewControllerProvider(context).viewController(for: state),
                using: transition
            )
        }
    }
}

public extension AsyncContentViewController {
    
    convenience init(
        content: @escaping () -> AnyPublisher<Content, Error>,
        render: @escaping (Content) -> UIViewController,
        loadingMessage: String? = nil,
        errorMessage: @escaping (Error) -> String,
        retryBehavior: RetryBehavior = .always
    ) {
        self.init(content: content) { context in
            ViewControllerProvider(
                renderLoading: {
                    LoadingViewController(message: loadingMessage)
                },
                renderContent: render,
                renderError: { error in
                    let message = errorMessage(error)
                    let retry = retryBehavior.shouldRetry(error) ? context.retry : nil
                    return ErrorViewController(message: message, retry: retry)
                }
            )
        }
    }
    
    static func custom(
        content: @escaping () -> AnyPublisher<Content, Error>,
        renderLoading: @escaping () -> UIViewController,
        renderContent: @escaping (Content) -> UIViewController,
        renderError: @escaping (Error) -> UIViewController
    ) -> AsyncContentViewController {
        custom(
            content: content,
            viewControllerProvider: ViewControllerProvider(
                renderLoading: renderLoading,
                renderContent: renderContent,
                renderError: renderError
            )
        )
    }
    
    static func custom(
        content: @escaping () -> AnyPublisher<Content, Error>,
        viewControllerProvider: ViewControllerProvider
    ) -> AsyncContentViewController {
        custom(content: content) { _ in viewControllerProvider }
    }
    
    static func custom(
        content: @escaping () -> AnyPublisher<Content, Error>,
        viewControllerProvider: @escaping (Context) -> ViewControllerProvider
    ) -> AsyncContentViewController {
        AsyncContentViewController(
            content: content,
            viewControllerProvider: viewControllerProvider
        )
    }
}

public extension AsyncContentViewController {
    
    struct ViewControllerProvider {
        
        private let render: (State) -> UIViewController?
        
        public init(_ render: @escaping (State) -> UIViewController?) {
            self.render = render
        }
        
        public init(
            renderLoading: @escaping () -> UIViewController,
            renderContent: @escaping (Content) -> UIViewController,
            renderError: @escaping (Error) -> UIViewController
        ) {
            self.init { state in
                switch state {
                case .idle:
                    return nil
                case .inProgress:
                    return renderLoading()
                case .success(let content):
                    return renderContent(content)
                case .failure(let error):
                    return renderError(error)
                }
            }
        }
        
        fileprivate func viewController(for state: State) -> UIViewController? {
            render(state)
        }
    }
}

public extension AsyncContentViewController {
    
    typealias State = LoadingState<Content, Error>
    
    typealias Transition = ContainerViewController.Transition
}

public extension AsyncContentViewController {
    
    struct TransitionProvider {
        
        fileprivate let transition: (State) -> Transition?
        
        private init(_ transition: @escaping (State) -> Transition?) {
            self.transition = transition
        }
        
        fileprivate func transition(for state: State) -> Transition? {
            transition(state)
        }
        
        public static func fixed(_ transition: Transition) -> Self {
            TransitionProvider { _ in transition }
        }
        
        public static func dynamic(_ handler: @escaping (State) -> Transition?) -> Self {
            TransitionProvider(handler)
        }
    }
}

public extension AsyncContentViewController {
    
    struct RetryBehavior {
        
        fileprivate let shouldRetry: (Error) -> Bool
        
        private init(_ shouldRetry: @escaping (Error) -> Bool) {
            self.shouldRetry = shouldRetry
        }
        
        public static var always: Self {
            custom { _ in true }
        }
        
        public static var never: Self {
            custom { _ in false }
        }
        
        public static func custom(_ shouldRetry: @escaping (Error) -> Bool) -> Self {
            RetryBehavior(shouldRetry)
        }
    }
}

public extension AsyncContentViewController {
    
    struct Context {
        
        public let retry: RetryAction
    }
}
