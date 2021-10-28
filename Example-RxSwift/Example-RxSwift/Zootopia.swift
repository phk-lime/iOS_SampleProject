//
//  Zootopia.swift
//  Example-RxSwift
//
//  Created by limefriends on 2021/10/28.
//

import UIKit
import RxSwift

class Zootopia {
    struct Rabbit {
        let comment = "rabbit's comming"
    }
    
    let disposeBag = DisposeBag()
    
    /// interval -> period와 scheduler를 파라미터로 받아 시간값 이벤트를 발생시키는 Observable
    let timer = Observable<Int>.interval(RxTimeInterval.seconds(3),
                                         scheduler: MainScheduler.instance)
    
    init() {
        /// Observable 이벤트를 Rabbit 객체로 mapping
        /// 3초마다 새로운 객체를 전달한다
        timer.map { _ in
            Rabbit()
        }
        /// subscribe는 발생한 이벤트를 구독하는 구문(syntax)
        .subscribe { rabbit in
            print("--->", rabbit.comment)
        }
        /// disposeBag을 생성하고 disposed(by: ) 를 통해 설정해주면 disposeBag 변수를 초기화 하거나 deinit 되면 옵저버는 종료된다.
        .disposed(by: disposeBag)
    }
    
    deinit {
        print("---> deinit")
    }
}
