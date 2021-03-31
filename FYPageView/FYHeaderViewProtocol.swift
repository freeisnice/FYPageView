//
//  FYHeaderViewProtocol.swift
//  FYPageView
//
//  Created by sven on 2021/3/31.
//

import UIKit

public protocol FYHeaderViewProtocol: NSObjectProtocol {

    //刷新头视图
    func reloadData()

    //获取分段控件高度
    func getHeaderHeight() -> CGFloat
}
