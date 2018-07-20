//
//  Helpers.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

internal func associate(_ object: Any?, withValue value: Any?,  by key: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
    object.map{ objc_setAssociatedObject($0, key, value.map(AssociationWrapper.init), policy) }
}

internal func associated<T>(with object: Any, by key: UnsafeRawPointer) -> T? {
    let wrapper = objc_getAssociatedObject(object, key) as? AssociationWrapper
    return wrapper?.value as? T
}

// unfortunately i was forced to start using such wrappers due to a new objc bug with structures hidden behind protocols
internal class AssociationWrapper {
    let value: Any
    
    init(value: Any) {
        self.value = value
    }
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

extension Reactive where Base: ReusableType {
    public var reuseBag: DisposeBag {
        get {
            return base.reuseBag
        }
    }
}

extension ViewModelHolderType {
    internal var _viewModelDidUpdate: PublishSubject<(ViewModelType, DisposeBag)> {
        get {
            objc_sync_enter(self)
            defer { objc_sync_exit(self) }
            guard let existingObserver : PublishSubject<(ViewModelType, DisposeBag)> = associated(with: self, by: &AssociatedKeys.viewModelUpdateObserver) else {
                let newObserver = PublishSubject<(ViewModelType, DisposeBag)>()
                associate(self, withValue: newObserver, by: &AssociatedKeys.viewModelUpdateObserver)
                return newObserver
            }
            return existingObserver
        }
    }
}

extension Reactive where Base: ViewModelHolderType {
    public var viewModelDidUpdate: Observable<(Base.ViewModelType, DisposeBag)> {
        return base._viewModelDidUpdate.asObservable()
    }
    
    public var viewModel: Binder<Base.ViewModelType?> {
        return Binder(base){ holder, viewModel in
            holder.viewModel = viewModel
        }
    }
}

fileprivate struct AssociatedKeys {
    static var disposeBag = "viewModel dispose bag associated key"
    static var viewModelUpdateObserver = "viewModel did update observer associated key"
}
