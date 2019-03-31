
#import "SplitImageView.h"

@interface UIImage(Pattern)
+ (UIImage *)checkerboard;
@end

@interface UIColor(Pattern)
+ (UIColor *)transparencyPattern;
@end

@interface SplitImageView ()
@property (nonatomic) UIImageView *leftImageView;
@property (nonatomic) CAShapeLayer *leftMaskLayer;

@property (nonatomic) UIImageView *rightImageView;
@property (nonatomic) CAShapeLayer *rightMaskLayer;

@property (nonatomic) UIView *splitterView;
@property (nonatomic) UIView *thumbView;
@end

static inline CGFloat CGFloatClamp(CGFloat minimum, CGFloat maximum, CGFloat value) { return MIN(MAX(value, minimum), maximum); }

@implementation SplitImageView

static const CGSize kSplitterThumbSize = { 10.f, 44.f };

- (instancetype)init; { if (!(self = [super init])) { return nil; } return [self commonInit]; }
- (instancetype)initWithCoder:(NSCoder *)aDecoder; { if (!(self = [super initWithCoder:aDecoder])) { return nil; } return [self commonInit]; }
- (instancetype)initWithFrame:(CGRect)frame; { if (!(self = [super initWithFrame:frame])) { return nil; } return [self commonInit]; }

- (instancetype)commonInit;
{
    self.leftImageView = UIImageView.new;
    self.leftImageView.contentMode = self.contentMode;
    self.leftMaskLayer = CAShapeLayer.layer;
    self.leftImageView.layer.mask = self.leftMaskLayer;
    [self addSubview:self.leftImageView];
    
    self.rightImageView = UIImageView.new;
    self.rightImageView.contentMode = self.contentMode;
    self.rightMaskLayer = CAShapeLayer.layer;
    self.rightImageView.layer.mask = self.rightMaskLayer;
    [self addSubview:self.rightImageView];
    
    self.splitterView = UIView.new;
    self.splitterView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.splitterView.backgroundColor = UIColor.darkGrayColor;
    self.splitterView.layer.cornerRadius = 1;
    self.splitterView.alpha = 0.9;
    [self addSubview:self.splitterView];
    
    self.thumbView = UIView.new;
    self.thumbView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.thumbView.backgroundColor = UIColor.lightGrayColor;
    self.thumbView.layer.cornerRadius = 3;
    self.thumbView.layer.borderWidth = 1.5;
    self.thumbView.layer.borderColor = UIColor.grayColor.CGColor;
    self.splitterView.alpha = 0.9;
    [self addSubview:self.thumbView];
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    self.backgroundColor = UIColor.transparencyPattern;

    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    self.imageSplit = CGFloatClamp(0.f, self.bounds.size.width, [touches.anyObject locationInView:self].x);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
{
    [self touchesMoved:touches withEvent:event];
}

- (void)layoutSubviews;
{
    self.leftImageView.frame = self.leftMaskLayer.frame = self.rightImageView.frame = self.rightMaskLayer.frame = self.bounds;
    
    self.splitterView.frame = CGRectMake(0, -2, 2, self.bounds.size.height + 4);
    self.thumbView.frame = CGRectMake(0, 0, kSplitterThumbSize.width, kSplitterThumbSize.height);
    
    self.imageSplit = CGRectGetMidX(self.bounds);
}

- (void)setImageSplit:(CGFloat)xPosition;
{
    self.splitterView.center = CGPointMake(xPosition, CGRectGetMidY(self.bounds));
    self.thumbView.center = CGPointMake(xPosition, CGRectGetMidY(self.bounds));
    
    self.leftMaskLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, xPosition, self.bounds.size.height)].CGPath;
    self.rightMaskLayer.path = [UIBezierPath bezierPathWithRect:CGRectMake(xPosition, 0, self.bounds.size.width - xPosition, self.bounds.size.height)].CGPath;
}

- (void)setContentMode:(UIViewContentMode)contentMode; { self.leftImageView.contentMode = self.rightImageView.contentMode = super.contentMode = contentMode; }

- (UIImage *)leftImage; { return self.leftImageView.image; }
- (void)setLeftImage:(UIImage *)leftImage; { self.leftImageView.image = leftImage; }
- (void)setLeftImageName:(NSString *)leftImageName; { self.leftImage = [UIImage imageNamed:leftImageName]; }

- (UIImage *)rightImage; { return self.rightImageView.image; }
- (void)setRightImage:(UIImage *)rightImage; { self.rightImageView.image = rightImage; }
- (void)setRightImageName:(NSString *)rightImageName; { self.rightImage = [UIImage imageNamed:rightImageName]; }

@end

@implementation UIImage(Pattern)

static const CGFloat kCheckerboardGridSize = 4.f;

+ (UIImage *)checkerboard;
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(kCheckerboardGridSize * 2.f, kCheckerboardGridSize * 2.f), YES, 0);
    [UIColor.whiteColor setFill];
    UIRectFill(CGRectMake(0, 0, kCheckerboardGridSize * 2.f, kCheckerboardGridSize * 2.f));
    [[UIColor colorWithWhite:0.75 alpha:1] setFill];
    UIRectFill(CGRectMake(0, 0, kCheckerboardGridSize, kCheckerboardGridSize));
    UIRectFill(CGRectMake(kCheckerboardGridSize, kCheckerboardGridSize, kCheckerboardGridSize, kCheckerboardGridSize));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIColor(Pattern)
+ (UIColor *)transparencyPattern; { return [UIColor colorWithPatternImage:UIImage.checkerboard]; }
@end


