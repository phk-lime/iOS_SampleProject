//
//  ViewController.swift
//  Example-Prefetching
//
//  Created by limefriends on 2021/11/02.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    /// 검색된 콘텐츠
    var foundContents = [Any]()
    /// 불러올 페이지 & 데이터 개수
    var pageToFetch = 0
    var count = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    }
    
    func fetchData(_ page: Int) {
        /// 데이터 패치에 성공했다면 패치 관련 정보 업데이트
        self.pageToFetch += 1
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        /// 패치할 페이지가 0일 경우 패치할 데이터가 없거나 기타 이유로 패치할 수 없는 상황이기 때문에 Prefetching 하지 않는다.
        guard pageToFetch != 0 else { return }
        indexPaths.forEach {
            /// ex) 한 번에 불러오는 양으로 나눴을 때의 넘버가 다음 패치할 페이지의 넘버와 같으면 프리패치 진행
            /// 다음 페이지 넘버는 1부터 시작하기 때문에 row에 +1을 해준다.
            if ($0.row + 1 / self.count) == pageToFetch {
                fetchData(pageToFetch)
            }
        }
    }
}
