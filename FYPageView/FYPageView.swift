//
//  FYPageView.swift
//  FYPageView
//
//  Created by sven on 2021/3/31.
//

import UIKit

public protocol FYPageViewDataSource: NSObjectProtocol {

    /// 提供头视图
    /// - Parameter pageView: FYPageView
    func headerViewForPageView(pageView: FYPageView) -> FYHeaderViewProtocol?

    /// 提供分段控件
    /// - Parameter pageView: FYPageView
    func segmentViewForPageView(pageView: FYPageView) -> FYSegmentProtocol

    /// 横向视图个数
    /// - Parameter pageView: FYPageView
    func numberOfViews(pageView: FYPageView) -> Int

    /// 提供当前index选中横向视图
    /// - Parameters:
    ///   - pageView: FYPageView
    ///   - index: 当前选中index
    func pageView(pageView: FYPageView, index: NSInteger) -> UIScrollView
}

public class FYPageView: UIScrollView {

    /// 头视图
    public var headerView: FYHeaderViewProtocol?

    /// 头视图高度
    private var headerViewHeight: CGFloat = 0

    /// 分段控件
    public var segmentView: FYSegmentProtocol?

    /// 分段控件高度
    private var segmentViewHeight: CGFloat = 0

    /// 横向子视图
    private var subViews: [UIScrollView?]?

    ///切换tab前index
    private var fromIndex: NSInteger = 0

    /// 分段控件悬停高度
    public var hoverHeight: CGFloat = 0

    /// 滚动监听
    var observationArray = [NSKeyValueObservation]()

    ///悬停触发偏移量
    private var hoverOffsetY: CGFloat {
        if hoverHeight >= 0 {
            return -segmentViewHeight - hoverHeight
        } else {
            if segmentViewHeight > -hoverHeight {
                return -segmentViewHeight - hoverHeight
            } else if segmentViewHeight < -hoverHeight {
                return -hoverHeight - segmentViewHeight
            } else {
                return 0
            }
        }
    }

    /// 切换tab更新index
    public var selectIndex: NSInteger = 0 {
        didSet {
            guard oldValue != selectIndex else {
                return
            }
            fromIndex = oldValue
            segmentView?.setSelectIndex(index: selectIndex)
            addSubivew(index: selectIndex)
            guard CGFloat(selectIndex) * bounds.width != contentOffset.x else {
                return
            }
            let newContentOffset = CGPoint(x: CGFloat(selectIndex) * bounds.width, y: contentOffset.y)
            setContentOffset(newContentOffset, animated: abs(fromIndex - selectIndex) < 2 ? true : false)
        }
    }

