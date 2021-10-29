//
//  ViewController.swift
//  Example-RxSwift
//
//  Created by limefriends on 2021/10/29.
//

import RxSwift

#if os(iOS)
    import UIKit
    typealias OSViewController = UIViewController
#endif

class ViewController: OSViewController {
    var disposeBag = DisposeBag()
}
