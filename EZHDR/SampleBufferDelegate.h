
@import AVFoundation;

@protocol ImageAnalysisDelegate <NSObject>
- (void)sampleBufferDidAnalyzeSampleWithDark:(CGFloat)dark light:(CGFloat)light;
@end

@interface SampleBufferDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

+ (instancetype)delegateWithImageAnalysisDelegate:(id<ImageAnalysisDelegate>)delegate;

@property (nonatomic, weak) id<ImageAnalysisDelegate> imageAnalysisDelegate;

@end
