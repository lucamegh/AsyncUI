# AsyncUI ⌛️

AsyncUI solves the problem of loading and displaying asynchronous content in modern UIKit apps.

## Installation

AsyncUI is distributed using [Swift Package Manager](https://swift.org/package-manager). To install it into a project, simply add it as a dependency within your Package.swift manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/lucamegh/AsyncUI", from: "1.0.0")
    ],
    ...
)
```

## Usage

```swift
let asyncProfileVC = AsyncContentViewController(
    content: {
        ProfileLoader.shared.profile(id: 1234) // AnyPublisher<Profile, ProfileLoader.Error>
    },
    render: { profile in
        let viewModel = ProfileViewModel(profile: profile)
        return ProfileViewController(viewModel: viewModel)
    },
    errorMessage: "Oops! Something went wrong..."
)
navigationController.pushViewController(asyncProfileVC, animated: true)
```

Pretty cool, huh? 

You can also provide different error messages and retry policies depending on the error:

```swift
AsyncContentViewController(
    ...,
    errorMessage: { error in
        switch error {
        case .notConnectedToInternet:
            return "Check your internet connection and try again."
        default:
            return "Oops! Something went wrong..."
        }
    },
    retryPolicy: { error in
        switch error {
        case .notConnectedToInternet:
            return .always
        default:
            return .never
        }
    }
)
```

When `retryPolicy` returns a `RetryPolicy.always`, the standard failure view controller will display a retry button.

If you don't want to use the standard loading and failure view controllers, use one of the `AsyncContentViewController.custom` static factory methods to provide your own.

Let's see how to implement an asynchronously loaded list with custom loading and failure screens using [Lists](https://github.com/lucamegh/Lists) and AsyncUI.

```swift
AsyncContentViewController.custom(
    content: Cookbook.shared.favoriteRecipes,
    renderLoading: MyLoadingViewController.init,
    renderContent: { recipes in
        if recipes.isEmpty {
            return EmptyViewController(configuration: .recipes)
        } else {
            return ListViewController(cellType: RecipeCell.self, items: recipes) { cell, recipe in
                cell.configure(with: recipe)
            }
        }
    },
    renderError: { error, retry in
        MyErrorViewController(message: error.recoverySuggestion, retry: retry)
    }
)
```

The error rendering function takes a `RetryAction` instance that incapsulates `AsyncContentViewController`'s retrying logic. Call it from your cutom error view controller to give users a chance to reload the asynchronous content.
