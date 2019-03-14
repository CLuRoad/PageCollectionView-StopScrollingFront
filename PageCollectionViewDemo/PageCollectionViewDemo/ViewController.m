//
//  ViewController.m
//  PageCollectionViewDemo
//
//  Created by Caolu on 2019/3/13.
//  Copyright © 2019 RoadCompany. All rights reserved.
//

#import "ViewController.h"
#import "CircleCollectionViewCell.h"
#import "MyCollectionFlowLayout.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate> {
    // items个数
    NSInteger _itemsCount;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _itemsCount = 6;
    
    MyCollectionFlowLayout *layout = [[MyCollectionFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 100) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor colorWithWhite:0 alpha:.05];
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast;

    [collectionView registerClass:CircleCollectionViewCell.class forCellWithReuseIdentifier:@"CircleCollectionViewCell"];
        collectionView.pagingEnabled = YES;
    _collectionView = collectionView;
    [self.view addSubview:_collectionView];
    
}

#pragma mark ---- private method
- (IBAction)reduceItem:(id)sender {
    _itemsCount = MAX(_itemsCount - 1,0 );
    [self.collectionView reloadData];
}

- (IBAction)increaseItem:(id)sender {
    _itemsCount ++;
    [self.collectionView reloadData];
}

#pragma mark --- UICollectionViewDatasouce
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _itemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CircleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CircleCollectionViewCell" forIndexPath:indexPath];
    [cell.circleButton setTitle:[NSString stringWithFormat:@"%ld", indexPath.row + 1] forState:UIControlStateNormal];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"---- %lf", scrollView.contentOffset.x);
}


@end
