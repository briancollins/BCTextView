#import "BCNode.h"

@interface BCImageNode : BCNode {
	UIImage *image;
}

- (id)initWithImage:(UIImage *)img link:(BOOL)isLink;
@property (nonatomic, retain) UIImage *image;

@end
