
#import "SampleBufferDelegate.h"

@implementation SampleBufferDelegate

+ (instancetype)delegateWithImageAnalysisDelegate:(id<ImageAnalysisDelegate>)delegate;
{
    SampleBufferDelegate *sbDelegate = SampleBufferDelegate.new;
    sbDelegate.imageAnalysisDelegate = delegate;
    return sbDelegate;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    uint8_t *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    
    size_t horizontalStride = width / 10;
    size_t verticalStride = height / 10;
    
    int darkPixelCount = 0;
    int lightPixelCount = 0;
    int totalPixelCount = 0;
    int threshold = 16;
    for (int y = 0; y < height; y += verticalStride) {
        for (int x = 0; x < width; x += horizontalStride) {
            size_t index = (y * bytesPerRow) + x;
            uint8_t pixelValue = baseAddress[index];
            if (pixelValue < threshold) {
                darkPixelCount ++;
            } else if (pixelValue > 255 - threshold) {
                lightPixelCount ++;
            }
            totalPixelCount++;
        }
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageAnalysisDelegate sampleBufferDidAnalyzeSampleWithDark:((float)darkPixelCount / (float)totalPixelCount) light:((float)lightPixelCount / (float)totalPixelCount)];
    });
}

@end
