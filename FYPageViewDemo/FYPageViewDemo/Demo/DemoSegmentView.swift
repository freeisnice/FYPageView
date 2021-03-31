//
//  DemoSegmentView.swift
//  FYPageViewDemo
//
//  Created by sven on 2021/3/31.
//

import UIKit

class DemoSegmentView: UIView, FYSegmentProtocol {

    let segment = UISegmentedControl(items: ["page1", "page2", "page3"])

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(segment)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        segment.frame = bounds
    }

    func setSelectIndex(index: NSInteger) {
        segment.selectedSegmentIndex = index
    }

    // MARK: FYSegmentProtocol
    func getSegmentHeight() -> CGFloat {
        return 40
    }

    func reloadData() {}
}
