//
//  ViewModelHolderProtocol.swift
//  ReusableView
//
//  Created by Artem Antihevich on 2/5/17.
//  Copyright © 2017 Artem Antihevich. All rights reserved.
//

import Foundation
import RxSwift

public protocol ViewModelHolderProtocol: class, ReactiveCompatible {
    associatedtype ViewModelProtocol
    var viewModel: ViewModelProtocol? { get set }
    
    func onUpdate(with viewModel: ViewModelProtocol, disposeBag: DisposeBag)
    
    func prepareForUsage()
}

extension ViewModelHolderProtocol {
    public func prepareForUsage() {}
}

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
