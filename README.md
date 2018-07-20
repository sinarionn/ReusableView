# ReusableView

[![CI Status](http://img.shields.io/travis/sinarionn/ReusableView.svg?style=flat)](https://travis-ci.org/sinarionn/ReusableView)
[![codecov.io](http://codecov.io/github/sinarionn/ReusableView/coverage.svg?branch=master)](http://codecov.io/github/sinarionn/ReusableView?branch=master)
[![Version](https://img.shields.io/cocoapods/v/ReusableView.svg?style=flat)](http://cocoapods.org/pods/ReusableView)
[![License](https://img.shields.io/cocoapods/l/ReusableView.svg?style=flat)](http://cocoapods.org/pods/ReusableView)
[![Platform](https://img.shields.io/cocoapods/p/ReusableView.svg?style=flat)](http://cocoapods.org/pods/ReusableView)

## Requirements

- iOS 9.0+
- osX 10.10+
- Xcode 9+
- Swift 4
- RxCocoa 4.0+

## Installation

ReusableView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ReusableView'
```

## Usage

Extend your class with one of the following protocols and get .viewModel property for free. )
Each viewModel change releases previous subscriptions (by releasing previous reuseBag) and calls `onUpdate` method again.

**NonReusableType** - if your view should not be reused. All next attempts to set viewModel will only call onAttemptToReuse method. (Allows you to ensure vm will be only one. Usually used with UIViewControllers.)

**ReusableType** - if your view supports reuse. viewModelWillUpdate will be called before each assignment. (can be used with cells, views in stackview and so on)


## Methods

**prepareForUsage()** - called only once before first assignment, can be used to initialize view. (check out default implementations)

**viewModelWillUpdate()** - called before each assignment.


## Examples


```swift
protocol MainViewModelType {
    var child: Driver<ChildViewModelType> { get }
}

protocol ChildViewModelType {
    var title: Driver<String> { get }
}

class MainViewController: UIViewController, NonReusableType {
    @IBOutlet weak var childView: ChildView!

    func onUpdate(with viewModel: MainViewModelType, reuseBag: DisposeBag) {
        viewModel.child.drive(childView.rx.viewModel).disposed(by: reuseBag)
    }
}

class ChildView: UIView, ReusableType {
    @IBOutlet weak var label: UILabel!

    // parameter reuseBag will be new for each new viewModel.
    func onUpdate(with viewModel: ChildViewModelType, reuseBag: DisposeBag) {
        viewModel.title.drive(label.rx.text).disposed(by: reuseBag)
    }
}
```

## Author

Artem Antihevich, sinarionn@gmail.com

## License

ReusableView is available under the MIT license. See the LICENSE file for more info.
