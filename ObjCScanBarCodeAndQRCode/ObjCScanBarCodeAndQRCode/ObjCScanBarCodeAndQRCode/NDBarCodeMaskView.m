//
//  BarCodeMaskView.m
//  PracticeThreeBarCode
//
//  Created by NixonShih on 2016/12/14.
//  Copyright © 2016年 Nixon. All rights reserved.
//

#import "NDBarCodeMaskView.h"

@implementation NDBarCodeMaskView {
    /** 放四個角落的對準線 */
    NSMutableArray<CAShapeLayer*> *snipeLines;
    /** 遮罩的layer */
    CAShapeLayer *maskLayer;
}

- (instancetype)initWithScanPosition:(CGPoint)theScanPosition {
    
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        _scanPosition = theScanPosition;
        [self defaulteSetting];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame position:(CGPoint)theScanPosition {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _scanPosition = theScanPosition;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self prepareMaskLayer];
}

- (void)refreshView {
    [self prepareMaskLayer];
}

#pragma mark - private methods

/** 初始設定值 */
- (void)defaulteSetting {
    _maskColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
    _rowHeight = 50.f;
    _snipeWidth = 5.f;
    _snipeLineLong = 15.f;
    _snipeColor = [UIColor whiteColor];
}

- (void)prepareMaskLayer {
    
    [maskLayer removeFromSuperlayer];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.frame];
    
    _rowOneFrame = CGRectMake(_scanPosition.x,
                              _scanPosition.y,
                              self.frame.size.width - _scanPosition.x * 2,
                              _rowHeight);
    _rowTwoFrame = CGRectMake(_scanPosition.x,
                              _scanPosition.y + _rowHeight + 10,
                              self.frame.size.width - _scanPosition.x * 2,
                              _rowHeight);
    _rowThreeFrame = CGRectMake(_scanPosition.x,
                                _scanPosition.y + _rowHeight * 2 + 10 * 2,
                                self.frame.size.width - _scanPosition.x * 2,
                                _rowHeight);
    
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:_rowOneFrame cornerRadius:1] bezierPathByReversingPath]];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:_rowTwoFrame cornerRadius:1] bezierPathByReversingPath]];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:_rowThreeFrame cornerRadius:1] bezierPathByReversingPath]];
    
    for (CAShapeLayer *theSnipeLine in snipeLines) {
        [theSnipeLine removeFromSuperlayer];
    }
    
    snipeLines = [NSMutableArray new];
    
    [self prepareBorderWithScanFrame:_rowOneFrame];
    [self prepareBorderWithScanFrame:_rowTwoFrame];
    [self prepareBorderWithScanFrame:_rowThreeFrame];
    
    [self prepareSnipeLayerWithFrame:_rowOneFrame];
    [self prepareSnipeLayerWithFrame:_rowTwoFrame];
    [self prepareSnipeLayerWithFrame:_rowThreeFrame];
    
    
    maskLayer = [CAShapeLayer new];
    maskLayer.fillColor = _maskColor.CGColor;
    maskLayer.path = maskPath.CGPath;
    
    [self.layer addSublayer:maskLayer];
}

- (void)prepareBorderWithScanFrame:(CGRect)theScanFrame {
    
    CGRect theBorderFrame = CGRectMake(theScanFrame.origin.x + 0.5, theScanFrame.origin.y + 0.5, theScanFrame.size.width - 1, theScanFrame.size.height - 1);
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRect:theBorderFrame];
    
    CAShapeLayer *borderLayer = [CAShapeLayer new];
    borderLayer.strokeColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.3f].CGColor;
    borderLayer.lineWidth = .5f;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.path = borderPath.CGPath;
    
    [self.layer addSublayer:borderLayer];
}

