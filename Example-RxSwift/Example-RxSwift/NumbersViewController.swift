//
//  NumbersViewController.swift
//  Example-RxSwift
//
//  Created by limefriends on 2021/10/28.
//

import UIKit
import RxSwift
import RxCocoa

class NumbersViewController: UIViewController {
    @IBOutlet weak var numberInput1: UITextField!
    @IBOutlet weak var numberInput2: UITextField!
    @IBOutlet weak var resultLabel: UILabel!
    
    var disposBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable<Int>.combineLatest(numberInput1.rx.text.orEmpty, numberInput2.rx.text.orEmpty) { number1, number2 -> Int in
            return (Int(number1) ?? 0) + (Int(number2) ?? 0)
        }
        .map { $0.description } /// UILabel에 넣어야 하니까 String으로 변환
        .bind(to: resultLabel.rx.text)
        .disposed(by: disposBag)
    }
}
