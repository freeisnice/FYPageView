//
//  DemoViewController.swift
//  FYPageViewDemo
//
//  Created by sven on 2021/3/31.
//

import UIKit

class DemoViewController: UIViewController {

    var pageView = FYPageView()

    let headerView = DemoHeaderView()

    let segmentView = DemoSegmentView()

    var subViews: [UIScrollView?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    func initUI() {

        title = "Demo"
        view.backgroundColor = .white

        segmentView.segment.addTarget(self, action: #selector(touchSegment), for: .valueChanged)
        subViews = Array(repeating: nil, count: 3)
        pageView.dataSource = self
        view.addSubview(pageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let nav_height = navigationController?.navigationBar.frame.maxY ?? 0
        pageView.frame = CGRect(x: 0, y: nav_height, width: view.bounds.width, height: view.bounds.height - nav_height)
    }

    @objc func touchSegment() {
        pageView.selectIndex = segmentView.segment.selectedSegmentIndex
    }
}

extension DemoViewController: FYPageViewDataSource {

    func headerViewForPageView(pageView: FYPageView) -> FYHeaderViewProtocol? {
        return headerView
    }

    func segmentViewForPageView(pageView: FYPageView) -> FYSegmentProtocol {
        return segmentView
    }

    func numberOfViews(pageView: FYPageView) -> Int {
        return 3
    }

    func pageView(pageView: FYPageView, index: NSInteger) -> UIScrollView {
        let subView = subViews[index]
        if subView == nil {
            return DemoSubView()
        } else {
            return subView!
        }
    }
}
