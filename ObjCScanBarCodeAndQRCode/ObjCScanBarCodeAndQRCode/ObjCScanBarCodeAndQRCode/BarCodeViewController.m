//
//  BarCodeViewController.m
//  PracticeThreeBarCode
//
//  Created by NixonShih on 2016/11/29.
//  Copyright © 2016年 Nixon. All rights reserved.
//

#import "BarCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "BarCodeMaskView.h"

@interface BarCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) BarCodeMaskView *maskView;
@end

static NSUInteger kVaildBarcodeLength = 16;

@implementation BarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addMaskView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startScan];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopScan];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _previewLayer.frame = [self previewLayerFrame];
}

#pragma mark - UI

/** 加上幫助使用者對準的遮罩 */
- (void)addMaskView {
    
    _maskView = [[BarCodeMaskView alloc] initWithScanPosition:CGPointMake(10, 36)];
    _maskView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_maskView];
    _maskView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSDictionary *views = @{@"maskView":_maskView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[maskView]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[maskView]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
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
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code]];
    
    _previewLayer = [self preparePreviewLayer];
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    

    CGSize maskViewSize = self.view.bounds.size;
    CGRect rect = CGRectMake(0, 155 - 64, maskViewSize.width, 60);
    CGRect intertRect = [_previewLayer metadataOutputRectOfInterestForRect:rect];
    
    output.rectOfInterest = intertRect;
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
    CGRect highlightViewRect = CGRectZero;
    NSString *detectionString = nil;

    if (!metadataObjects || metadataObjects.count == 0) return;
    
    for (AVMetadataObject *metadata in metadataObjects) {

        if ([metadata.type isEqualToString:AVMetadataObjectTypeCode39Code])
        {
            AVMetadataMachineReadableCodeObject *barCodeObject = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
            highlightViewRect = barCodeObject.bounds;
            detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
//            NSLog(@"%@",detectionString);

            // 藉由掃描到的條碼文字長度來判斷是否是我們所需要的
            if (detectionString.length == kVaildBarcodeLength) {
                // Vibrate 震動
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
                // 暫停掃描
                [_session stopRunning];
                _previewLayer.connection.enabled = false;
                
                // 簡單的用alert來呈現掃描到的結果
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"掃到了拉" message:detectionString preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    // 按完確定之後繼續掃描
                    _previewLayer.connection.enabled = true;
                    [_session startRunning];
                }]];
                
                [self presentViewController:alert animated:true completion:nil];
                
                break;
            }
        }
    }
    
}

@end
