//
//  DemoHeaderView.swift
//  FYPageViewDemo
//
//  Created by sven on 2021/3/31.
//

import UIKit

class DemoHeaderView: UIView, UITableViewDataSource, FYHeaderViewProtocol {

    let list = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        list.dataSource = self
        list.rowHeight = 20
        addSubview(list)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        list.frame = bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "test")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "test")
        }
        cell?.textLabel?.text = "--\(indexPath.row)"
        cell?.textLabel?.textColor = .black
        return cell!
    }

    // MARK: FYHeaderViewProtocol
    func getHeaderHeight() -> CGFloat {
        return 300
    }

    func reloadData() {}
}

