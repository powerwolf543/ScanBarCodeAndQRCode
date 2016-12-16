//
//  BarCodeViewController.m
//  PracticeThreeBarCode
//
//  Created by NixonShih on 2016/11/29.
//  Copyright © 2016年 Nixon. All rights reserved.
//

/*
 在台灣常常會遇到三個條碼放在一起的繳費單，
 但是有時候我們只需要其中一條就可以判斷出完整的資訊，
 這個範例的遮罩中有三個可以掃描的區域，
 雖然我們只要其中一個條碼，
 但是這樣可以幫助使用者可容易找到他需要掃描的區域。
 */

#import "BarCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "NDBarCodeMaskView.h"

@interface BarCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
/** 讓使用者預覽掃描的結果 */
@property (weak, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
/** 偽遮罩 */
@property (strong, nonatomic) NDBarCodeMaskView *maskView;
@end

static NSUInteger kVaildBarcodeLength = 16;

@implementation BarCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addMaskView];
    [self addSampleImage];
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
    
    _maskView = [[NDBarCodeMaskView alloc] initWithScanPosition:CGPointMake(10, 36)];
    _maskView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_maskView];
    _maskView.translatesAutoresizingMaskIntoConstraints = false;
    
    NSDictionary *views = @{@"maskView":_maskView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[maskView]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[maskView]-(0)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
}

/** 加上掃描範例圖 */
- (void)addSampleImage {
    UIImageView *sampleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanBarCodeSample"]];
    [self.view addSubview:sampleImageView];
    sampleImageView.translatesAutoresizingMaskIntoConstraints = false;
    NSDictionary *views = @{@"sampleImageView":sampleImageView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sampleImageView]-(30)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[sampleImageView]-(20)-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:views]];
    [sampleImageView addConstraint:[NSLayoutConstraint constraintWithItem:sampleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:sampleImageView attribute:NSLayoutAttributeHeight multiplier:1.6f constant:0]];
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
    
    // rectOfInterest 可以設定 AVCaptureMetadataOutput 解析的區域。
    // rectOfInterest 需要透過 metadataOutputRectOfInterestForRect 轉換成專屬座標。
    // 需要在 InputPortFormatDescriptionDidChangeNotification 的這個通知使用 metadataOutputRectOfInterestForRect，這樣才能精準的轉換座標。
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue currentQueue]
                                                  usingBlock: ^(NSNotification *_Nonnull note) {
                                                      
                                                      CGFloat outputRectWidth = self.view.frame.size.width;
                                                      // 這邊設定了一個較大的區域，可以幫助使用者更容易掃描到資訊。
                                                      CGRect outputRect = CGRectMake(0, 91, outputRectWidth, 60);
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

        // 這邊我們只拿 AVMetadataObjectTypeCode39Code 格式的資料。
        if ([metadata.type isEqualToString:AVMetadataObjectTypeCode39Code])
        {
//            AVMetadataMachineReadableCodeObject *barCodeObject = (AVMetadataMachineReadableCodeObject *)[_previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
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
