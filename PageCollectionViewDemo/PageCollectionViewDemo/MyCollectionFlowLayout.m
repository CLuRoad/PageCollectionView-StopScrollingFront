//
//  MyCollectionFlowLayout.m
//  PageCollectionViewDemo
//
//  Created by Caolu on 2019/3/13.
//  Copyright © 2019 RoadCompany. All rights reserved.
//

#import "MyCollectionFlowLayout.h"

static CGFloat const kItemWidth = 70.f;     // item宽高
static CGFloat const kPaddingMid = 30.f;    // item间距
static CGFloat const kPaddingLeft = 20.f;   // 最左边item左边距


@interface MyCollectionFlowLayout()<UIScrollViewDelegate, UICollectionViewDelegate> {
    NSInteger _pageCapacity;    // 每页可以完整展示的item个数
    NSInteger _currentIndex;    // 当前页码（滑动前）
}

@end

@implementation MyCollectionFlowLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    self.collectionView.delegate = self;
    
    // 计算paddingRight
    CGFloat paddingRight = 0.0;
    
    // item个数
    // collectionView调用reloadData后，layout会重新prepareLayout
    NSInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    // item间距
    self.minimumInteritemSpacing = kPaddingMid;
    self.minimumLineSpacing = kPaddingMid;
    self.itemSize = CGSizeMake(kItemWidth, kItemWidth);
    
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    
    // 每页可以完整显示的items个数
    NSInteger pageCapacity = (NSInteger)(collectionViewWidth - kPaddingLeft + kPaddingMid) / (NSInteger)(kItemWidth + kPaddingMid);
    _pageCapacity = pageCapacity;
    
    // 完整显示所有items的总页数
    NSInteger pages = itemsCount / pageCapacity;
    NSInteger remainder = itemsCount % pageCapacity;
    if (remainder == 0) {
        paddingRight = collectionViewWidth - pageCapacity * (kItemWidth + kPaddingMid) + kPaddingMid - kPaddingLeft;
    } else {
        paddingRight = collectionViewWidth - remainder * (kItemWidth + kPaddingMid) + kPaddingMid - kPaddingLeft;
        pages ++;
    }
    
    // padding top bottom
    CGFloat paddingVertical = (CGRectGetHeight(self.collectionView.bounds) - kItemWidth) / 2;
    self.sectionInset = UIEdgeInsetsMake(paddingVertical, kPaddingLeft, paddingVertical, paddingRight);
    
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    NSInteger index = (NSInteger)proposedContentOffset.x / (NSInteger)(_pageCapacity * (kItemWidth + kPaddingMid));

    NSInteger remainder = (NSInteger)proposedContentOffset.x % (NSInteger)(_pageCapacity * (kItemWidth + kPaddingMid));

    if (remainder > 10 && velocity.x > 0.3) {
        index ++;
    }

    if (velocity.x < -0.3 && index > 0) {
        index --;
    }
    
    // 保证一次只滑动一页
    index = MAX(index, _currentIndex - 1);
    index = MIN(index, _currentIndex + 1);

    CGPoint point = CGPointMake(0, 0);
    if (index > 0) {
        point.x = index * _pageCapacity * (kItemWidth + kPaddingMid);
    }

    return point;
}

#pragma mark --- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _currentIndex = (NSInteger)scrollView.contentOffset.x / (NSInteger)(_pageCapacity * (kItemWidth + kPaddingMid));
}

@end
