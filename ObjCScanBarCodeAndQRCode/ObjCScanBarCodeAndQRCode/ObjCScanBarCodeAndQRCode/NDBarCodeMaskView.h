//
//  BarCodeMaskView.h
//  PracticeThreeBarCode
//
//  Created by NixonShih on 2016/12/14.
//  Copyright © 2016年 Nixon. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 幫助使用者對準的三個條碼遮罩 */
@interface NDBarCodeMaskView : UIView
/** 遮罩顏色，預設值為黑色 alpha 0.5。 */
@property (strong, nonatomic) UIColor *maskColor;
/** 掃描框框的高度，預設值為50。 */
@property (assign, nonatomic) CGFloat rowHeight;
/** 掃描框框四個角落瞄準線的寬度，預設值為5。 */
@property (assign, nonatomic) CGFloat snipeWidth;
/** 掃描框框四個角落瞄準線的長度，預設值為15。 */
@property (assign, nonatomic) CGFloat snipeLineLong;
/** 掃描框框四個角落瞄準線的顏色，預設值為白色。 */
@property (strong, nonatomic) UIColor *snipeColor;

@property (assign, nonatomic, readonly) CGRect rowOneFrame;
@property (assign, nonatomic, readonly) CGRect rowTwoFrame;
@property (assign, nonatomic, readonly) CGRect rowThreeFrame;

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
 @param theScanPosition 掃描框框的位置
 @return (BarCodeMaskView*) BarCodeMaskView's Instance
 */
- (instancetype)initWithFrame:(CGRect)frame position:(CGPoint)theScanPosition;
@end
