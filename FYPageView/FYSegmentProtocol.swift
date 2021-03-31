//
//  FYSegmentProtocol.swift
//  FYPageView
//
//  Created by sven on 2021/3/31.
//

import UIKit

public protocol FYSegmentProtocol: NSObjectProtocol {

    //更新分段控件选中索引（用于子视图与标题联动）
    func setSelectIndex(index: NSInteger)

    //刷新分段控件
    func reloadData()

    //获取分段控件高度
    func getSegmentHeight() -> CGFloat
}
