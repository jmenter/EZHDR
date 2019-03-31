
@import AVFoundation;

@protocol ImageAnalysisDelegate <NSObject>
- (void)sampleBufferDidAnalyzeSampleWithDark:(CGFloat)dark light:(CGFloat)light;
@end

/*!
 @class SampleBufferDelegate
 @abstract
 SampleBufferDelegate implements AVCaptureVideoDataOutputSampleBufferDelegate and performs a basic image analysis of the pixels that are captured.
 
 @discussion
 SampleBufferDelegate will take the sample buffer from a video output and perform a basic image analysis of the pixels that are in the buffer. The "analysis" simply reduces the image to a 10px by 10px collection of pixels and sorts them into "dark" (brightness < 16) and "light" (brightness > 239) pixels. It then calls the ImageAnalysisDelegate and reports the percentage of "dark" and "light" pixels in the image. This will give you a good estimate of the extent of under and over exposed areas of the image.
 */

@interface SampleBufferDelegate : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

+ (instancetype)delegateWithImageAnalysisDelegate:(id<ImageAnalysisDelegate>)delegate;

@property (nonatomic, weak) id<ImageAnalysisDelegate> imageAnalysisDelegate;

@end
