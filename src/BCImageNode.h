#import "BCNode.h"

@interface BCImageNode : BCNode {
	UIImage *image;
}

- (id)initWithImage:(UIImage *)img;
@property (nonatomic, retain) UIImage *image;

@end
