//
//  ValidateViewController.swift
//  Example-RxSwift
//
//  Created by limefriends on 2021/10/28.
//

import UIKit
import RxSwift
import RxCocoa

private let minimumIDLength = 5
private let minimumPWLength = 10

class ValidateViewController: UIViewController {
    @IBOutlet weak var idInput: UITextField!
    @IBOutlet weak var idValidateLabel: UILabel!
    @IBOutlet weak var pwInput: UITextField!
    @IBOutlet weak var pwValidateLabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let idValidate = idInput.rx.text.orEmpty
            .map { $0.count >= minimumIDLength }
            /// without this map( share() ) would be executed once for each binding, rx is stateless by default.
            /// 보통 share(replay: 1) 형태로 사용
            .share(replay: 1)
        
        let pwValidate = pwInput.rx.text.orEmpty
            .map { $0.count >= minimumPWLength }
            .share(replay: 1)
        
        let everyValidate = Observable.combineLatest(idValidate, pwValidate) { $0 && $1 }
            .share(replay: 1)
        
        idValidate
            /// bind(to:)는 subscribe()의 별칭(Alias)으로 Subscribe()를 호출한 것과 동일
            .bind(to: idValidateLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        pwValidate
            .bind(to: pwValidateLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        everyValidate
            .bind(to: joinButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
//        joinButton.rx.tap
//            .subscribe { [weak self] _ in
//                self?.showJoinedAlert()
//            }
//            .disposed(by: disposeBag)
        
        let TEST = Observable.of(100)
        joinButton.rx.tap
            .flatMap { TEST }
            .map { $0 > 10 }
            .subscribe {
                print("--->", $0)
            }
            .disposed(by: disposeBag)
    }
    
    private func showJoinedAlert() {
        let ac = UIAlertController(title: nil,
                                   message: "회원가입 완료",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "확인",
                                   style: .default))
        present(ac, animated: true)
    }
}
