
@import AVFoundation;
#import "CaptureSessionPreviewView.h"

@implementation CaptureSessionPreviewView

+ (Class)layerClass; { return AVCaptureVideoPreviewLayer.class; }
- (AVCaptureVideoPreviewLayer*)videoPreviewLayer; { return (AVCaptureVideoPreviewLayer *)self.layer; }
- (AVCaptureSession*)session; { return self.videoPreviewLayer.session; }
- (void)setSession:(AVCaptureSession*)session; { self.videoPreviewLayer.session = session; }

@end
