//
//  UIView+Frame.m
//  JuJuSports
//
//  Created by Jame on 15-3-31.
//  Copyright (c) 2015年 Cache. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)

//获取view的高
- (CGFloat)viewHeight {
    return self.bounds.size.height;
}
//获取view的宽
- (CGFloat)viewWidth {
    return self.bounds.size.width;
}
//获取view的左上角x
- (CGFloat)viewX {
    return self.frame.origin.x;
}
//获取view的y
- (CGFloat)viewY {
    return self.frame.origin.y;
}

@end
