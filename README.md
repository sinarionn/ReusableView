# ReusableView

[![CI Status](http://img.shields.io/travis/sinarionn/ReusableView.svg?style=flat)](https://travis-ci.org/sinarionn/ReusableView)
[![codecov.io](http://codecov.io/github/sinarionn/ReusableView/coverage.svg?branch=master)](http://codecov.io/github/sinarionn/ReusableView?branch=master)
[![Version](https://img.shields.io/cocoapods/v/ReusableView.svg?style=flat)](http://cocoapods.org/pods/ReusableView)
[![License](https://img.shields.io/cocoapods/l/ReusableView.svg?style=flat)](http://cocoapods.org/pods/ReusableView)
[![Platform](https://img.shields.io/cocoapods/p/ReusableView.svg?style=flat)](http://cocoapods.org/pods/ReusableView)

## Requirements

- iOS 8.0+
- Xcode 8+
- Swift 3

## Installation

ReusableView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ReusableView'
```

## Usage

**NonReusableViewProtocol** - if your view should not be reused. All next attempts to set viewModel will only call onAttemptToReuse method.

**ReusableViewProtocol** - if your view supports reuse. prepareForReuse will be called each time.

**DistinctiveReuse** - marker, ReusableView will ignore all viewModels that are equal to current one.

## Examples

#### Simple NonReusableView

```swift
protocol ViewModelProtocol {
    var observable: Observable<String> { get }
}

class NonReusableView: UIView, NonReusableViewProtocol {
    @IBOutlet weak var label: UILabel!

    // In case of NonReusableViewProtocol disposeBag are equal to rx.disposeBag. Method will be called only one time.
    func onUpdate(with viewModel: ViewModelProtocol, disposeBag: DisposeBag) {
        viewModel.observable.bindTo(label.rx.text).addDisposableTo(disposeBag)
    }
}
```

#### Simplest ReusableView

```swift
protocol ViewModelProtocol: Equatable {
    var observable: Observable<String> { get }
}

class ReusableView: UIView, ReusableViewProtocol, DistinctiveReuse {
    @IBOutlet weak var label: UILabel!

    // parameter disposeBag will be new for each time viewModel is successfully set.
    func onUpdate(with viewModel: ViewModelProtocol, disposeBag: DisposeBag) {
        viewModel.observable.bindTo(label.rx.text).addDisposableTo(disposeBag)
    }
}
```

## Author

Artem Antihevich, sinarionn@gmail.com

## License

ReusableView is available under the MIT license. See the LICENSE file for more info.
