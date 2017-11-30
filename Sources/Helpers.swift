//
//  Helpers.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import Foundation
import RxSwift

internal func associate(_ object: Any?, withValue value: Any?,  by key: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
    object.map{ objc_setAssociatedObject($0, key, value, policy) }
}

internal func associated<T>(with object: Any, by key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(object, key) as? T
}

extension Reactive where Base: AnyObject {
    public var disposeBag: DisposeBag {
        get {
            objc_sync_enter(base)
            defer { objc_sync_exit(base) }
            guard let existingBag : DisposeBag = associated(with: base, by: &AssociatedKeys.disposeBag) else {
                let newBag = DisposeBag()
                associate(base, withValue: newBag, by: &AssociatedKeys.disposeBag)
                return newBag
            }
            return existingBag
        }
    }
}

extension Reactive where Base: ReusableViewProtocol {
    public var reuseBag: DisposeBag {
        get {
            return base.reuseBag
        }
        nonmutating set {
            base.reuseBag = newValue
        }
    }
}

extension ViewModelHolderProtocol {
    internal var _viewModelDidUpdate: PublishSubject<(ViewModelProtocol, DisposeBag)> {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            guard let existingObserver : PublishSubject<(ViewModelProtocol, DisposeBag)> = associated(with: self, by: &AssociatedKeys.viewModelUpdateObserver) else {
                let newObserver = PublishSubject<(ViewModelProtocol, DisposeBag)>()
                associate(self, withValue: newObserver, by: &AssociatedKeys.viewModelUpdateObserver)
                return newObserver
            }
            return existingObserver
        }
    }
}

extension Reactive where Base: ViewModelHolderProtocol {
    public var viewModelDidUpdate: Observable<(Base.ViewModelProtocol, DisposeBag)> {
        return base._viewModelDidUpdate.asObservable()
    }
}

fileprivate struct AssociatedKeys {
    static var disposeBag = "viewModel dispose bag associated key"
    static var viewModelUpdateObserver = "viewModel did update observer associated key"
}
