//
//  ViewModelHolderProtocol.swift
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

public protocol ViewModelHolderProtocol: class, ReactiveCompatible {
    associatedtype ViewModelProtocol
    var viewModel: ViewModelProtocol? { get set }
    
    func onUpdate(with viewModel: ViewModelProtocol, disposeBag: DisposeBag)
    
    func prepareForUsage()
}

public extension ViewModelHolderProtocol {
    public func prepareForUsage() {}
}



#if os(OSX)
    extension ViewModelHolderProtocol where Self: NSViewController {
        public func prepareForUsage() {
            view.layout()
        }
    }
    
    extension ViewModelHolderProtocol where Self: NSView {
        public func prepareForUsage() {
            layout()
        }
    }
#elseif os(iOS)
    import UIKit
    extension ViewModelHolderProtocol where Self: UIViewController {
        public func prepareForUsage() {
            loadViewIfNeeded()
            view.layoutIfNeeded()
        }
    }
    
    extension ViewModelHolderProtocol where Self: UIView {
        public func prepareForUsage() {
            layoutIfNeeded()
        }
    }
#endif
