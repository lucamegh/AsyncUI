# AsyncUI ⌛️

AsyncUI solves the common problem of loading and displaying asynchronous content in modern UIKit apps.

<p>
  	<img src="https://user-images.githubusercontent.com/7815995/126147742-21bdbc6a-3783-4cb7-b351-8a4c31655b0d.gif" alt="AsyncUI" title="AsyncUI"> 
</p>

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
import AsyncUI

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

You can also map different error messages and retry policies to each error:

```swift
AsyncContentViewController(
    ...,
    loadingMessage: "This won't take long",
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
    content: { 
        Cookbook.shared.favoriteRecipes()
    },
    renderLoading: MyLoadingViewController.init,
    renderContent: { recipes in
        if recipes.isEmpty {
            return EmptyViewController(configuration: .recipes)
        } else {
            return ListViewController(cellType: RecipeCell.self, items: recipes) { cell, recipe in
                cell.viewModel = RecipeViewModel(recipe: recipe)
            }
        }
    },
    renderError: { error, retry in
        let message = error.recoverySuggestion
        return MyErrorViewController(message: message, retry: retry)
    }
)
```

The error rendering closure takes a `RetryAction` instance that incapsulates `AsyncContentViewController`'s retrying logic. Call it from your custom error view controller to give users a chance to reload the asynchronous content.
