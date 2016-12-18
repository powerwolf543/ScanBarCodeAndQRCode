//
//  ScanQRCodeViewController.m
//  ObjCScanBarCodeAndQRCode
//
//  Created by NixonShih on 2016/12/16.
//  Copyright © 2016年 Nixon. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "NDQRCodeMaskView.h"

@interface ScanQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
/** 讓使用者預覽掃描的結果 */
@property (weak, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
/** 偽遮罩 */
@property (strong, nonatomic) NDQRCodeMaskView *maskView;
@end

@implementation ScanQRCodeViewController {
    /** 掃瞄框與superView的間距 */
    CGFloat theSpacing;
    /** 掃瞄框的寬 */
    CGFloat scanRectWidth;
    /** 動畫的掃描線 */
    UIView *scanLine;
    /** 掃描線跟superView的間距 */
    NSLayoutConstraint *scanLineTopConstraint;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addMaskView];
    [self addSampleImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScan];
    [self startScanAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopScan];
    [self stopScanAnimation];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = [self previewLayerFrame];
}

#pragma mark - UI

/** 加上幫助使用者對準的遮罩 */
- (void)addMaskView {
    
    theSpacing = 30.f;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    scanRectWidth = screenWidth - theSpacing * 2;
    CGRect scanRect = CGRectMake(theSpacing, theSpacing, scanRectWidth, scanRectWidth);
    
    _maskView = [[NDQRCodeMaskView alloc] initWithScanFrame:scanRect];
    _maskView.snipeColor = [UIColor colorWithRed:53.f/255.f green:187.f/255.f blue:5.f/255.f alpha:1.f];
    _maskView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_maskView];
    _maskView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSDictionary *views = @{@"maskView":_maskView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[maskView]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[maskView]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
}

/** 加上掃描範例圖 */
- (void)addSampleImage {
    UIImageView *sampleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanQRCodeSample"]];
    [self.view addSubview:sampleImageView];
    sampleImageView.translatesAutoresizingMaskIntoConstraints = false;
    NSDictionary *views = @{@"sampleImageView":sampleImageView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sampleImageView]-(20)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [sampleImageView addConstraint:[NSLayoutConstraint constraintWithItem:sampleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:sampleImageView attribute:NSLayoutAttributeHeight multiplier:0.92f constant:0]];
    [sampleImageView addConstraint:[NSLayoutConstraint constraintWithItem:sampleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:160]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sampleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0]];
}

/** 加上動畫線的View */
- (void)addScanLine {
    scanLine = [UIView new];
    scanLine.backgroundColor = [UIColor colorWithRed:1.f green:0 blue:0 alpha:0.4];
    [self.view addSubview:scanLine];
    scanLine.translatesAutoresizingMaskIntoConstraints = false;
    
    NSDictionary *views = @{@"scanLine":scanLine};
    scanLineTopConstraint = [NSLayoutConstraint constraintWithItem:scanLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.f constant:theSpacing];
    [self.view addConstraint:scanLineTopConstraint];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[scanLine(2)]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%f)-[scanLine]-(%f)-|",theSpacing,theSpacing] options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    
    scanLine.layer.shadowColor = [UIColor redColor].CGColor;
    scanLine.layer.shadowOffset = CGSizeMake(0, 0);
    scanLine.layer.shadowRadius = 2;
    scanLine.layer.shadowOpacity = 1.f;
}

#pragma mark - Animation

/** 開始掃描線動畫 */
- (void)startScanAnimation {
    
    if (!scanLine) {
        [self addScanLine];
        [self.view layoutIfNeeded];
    }
    
    scanLineTopConstraint.constant += scanRectWidth;

    [UIView animateWithDuration:1.5f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            scanLineTopConstraint.constant = theSpacing;
        }else{
            [self stopScanAnimation];
            [self startScanAnimation];
        }
    }];
}

/** 停止掃描線動畫 */
- (void)stopScanAnimation {
    [scanLine removeFromSuperview];
    scanLine = nil;
}

#pragma mark - BarCode Scan

/** 對AVCaptureSession進行相關掃描所需的設置 */
- (void)captureSessionInitial {
    
    // 建立一個抓取Video的裝置
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // 讓抓取Video的裝置作為輸入端
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error || !input) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"無法使用相機功能" message:@"請到手機設定裡，開啟相機功能" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
        
        NSLog(@"%@", [error localizedDescription]);
        
        return;
    }
    
    _session = [AVCaptureSession new];
    [_session addInput:input];
    
    // 建立輸出端，將輸入端的資料解析過後拿到我們需要用的資料。
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    [_session addOutput:output];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 要先 addOutput 才能設定 MetadataObjectTypes 不然會 crash
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    _previewLayer = [self preparePreviewLayer];
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    // rectOfInterest 可以設定 AVCaptureMetadataOutput 解析的區域。
    // rectOfInterest 需要透過 metadataOutputRectOfInterestForRect 轉換成專屬座標。
    // 需要在 InputPortFormatDescriptionDidChangeNotification 的這個通知使用 metadataOutputRectOfInterestForRect，這樣才能精準的轉換座標。
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock: ^(NSNotification *_Nonnull note) {
                                                      
                                                      CGFloat outputRectWidth = self.view.frame.size.width;
                                                      // 這邊設定了一個較大的區域，可以幫助使用者更容易掃描到資訊。
                                                      CGRect outputRect = CGRectMake(0, 0, outputRectWidth, outputRectWidth);
                                                      output.rectOfInterest = [_previewLayer metadataOutputRectOfInterestForRect:outputRect];
                                                  }];
}

/** 開始掃描，並準備一切掃描開始所需做的事情。 */
- (void)startScan {
    [self captureSessionInitial];
    [_session startRunning];
}

/** 停止掃描，並移除一些相關的View。 */
- (void)stopScan {
    [_session stopRunning];
    _session = nil;
    [_previewLayer removeFromSuperlayer];
}

/** 建立讓使用者預覽相機畫面的 Layer */
- (AVCaptureVideoPreviewLayer*)preparePreviewLayer {
    AVCaptureVideoPreviewLayer *thePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    thePreviewLayer.frame = [self previewLayerFrame];
    thePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    return thePreviewLayer;
}

- (CGRect)previewLayerFrame {
    return self.view.bounds;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *detectionString = nil;
    
    if (!metadataObjects || metadataObjects.count == 0) return;
    
    for (AVMetadataObject *metadata in metadataObjects) {
        
        // 這邊我們只拿 AVMetadataObjectTypeQRCode 格式的資料。
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            //            NSLog(@"%@",detectionString);
            
            // Vibrate 震動
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            [self stopScanAnimation];
            
            // 暫停掃描
            [_session stopRunning];
            _previewLayer.connection.enabled = false;
            
            // 簡單的用alert來呈現掃描到的結果
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"掃到了拉" message:detectionString preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                // 按完確定之後繼續掃描
                _previewLayer.connection.enabled = true;
                [_session startRunning];
                
                [self startScanAnimation];
            }]];
            
            [self presentViewController:alert animated:true completion:nil];
            
            break;
        }
    }
    
}

@end
