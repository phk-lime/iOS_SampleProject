//
//  ViewController.swift
//  Example-RxSwift
//
//  Created by limefriends on 2021/10/27.
//

import UIKit
import RxSwift
import RxCocoa

class SampleViewController: UIViewController {
    var zootopia: Zootopia?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        zootopia = Zootopia()
        
//        checkArrayObservable(items: [1, 2, 3, 2]).subscribe { event in
//            switch event {
//            case .next(let item):
//                print("--->", item)
//            case .completed:
//                print("--->completed")
//            case .error(let error):
//                print("--->", error)
//            }
//        }
//        .disposed(by: disposeBag)
        
        let test = Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .take(10)
            .subscribe { value in
                print(value)
            } onError: { error in
                print(error)
            } onCompleted: {
                print("onCompleted")
            } onDisposed: {
                print("onDisposed")
            }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            test.dispose()
        }

    }
    
    func checkArrayObservable(items: [Int]) -> Observable<Int> {
        return Observable.create { observer -> Disposable in
            for item in items {
                if item == 0 {
                    observer.onError(NSError(domain: "0은 출력할 수 없습니다.",
                                             code: 0,
                                             userInfo: nil))
                    break
                }
                observer.onNext(item)
                sleep(1)
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }
}
