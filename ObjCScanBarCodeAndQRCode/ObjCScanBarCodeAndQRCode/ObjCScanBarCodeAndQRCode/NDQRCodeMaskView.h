//
//  NDQRCodeMaskView.h
//  ObjCScanBarCodeAndQRCode
//
//  Created by NixonShih on 2016/12/16.
//  Copyright © 2016年 Nixon. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 幫助使用者對準的QRCODE遮罩 */
@interface NDQRCodeMaskView : UIView
/** 遮罩顏色，預設值為黑色 alpha 0.5。 */
@property (strong, nonatomic) UIColor *maskColor;
/** 掃描框框四個角落瞄準線的寬度，預設值為5。 */
@property (assign, nonatomic) CGFloat snipeWidth;
/** 掃描框框四個角落瞄準線的長度，預設值為15。 */
@property (assign, nonatomic) CGFloat snipeLineLong;
/** 掃描框框四個角落瞄準線的顏色，預設值為白色。 */
@property (strong, nonatomic) UIColor *snipeColor;
/** 掃瞄框的大小與位置 */
@property (assign, nonatomic, readonly) CGRect scanFrame;

/** 更新整個遮罩 */
- (void)refreshView;
/**
 初始化 NDQRCodeMaskView
 @param scanFrame 掃描框框的位置與大小
 @return (NDQRCodeMaskView*) NDQRCodeMaskView's Instance
 */
- (instancetype)initWithScanFrame:(CGRect)scanFrame;
/**
 初始化 NDQRCodeMaskView
 @param frame NDQRCodeMaskView's Instance frame
 @param scanFrame 掃描框框的位置與大小
 @return (NDQRCodeMaskView*) NDQRCodeMaskView's Instance
 */
- (instancetype)initWithFrame:(CGRect)frame scanFrame:(CGRect)scanFrame;
@end
