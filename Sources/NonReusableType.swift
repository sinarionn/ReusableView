//
//  NonReusableType.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import Foundation
import RxSwift

public protocol NonReusableType: ViewModelHolderType {
    func onAttemptToReuse(with viewModel: ViewModelType?)
}

extension NonReusableType {
    public func onAttemptToReuse(with viewModel: ViewModelType?) {
        assertionFailure("\(String(describing: self)) doesn't support reuse. Use ReusableType instead.")
    }
}

extension NonReusableType where Self.CompatibleType: AnyObject {
    public var viewModel: ViewModelType? {
        set {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            guard associated(with: self, by: &AssociatedKeys.viewModel) as ViewModelType? == nil else {
                return onAttemptToReuse(with: newValue)
            }
            guard let newVM = newValue else { return }
            prepareForUsage()
            associate(self, withValue: newVM, by: &AssociatedKeys.viewModel)
            objc_sync_exit(self)

            onUpdate(with: newVM, reuseBag: rx.disposeBag)
            _viewModelDidUpdate.onNext((newVM, rx.disposeBag))
        }
        
        get {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            return associated(with: self, by: &AssociatedKeys.viewModel)
        }
    }
}

fileprivate struct AssociatedKeys {
    static var viewModel = "view model associated key"
}
