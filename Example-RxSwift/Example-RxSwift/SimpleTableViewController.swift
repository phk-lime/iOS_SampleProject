//
//  SimpleTableViewController.swift
//  Example-RxSwift
//
//  Created by limefriends on 2021/10/29.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleTableViewController: ViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = Observable.just(["가", "나", "다", "라"])
        
        items
            .bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { row, element, cell in
                cell.textLabel?.text = "row: \(row), element: \(element)"
            }
            .disposed(by: disposeBag)
        
        tableView.rx
            .modelSelected(String.self)
            .subscribe(onNext: { element in
                DefaultWireframe.presentAlert("element: \(element)")
            })
            .disposed(by: disposeBag)
        
        tableView.rx
            .itemAccessoryButtonTapped
            .subscribe(onNext: { indexPath in
                DefaultWireframe.presentAlert("indexPath: \(indexPath)")
            })
            .disposed(by: disposeBag)
    }
}
