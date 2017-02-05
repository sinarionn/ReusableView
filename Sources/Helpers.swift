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
    objc_setAssociatedObject(object, key, value, policy)
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

extension Reactive where Base: ReusableViewProtocol, Base: AnyObject {
    public var reuseBag: DisposeBag {
        get {
            return base.reuseBag
        }
        set {
            base.reuseBag = newValue
        }
    }
}

fileprivate struct AssociatedKeys {
    static var disposeBag = "viewModel dispose bag associated key"
}
