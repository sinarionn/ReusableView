//
//  NonReusableViewProtocol.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import Foundation
import RxSwift

public protocol NonReusableViewProtocol: ViewModelHolderProtocol {
    func onAttemptToReuse(with viewModel: ViewModelProtocol?)
}

extension NonReusableViewProtocol {
    public func onAttemptToReuse(with viewModel: ViewModelProtocol?) {
        print("\(String(describing: self)) doesn't support reuse. Use ReusableViewProtocol instead.")
    }
}

extension NonReusableViewProtocol where Self: AnyObject, Self.CompatibleType: AnyObject {
    public var viewModel: ViewModelProtocol? {
        set {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            guard associated(with: self, by: &AssociatedKeys.viewModel) as ViewModelProtocol? == nil else {
                return onAttemptToReuse(with: newValue)
            }
            guard let newVM = newValue else { return }
            prepareForUsage()
            associate(self, withValue: newVM, by: &AssociatedKeys.viewModel)
            objc_sync_exit(self)

            onUpdate(with: newVM, disposeBag: rx.disposeBag)
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
