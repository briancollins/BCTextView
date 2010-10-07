#import "BCImageNode.h"


@implementation BCImageNode
@synthesize image;

- (id)initWithImage:(UIImage *)img {
	if ((self = [super init])) {
		self.image = img;
	}
	return self;
}

- (CGFloat)width {
	return self.image.size.width;
}

- (CGFloat)height {
	return self.image.size.height;
}

- (void)drawAtPoint:(CGPoint)point {
	[self.image drawAtPoint:point];
}



@end
