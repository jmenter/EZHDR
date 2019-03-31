
@import CoreImage;

@interface CIImage (Extras)

- (CIImage *)autoAdjustedImage;
- (CIImage *)greyscaleImage;
- (CIImage *)invertedImage;
- (CIImage *)boxBlurredWithRadius:(CGFloat)radius;
- (CIImage *)blendedWithImage:(CIImage *)image mask:(CIImage *)mask;

@end
