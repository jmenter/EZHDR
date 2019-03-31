
@import UIKit;

@interface SplitImageView : UIView

@property (nonatomic, copy) IBInspectable NSString *leftImageName;
@property (nonatomic, copy) IBInspectable NSString *rightImageName;
@property (nonatomic) UIImage *leftImage;
@property (nonatomic) UIImage *rightImage;

@end
