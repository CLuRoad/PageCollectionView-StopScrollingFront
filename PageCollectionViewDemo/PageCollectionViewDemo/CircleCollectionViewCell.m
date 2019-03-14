
//
//  CircleCollectionViewCell.m
//  PageCollectionViewDemo
//
//  Created by Caolu on 2019/3/13.
//  Copyright © 2019 RoadCompany. All rights reserved.
//

#import "CircleCollectionViewCell.h"

#define random(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:.95]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

@implementation CircleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    _circleButton = [[UIButton alloc] initWithFrame:self.bounds];
    _circleButton.center = self.contentView.center;
    [_circleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _circleButton.titleLabel.font = [UIFont systemFontOfSize:20];
    _circleButton.backgroundColor = randomColor;
    _circleButton.layer.cornerRadius = self.bounds.size.height / 2;
    _circleButton.layer.masksToBounds = YES;
    [self.contentView addSubview:_circleButton];
}



@end
