//
//  ViewController.m
//  ObjCScanBarCodeAndQRCode
//
//  Created by NixonShih on 2016/12/19.
//  Copyright © 2016年 Nixon. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *barCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *qrCodeButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 清除回上一頁按鈕的Text（只出現 < )
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    [self.view layoutIfNeeded];
    _barCodeButton.layer.cornerRadius = _barCodeButton.bounds.size.width / 2;
    _qrCodeButton.layer.cornerRadius = _qrCodeButton.bounds.size.width / 2;
}

@end
