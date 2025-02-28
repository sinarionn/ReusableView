//
//  ViewModelHolderType.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import Foundation
import RxSwift
#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

public protocol ViewModelHolderType: AnyObject, ReactiveCompatible {
    associatedtype ViewModelType
    var viewModel: ViewModelType? { get set }
    
    func onUpdate(with viewModel: ViewModelType, reuseBag: DisposeBag)
    
    func prepareForUsage()
}

public extension ViewModelHolderType {
    func prepareForUsage() {}
}



#if os(OSX)
    extension ViewModelHolderType where Self: NSViewController {
        public func prepareForUsage() {
            view.layout()
        }
    }
    
    extension ViewModelHolderType where Self: NSView {
        public func prepareForUsage() {
            layout()
        }
    }
#elseif os(iOS)
    import UIKit
    extension ViewModelHolderType where Self: UIViewController {
        public func prepareForUsage() {
            loadViewIfNeeded()
            view.layoutIfNeeded()
        }
    }
    
    extension ViewModelHolderType where Self: UIView {
        public func prepareForUsage() {
            layoutIfNeeded()
        }
    }
#endif
