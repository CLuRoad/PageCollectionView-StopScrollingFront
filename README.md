# PageCollectionViewstop-StopScrollingFront

**这个标题挺难起的：**
> UICollectionView设置翻页区域？
> UICollectionView依据items翻页，而不是屏幕宽度？
> UICollectionView每一页开头第一个item不被切割，并且左间距固定？
。。。

**直接看效果：**
![第一页item4未展示全，第二页从item4开始](https://upload-images.jianshu.io/upload_images/5994062-9c0aee0888290a72.GIF?imageMogr2/auto-orient/strip)

**比较一下直接设置`collectionView.pagingEnabled = YES`的效果：**
![第一页item4展示一部分，第二页展示item4剩下部分](https://upload-images.jianshu.io/upload_images/5994062-a18b73aad8adfe1a.GIF?imageMogr2/auto-orient/strip)

# Code
源码在[GitHub](https://github.com/CLuRoad/PageCollectionViewstop-StopScrollingFront)，item的宽度和间距使用宏定义，方便修改

# 关键步骤
#### 一、新建UICollectionViewFlowLayout 子类，自定义滑动位置 
`- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity;`
> Discussion
If you want the scrolling behavior to snap to specific boundaries, you can override this method and use it to change the point at which to stop. For example, you might use this method to always **stop scrolling on a boundary between items, as opposed to stopping in the middle of an item.**

首先，`proposedContentOffset`参数的含义是系统根据用户的滑动手势计算出来的将要滑动到的目标位置。
我们可以在`UICollectionViewFlowLayout`的子类里重写这个方法，根据系统计算出来的期望目标位置`proposedContentOffset `和滑动速度`velocity `，自定义滑动位置。

##### 1. 新建`UICollectionViewFlowLayout`的子类`MyCollectionFlowLayout`
将item有关参数设置为宏，方便修改
```
#import "MyCollectionFlowLayout.h"

static CGFloat const kItemWidth = 70.f;     // item宽高
static CGFloat const kPaddingMid = 30.f;    // item间距
static CGFloat const kPaddingLeft = 20.f;   // 最左边item左边距


@interface MyCollectionFlowLayout()<UIScrollViewDelegate, UICollectionViewDelegate> {
    NSInteger _pageCapacity;    // 每页可以完整展示的item个数
    NSInteger _currentIndex;    // 当前页码（滑动前）
}

@end
```
##### 2. 重写`- (void)prepareLayout`方法，设置`sectionInset`右缩进
在这个方法里，需要计算：
1. 每页可以完整显示的items个数
2. 完整显示所有items的总页数
3. 最后一页item从左边开始，那右边的剩余空间有多少？即`sectionInset`右缩进

```
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
```

##### 3. 重写`- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity`方法
重写这个方法就可以指定滑动停止的位置，我的计算思路是先根据用户的滑动手势，判断是向前翻页还是向后翻页，向后翻页则目标页码`index = _currentIndex + 1`。 翻页时，实际的页面宽度是每页刚好可以完整展示的最多个item的宽度，即`_pageCapacity * (kItemWidth + kPaddingMid)`，那么x轴目标偏移就是`point.x = 目标页码 * 每页实际宽度`
这里需要知道滑动前当前的页码`_currentIndex`， 我是通过`UIScrollViewDelegate`的代理方法取到用户将要滑动时的x轴偏移计算的
```
#pragma mark --- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _currentIndex = (NSInteger)(scrollView.contentOffset.x ) / (NSInteger)(_pageCapacity * (kItemWidth + kPaddingMid));
}
```
```
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
```


#### 二、 不使用系统pagingEnabled
文章开头已说明，设置`scrollView.pagingEnabled = YES `达不到我们的目标，本文介绍的方案里需要设置`scrollView.pagingEnabled = NO`，否则上面函数中自定义的滑动位置不起作用


#### 三、 尽量还原pagingEnabled效果
设置`scrollView.decelerationRate = UIScrollViewDecelerationRateFast;`,滑动效果基本接近系统pagingEnabled
 

运行起来后简单测试，需求基本满足了
![](https://upload-images.jianshu.io/upload_images/5994062-bcc857396186694e.GIF?imageMogr2/auto-orient/strip)

#### 四、有两个bug
###### 1. 滑动有时会卡顿
![第二页第一次向后翻页时，卡一下](https://upload-images.jianshu.io/upload_images/5994062-1c464d0ee9490efb.GIF?imageMogr2/auto-orient/strip)
###### 2. 从后往前翻页时，有时会连续翻两页
![第三页向前翻页时，直接翻到了第一页](https://upload-images.jianshu.io/upload_images/5994062-08209c3a72d7b331.GIF?imageMogr2/auto-orient/strip)

###### 3. 检查出错原因，在`MyCollectionFlowLayout.m`文件里加上日志
```
#pragma mark --- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _currentIndex = (NSInteger)(scrollView.contentOffset.x) / (NSInteger)(_pageCapacity * (kItemWidth + kPaddingMid));
    NSLog(@"\n\n---------------------");
    NSLog(@"1. 预期每页内容宽度 %ld",(NSInteger)(_pageCapacity * (kItemWidth + kPaddingMid)));
    NSLog(@"2. 滑动前的x轴偏移 %ld",(NSInteger)(scrollView.contentOffset.x));
    NSLog(@"3. 滑动前当前页码 %ld",_currentIndex);
}
```
![log.png](https://upload-images.jianshu.io/upload_images/5994062-54f4dd73900c9b62.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
从打印日志发现从第一页翻到第二页，然后（未等滑动完全停止）继续滑动时，x轴偏移量比目标偏移量小几个像素，即滑动还没有完全结束。由于当前页的index是通过x轴偏移量取整求商得到的，这几个像素的差异会导致index比预期小1

###### 4. 解决方法
在计算当前的页码`_currentIndex`时，用一个item的宽度补偿x轴偏移量，由于`kItemWidth`恒小于`_pageCapacity * (kItemWidth + kPaddingMid)`，这种补偿不会造成页面index加1，是安全的
```
#pragma mark --- UIScrollViewDelegate
- (**void**)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    */**
** 分子scrollView.contentOffset.x为什么要+kItemWidth ？？*
** 消除scrollView在摆动的时候的误差，此时contentOffset.x比预期减少了10左右像素，导致_currentIndex比预期小1*
**/*
    _currentIndex = (NSInteger)(scrollView.contentOffset.x + kItemWidth) / (NSInteger)(_pageCapacity * (kItemWidth + kPaddingMid));
}
```



