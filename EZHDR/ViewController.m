
@import AVFoundation;
#import "ViewController.h"
#import "CaptureSessionPreviewView.h"
#import "SampleBufferDelegate.h"
#import "SplitImageView.h"
#import "CIImage+Extras.h"

@interface ViewController () <AVCapturePhotoCaptureDelegate, ImageAnalysisDelegate>
@property (weak, nonatomic) IBOutlet CaptureSessionPreviewView *previewView;
@property (weak, nonatomic) IBOutlet SplitImageView *splitImageView;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDevice *device;
@property (nonatomic) AVCapturePhotoOutput* photoOutput;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) NSMutableArray <AVCapturePhoto *> *capturedPhotos;
@property (weak, nonatomic) IBOutlet UISegmentedControl *evControl;
@property (weak, nonatomic) IBOutlet UIButton *takeButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property CGFloat evBias;
@property CGFloat underBias;
@property CGFloat overBias;
@property (weak, nonatomic) IBOutlet UILabel *biasLabel;
@property (nonatomic) SampleBufferDelegate *sampleBufferDelegate;
@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden; { return YES; }

- (void)viewDidLoad;
{
    [super viewDidLoad];
    
    [self.splitImageView addGestureRecognizer:[UITapGestureRecognizer.alloc initWithTarget:self action:@selector(splitImageViewTap)]];
    self.sessionQueue = dispatch_queue_create("session.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.sessionQueue, ^{
        [self configureSession];
    });
}

- (void)configureSession;
{
    self.sampleBufferDelegate = [SampleBufferDelegate delegateWithImageAnalysisDelegate:self];
    self.session = AVCaptureSession.new;
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.device = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    [self.session addInput:videoDeviceInput];
    self.photoOutput = AVCapturePhotoOutput.new;
    [self.session addOutput:self.photoOutput];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewView.session = self.session;
    });
    AVCaptureVideoDataOutput *sampleBufferOutput = AVCaptureVideoDataOutput.new;
    
    sampleBufferOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    ;
    [self.session addOutput:sampleBufferOutput];
    
    [sampleBufferOutput setSampleBufferDelegate:self.sampleBufferDelegate queue:dispatch_queue_create("sampleBuffer.queue", NULL)];
    
    [self.session startRunning];
}

- (IBAction)takeWasTapped:(UIButton *)sender;
{
    self.takeButton.enabled = NO;
    self.capturedPhotos = NSMutableArray.new;
    self.evBias = self.evControl.selectedSegmentIndex + 1.f;
    AVCaptureVideoOrientation orientation = self.previewView.videoPreviewLayer.connection.videoOrientation;
    dispatch_async(self.sessionQueue, ^{
        [self.photoOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = orientation;
        [self takeBracketed];
    });
}

- (void)splitImageViewTap;
{
    self.splitImageView.hidden = YES;
    [self.session startRunning];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    UIDeviceOrientation deviceOrientation = UIDevice.currentDevice.orientation;
    
    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        self.previewView.videoPreviewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    }
}

- (IBAction)saveWasTapped:(UIButton *)sender;
{
    CIImage *ciImage = self.splitImageView.rightImage.CIImage;
    UIImage *imageToSave = [UIImage imageWithCGImage:[CIContext.new createCGImage:ciImage
                                                                         fromRect:ciImage.extent]];
    UIImageWriteToSavedPhotosAlbum(imageToSave, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [self splitImageViewTap];
}

- (void)sampleBufferDidAnalyzeSampleWithDark:(CGFloat)dark light:(CGFloat)light;
{
    self.overBias = light * 15.f;
    self.underBias = dark * 15.f;
    self.biasLabel.text = [NSString stringWithFormat:@"-%0.2fEV/%0.2fEV", self.overBias, self.underBias];
}

#pragma mark - background queue stuff

- (void)takeBracketed;
{
    NSDictionary *processedFormat = @{AVVideoCodecKey : AVVideoCodecTypeJPEG};
    NSArray *brackets = @[[self settingsWithBias:-self.overBias],
                          [self settingsWithBias:0.f],
                          [self settingsWithBias:self.underBias]];
    AVCapturePhotoBracketSettings *settings =
    [AVCapturePhotoBracketSettings photoBracketSettingsWithRawPixelFormatType:0
                                                              processedFormat:processedFormat
                                                            bracketedSettings:brackets];
    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

- (AVCaptureAutoExposureBracketedStillImageSettings *)settingsWithBias:(CGFloat)bias;
{
    return [AVCaptureAutoExposureBracketedStillImageSettings autoExposureSettingsWithExposureTargetBias:bias];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error;
{
    [self.capturedPhotos addObject:photo];
    if (self.capturedPhotos.count == 3) {
        [self.session stopRunning];
        [self generateHDRForBracketedPhotos];
    }
}

- (void)generateHDRForBracketedPhotos;
{
    CIImage *underexposed = [CIImage imageWithData:self.capturedPhotos[0].fileDataRepresentation];
    CIImage *normal = [CIImage imageWithData:self.capturedPhotos[1].fileDataRepresentation];
    CIImage *overexposed = [CIImage imageWithData:self.capturedPhotos[2].fileDataRepresentation];
    
    if (!underexposed || !normal || !overexposed) { return; }
    
    CIImage *normalOriented = [normal imageByApplyingOrientation:kCGImagePropertyOrientationRight];
    self.splitImageView.leftImage = [UIImage imageWithCIImage:normalOriented];

    CGFloat radius = ((self.splitImageView.leftImage.size.width + self.splitImageView.leftImage.size.height) / 2.f) * 0.05;
    
    CIImage *underexposedMask = [underexposed.greyscaleImage boxBlurredWithRadius:radius].autoAdjustedImage;
    CIImage *overexposedMask = [overexposed.greyscaleImage.invertedImage boxBlurredWithRadius:radius].autoAdjustedImage;
    CIImage *intermediate = [normal blendedWithImage:underexposed mask:underexposedMask];
    CIImage *final = [intermediate blendedWithImage:overexposed mask:overexposedMask].autoAdjustedImage;
    CIImage *finalOriented = [final imageByApplyingOrientation:kCGImagePropertyOrientationRight];
    self.splitImageView.rightImage = [UIImage imageWithCIImage:finalOriented];
    self.splitImageView.hidden = NO;
    self.takeButton.enabled = YES;
}


@end
