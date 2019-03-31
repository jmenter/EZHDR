
#import "CIImage+Extras.h"

@implementation CIImage (Extras)

- (CIImage *)autoAdjustedImage;
{
    CIImage *inputImage = self;
    CIImage *outputImage;
    
    for (CIFilter *filter in self.autoAdjustmentFilters) {
        [filter setValue:inputImage forKey:@"inputImage"];
        outputImage = filter.outputImage;
        inputImage = outputImage ?: inputImage;
    }
    return outputImage ?: inputImage;
}

- (CIImage *)greyscaleImage;
{
    return [self imageByApplyingFilter:@"CIPhotoEffectMono"];
}

- (CIImage *)invertedImage;
{
    return [self imageByApplyingFilter:@"CIColorInvert"];
}

- (CIImage *)boxBlurredWithRadius:(CGFloat)radius;
{
    return [self imageByApplyingFilter:@"CIBoxBlur" withInputParameters:@{@"inputRadius" : @(radius)}];
}

- (CIImage *)blendedWithImage:(CIImage *)image mask:(CIImage *)mask;
{
    return [image imageByApplyingFilter:@"CIBlendWithMask" withInputParameters:@{@"inputBackgroundImage" : self, @"inputMaskImage" : mask}];
}

@end