    /// 数据源
    public weak var dataSource: FYPageViewDataSource? {
        didSet {
            guard let dataSource = dataSource else {
                return
            }
            if let headerView = headerView as? UIView {
                headerView.removeFromSuperview()
            }

            headerView = dataSource.headerViewForPageView(pageView: self)
            headerViewHeight = headerView?.getHeaderHeight() ?? 0
            if let headerView = headerView as? UIView {
                addSubview(headerView)
                headerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: headerViewHeight)
            }

            if let segmentView = segmentView as? UIView {
                segmentView.removeFromSuperview()
            }
            segmentView = dataSource.segmentViewForPageView(pageView: self)
            segmentViewHeight = segmentView?.getSegmentHeight() ?? 0
            if let segmentView = segmentView as? UIView {
                addSubview(segmentView)
                segmentView.frame = CGRect(x: 0, y: (headerView as? UIView)?.frame.maxY ?? 0, width: bounds.width, height: segmentViewHeight)
            }

            subViews?.forEach({ (subView) in
                subView?.removeFromSuperview()
            })
            subViews?.removeAll()
            observationArray.removeAll()
            subViews = Array(repeating: nil, count: dataSource.numberOfViews(pageView: self))
        }
    }

    /// 记录是否需要悬停状态
    private var shouldHover = false {
        didSet {

            guard let view = segmentView as? UIView else {
                return
            }
            guard oldValue != shouldHover else {
                return
            }
            view.backgroundColor = UIColor.white
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUIConfig()
    }

    private func initUIConfig() {
        clipsToBounds = true
        bounces = false
        isPagingEnabled = true
        backgroundColor = .white
        delegate = self
        showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }

    /// 刷新UI （刷新内容：头部视图高度重置、 调用头部视图reloadData()、分段控件高度重置、调用分段控件reloadData()、已存在子视图UI刷新）
    /// - Parameter needForce: 是否删除子视图缓存、强制使用最新
    public func reloadData(needForce: Bool = false) {
        guard let dataSource = dataSource else {
            print("FYPageView：调用FCPagingView的reloadData方法需要实现dataSource协议!!!")
            return
        }

        let originTopView_height = headerViewHeight
        let originTitleBar_height = segmentViewHeight

        headerViewHeight = headerView?.getHeaderHeight() ?? 0
        headerView?.reloadData()
        if let headerView = headerView as? UIView {
            headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: bounds.width, height: headerViewHeight)
        } else {
            headerView = dataSource.headerViewForPageView(pageView: self)
            if let headerView = headerView as? UIView {
                addSubview(headerView)
                headerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: headerViewHeight)
            }
        }

        segmentViewHeight = segmentView?.getSegmentHeight() ?? 0
        segmentView?.reloadData()
        segmentView?.setSelectIndex(index: selectIndex)
        if let segmentView = segmentView as? UIView {
            segmentView.frame = CGRect(x: 0, y: (headerView as? UIView)?.frame.maxY ?? 0, width: bounds.width, height: segmentViewHeight)
        } else {
            segmentView = dataSource.segmentViewForPageView(pageView: self)
            if let segmentView = segmentView as? UIView {
                addSubview(segmentView)
                segmentView.frame = CGRect(x: 0, y: (headerView as? UIView)?.frame.maxY ?? 0, width: bounds.width, height: segmentViewHeight)
            }
        }

        if let count = subViews?.count, count == dataSource.numberOfViews(pageView: self), needForce == false {
            for view in subViews ?? [] {
                if let view = view as? UITableView {
                    view.contentInset = UIEdgeInsets(top: headerViewHeight + segmentViewHeight, left: 0, bottom: 0, right: 0)
                    view.reloadData()
                } else if let view = view as? UICollectionView {
                    view.contentInset = UIEdgeInsets(top: headerViewHeight + segmentViewHeight, left: 0, bottom: 0, right: 0)
                    view.reloadData()
                } else {
                    continue
                }
            }
        } else {
            subViews?.forEach({ (subView) in
                subView?.removeFromSuperview()
            })
            subViews?.removeAll()
            observationArray.removeAll()
            subViews = Array(repeating: nil, count: dataSource.numberOfViews(pageView: self))
        }

        if originTopView_height != headerViewHeight || originTitleBar_height != segmentViewHeight {//偏移量修正
            if let count = subViews?.count, selectIndex < count, let currentView = subViews?[selectIndex] {
                let fixHeight = originTopView_height + originTitleBar_height - headerViewHeight - segmentViewHeight
                if fixHeight < 0 {
                    currentView.contentOffset = CGPoint(x: currentView.contentOffset.x, y: currentView.contentOffset.y + fixHeight)
                }
            }
        }
        setNeedsLayout()
    }

    ///传递滚动事件
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitTestView = super.hitTest(point, with: event)

        if let view = hitTestView, selectIndex < (subViews?.count ?? 0), let selectedTableView = subViews?[selectIndex] {
            view.addGestureRecognizer(selectedTableView.panGestureRecognizer)
        }

        //屏蔽点击区域在头视图内的滚动事件
        if let header = headerView as? UIView {
            let point_in_header = convert(point, to: header)
            isScrollEnabled = point_in_header.y >= headerViewHeight
        }

        return hitTestView
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let headerView = headerView as? UIView {
            headerView.frame = CGRect(x: contentOffset.x, y: headerView.frame.origin.y, width: bounds.width, height: headerViewHeight)
        }

        if let segmentView = segmentView as? UIView {
            segmentView.frame = CGRect(x: contentOffset.x, y: segmentView.frame.origin.y, width: bounds.width, height: segmentViewHeight)
        }

        guard dataSource != nil else {
            return
        }
        guard let subViews = subViews, subViews.count != 0 else {
            return
        }

        contentSize = CGSize(width: CGFloat(subViews.count) * bounds.width, height: 0)

        //子控件高度\宽度重置
        for view in subViews {
            guard let view = view else {
                continue
            }
            view.frame.size.height = bounds.height - contentInset.top
            view.frame.size.width = bounds.width
        }
        addSubivew(index: selectIndex)
    }

    private func addSubivew(index: NSInteger) {
        guard index < (subViews?.count ?? 0) else {
            return
        }
        guard let dataSource = dataSource else {
            return
        }
        if subViews?[index] == nil {
            if index == 0 {
                segmentView?.setSelectIndex(index: index)
            }
            let subView = dataSource.pageView(pageView: self, index: index)
            if #available(iOS 11.0, *) {
                subView.contentInsetAdjustmentBehavior = .never
            }
            subView.frame = CGRect(x: CGFloat(index) * bounds.width, y: 0, width: bounds.width, height: bounds.height - contentInset.top)
            subView.contentInset = UIEdgeInsets(top: headerViewHeight + segmentViewHeight, left: 0, bottom: 0, right: 0)
            if let view = subViews?[fromIndex] {
                var subViewContentOffsetY = view.contentOffset.y
                if subViewContentOffsetY >= hoverOffsetY {//达到悬浮高度
                    subViewContentOffsetY = hoverOffsetY
                }
                subView.contentOffset = CGPoint(x: 0, y: subViewContentOffsetY)
            }

            addSubview(subView)
            subViews?[index] = subView
            if let subView = subView as? UITableView {
                subView.reloadData()
            } else if let subView = subView as? UICollectionView {
                subView.reloadData()
            }
            subView.tag = 101 + index
            addScrollObserve(view: subView)
        }
        if let headerView = headerView as? UIView {
            bringSubviewToFront(headerView)
        }
        if let segmentView = segmentView as? UIView {
            bringSubviewToFront(segmentView)
        }
    }

    /// 添加纵向滚动监听、未悬停时同步子视图偏移量
    /// - Parameter view: 需要添加监听的视图
    private func addScrollObserve(view: UIScrollView) {

        let index = view.tag - 101

        let observation = view.observe(\.contentOffset) { (view, _) in

            //只处理正在滑动视图的事件
            guard index == self.selectIndex else {
                return
            }

            let changeY = view.contentOffset.y

            if changeY < self.hoverOffsetY {//未达到悬浮高度、头视图和标题视图跟随滚动

                self.shouldHover = false

                if let headerView = self.headerView as? UIView {
                    headerView.frame.origin.y = -changeY - self.segmentViewHeight - self.headerViewHeight
                }
                if let segmentView = self.segmentView as? UIView {
                    segmentView.frame.origin.y = -changeY - self.segmentViewHeight
                }

                //同步子视图偏移量
                guard let subViews = self.subViews else {
                    return
                }

                for (idx, view) in subViews.enumerated() {
                    guard idx != self.selectIndex else {
                        continue
                    }
                    if let view = view {
                        var contentOffSet_y = changeY
                        if contentOffSet_y >= self.hoverOffsetY {
                            contentOffSet_y = self.hoverOffsetY
                        }
                        view.contentOffset = CGPoint(x: view.contentOffset.x, y: contentOffSet_y)
                    }
                }
            } else {

                self.shouldHover = true

                if let headerView = self.headerView as? UIView {
                    headerView.frame.origin.y = -self.headerViewHeight + self.hoverHeight
                }
                if let segmentView = self.segmentView as? UIView {
                    segmentView.frame.origin.y = self.hoverHeight
                }
                //同步子视图偏移量
                guard let subViews = self.subViews else {
                    return
                }
                for (idx, view) in subViews.enumerated() {
                    guard idx != self.selectIndex else {
                        continue
                    }
                    if let view = view {
                        if view.contentOffset.y <= self.hoverOffsetY {
                            view.contentOffset.y = self.hoverOffsetY
                        }
                    }
                }
            }
        }
        observationArray.append(observation)
    }

    /// 滚动至顶部
    public func scrollToTop() {
        guard let currentView = subViews?[selectIndex] else {
            return
        }
        currentView.setContentOffset(CGPoint(x: 0, y: -headerViewHeight - segmentViewHeight), animated: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FYPageView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x.truncatingRemainder(dividingBy: bounds.width) == 0 {
            selectIndex = Int(scrollView.contentOffset.x) / Int(bounds.width)
        }
    }
}