/** 繪出四個角落的對準線 */
- (void)prepareSnipeLayerWithFrame:(CGRect)snipeFrame {
    
    UIBezierPath *topLeftPath = [UIBezierPath new];
    CGPoint topLeftPoint = CGPointMake(snipeFrame.origin.x + _snipeWidth / 2, snipeFrame.origin.y + _snipeWidth / 2);
    [topLeftPath moveToPoint:CGPointMake(topLeftPoint.x, topLeftPoint.y + _snipeLineLong)];
    [topLeftPath addLineToPoint:CGPointMake(topLeftPoint.x, topLeftPoint.y)];
    [topLeftPath addLineToPoint:CGPointMake(topLeftPoint.x + _snipeLineLong, topLeftPoint.y)];
    
    CAShapeLayer *topLeft = [CAShapeLayer new];
    topLeft.path = topLeftPath.CGPath;
    [self setAttributesWithSnipeLine:topLeft];
    [self.layer addSublayer:topLeft];
    
    UIBezierPath *topRightPath = [UIBezierPath new];
    CGPoint topRightPoint = CGPointMake(snipeFrame.origin.x + snipeFrame.size.width - _snipeWidth / 2, snipeFrame.origin.y + _snipeWidth / 2);
    [topRightPath moveToPoint:CGPointMake(topRightPoint.x, topRightPoint.y + _snipeLineLong)];
    [topRightPath addLineToPoint:CGPointMake(topRightPoint.x, topRightPoint.y)];
    [topRightPath addLineToPoint:CGPointMake(topRightPoint.x - _snipeLineLong, topRightPoint.y)];
    
    CAShapeLayer *topRight = [CAShapeLayer new];
    topRight.path = topRightPath.CGPath;
    [self setAttributesWithSnipeLine:topRight];
    [self.layer addSublayer:topRight];
    
    UIBezierPath *bottomLeftPath = [UIBezierPath new];
    CGPoint bottomLeftPoint = CGPointMake(snipeFrame.origin.x + _snipeWidth / 2, snipeFrame.origin.y + snipeFrame.size.height - _snipeWidth / 2);
    [bottomLeftPath moveToPoint:CGPointMake(bottomLeftPoint.x, bottomLeftPoint.y - _snipeLineLong)];
    [bottomLeftPath addLineToPoint:CGPointMake(bottomLeftPoint.x, bottomLeftPoint.y)];
    [bottomLeftPath addLineToPoint:CGPointMake(bottomLeftPoint.x + _snipeLineLong, bottomLeftPoint.y)];
    
    CAShapeLayer *bottomLeft = [CAShapeLayer new];
    bottomLeft.path = bottomLeftPath.CGPath;
    [self setAttributesWithSnipeLine:bottomLeft];
    [self.layer addSublayer:bottomLeft];
    
    UIBezierPath *bottomRightPath = [UIBezierPath new];
    CGPoint bottomRightPoint = CGPointMake(snipeFrame.origin.x + snipeFrame.size.width - _snipeWidth / 2, snipeFrame.origin.y + snipeFrame.size.height - _snipeWidth / 2);
    [bottomRightPath moveToPoint:CGPointMake(bottomRightPoint.x, bottomRightPoint.y - _snipeLineLong)];
    [bottomRightPath addLineToPoint:CGPointMake(bottomRightPoint.x, bottomLeftPoint.y)];
    [bottomRightPath addLineToPoint:CGPointMake(bottomRightPoint.x - _snipeLineLong, bottomRightPoint.y)];
    
    CAShapeLayer *bottomRight = [CAShapeLayer new];
    bottomRight.path = bottomRightPath.CGPath;
    [self setAttributesWithSnipeLine:bottomRight];
    [self.layer addSublayer:bottomRight];
    
    [snipeLines addObjectsFromArray:@[topLeft,topRight,bottomLeft,bottomRight]];
}

- (void)setAttributesWithSnipeLine:(CAShapeLayer*)snipeLine {
    snipeLine.strokeColor = _snipeColor.CGColor;
    snipeLine.fillColor = [UIColor clearColor].CGColor;
    snipeLine.lineWidth = _snipeWidth;
}

@end
