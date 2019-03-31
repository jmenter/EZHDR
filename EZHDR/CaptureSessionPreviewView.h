
@import UIKit;

@class AVCaptureSession;

@interface CaptureSessionPreviewView : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic) AVCaptureSession *session;

@end
