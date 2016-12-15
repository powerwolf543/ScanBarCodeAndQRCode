//
//  BarCodeMaskView.h
//  PracticeThreeBarCode
//
//  Created by NixonShih on 2016/12/14.
//  Copyright © 2016年 Nixon. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 偽掃描三個條碼的遮罩 */
@interface BarCodeMaskView : UIView
/** 遮罩顏色 */
@property (strong, nonatomic) UIColor *maskColor;
/** 掃描框框的高度 */
@property (assign, nonatomic) CGFloat rowHeight;
/** 掃描框框四個角落瞄準線的寬度 */
@property (assign, nonatomic) CGFloat snipeWidth;
/** 掃描框框四個角落瞄準線的長度 */
@property (assign, nonatomic) CGFloat snipeLineLong;
/** 掃描框框四個角落瞄準線的顏色 */
@property (strong, nonatomic) UIColor *snipeColor;
/** 更新整個遮罩 */
- (void)refreshView;
/**
 初始化 BarCodeMaskView
 @param scanPosition 掃描框框的位置
 @return (BarCodeMaskView*) BarCodeMaskView's Instance
 */
- (instancetype)initWithScanPosition:(CGPoint)scanPosition;
/**
 初始化 BarCodeMaskView
 @param frame BarCodeMaskView's Instance frame
 @param scanPosition 掃描框框的位置
 @return (BarCodeMaskView*) BarCodeMaskView's Instance
 */
- (instancetype)initWithFrame:(CGRect)frame position:(CGPoint)theScanPosition;
@end
