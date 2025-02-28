//
//  ReusableType.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import Foundation
import RxSwift

public protocol DistinctiveReuse {
}

public protocol ReusableType: ViewModelHolderType {
    func viewModelWillUpdate()
}

extension ReusableType {
    public func viewModelWillUpdate() {}
    
    internal var reuseBag: DisposeBag {
        get {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            guard let existingBag : DisposeBag = associated(with: self, by: &AssociatedKeys.reuseBag) else {
                let newBag = DisposeBag()
                associate(self, withValue: newBag, by: &AssociatedKeys.reuseBag)
                return newBag
            }
            return existingBag
        }
        set {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            associate(self, withValue: newValue, by: &AssociatedKeys.reuseBag)
        }
    }
}

extension ReusableType {
    fileprivate var prepareForUsageWasCalled: Bool {
        get { return associated(with: self, by: &AssociatedKeys.prepareCalled) ?? false }
        set { associate(self, withValue: newValue, by: &AssociatedKeys.prepareCalled) }
    }
    
    public var viewModel: ViewModelType? {
        set {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            if !prepareForUsageWasCalled {
                prepareForUsage()
                prepareForUsageWasCalled = true
            }
            viewModelWillUpdate()
            let reuseBag = DisposeBag()
            self.reuseBag = reuseBag
            associate(self, withValue: newValue, by: &AssociatedKeys.viewModel)
            guard let newVM = newValue else { return }
            objc_sync_exit(self)
            onUpdate(with: newVM, reuseBag: reuseBag)
            _viewModelDidUpdate.onNext((newVM, reuseBag))
        }
        
        get {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            return associated(with: self, by: &AssociatedKeys.viewModel)
        }
    }
}

extension ReusableType where Self.ViewModelType : Equatable {
    public var viewModel: ViewModelType? {
        set {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            if !prepareForUsageWasCalled { /// TODO: find alternative
                prepareForUsage()
                prepareForUsageWasCalled = true
            }
            if self is DistinctiveReuse && newValue == viewModel { return }
            viewModelWillUpdate()
            let reuseBag = DisposeBag()
            self.reuseBag = reuseBag
            associate(self, withValue: newValue, by: &AssociatedKeys.viewModel)
            guard let newVM = newValue else { return }
            objc_sync_exit(self)
            onUpdate(with: newVM, reuseBag: reuseBag)
            _viewModelDidUpdate.onNext((newVM, reuseBag))
        }
        
        get {
            objc_sync_enter(self); defer { objc_sync_exit(self) }
            return associated(with: self, by: &AssociatedKeys.viewModel)
        }
    }
}

fileprivate struct AssociatedKeys {
    nonisolated(unsafe) static var reuseBag = "viewModel reuse bag associated key"
    nonisolated(unsafe) static var viewModel = "view model associated key"
    nonisolated(unsafe) static var prepareCalled = "prepare for usage was called key"
}
