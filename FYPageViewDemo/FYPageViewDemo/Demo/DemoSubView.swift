//
//  DemoSubView.swift
//  FYPageViewDemo
//
//  Created by sven on 2021/3/31.
//

import UIKit

class DemoSubView: UITableView, UITableViewDataSource, UITableViewDelegate {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        showsVerticalScrollIndicator = false
        dataSource = self
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "test")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "test")
        }
        cell?.textLabel?.text = "索引：\(indexPath.row)"
        return cell!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}
