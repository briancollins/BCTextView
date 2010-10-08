#import "BCBlockBorder.h"


@implementation BCBlockBorder


- (void)drawAtPoint:(CGPoint)point textColor:(UIColor *)textColor linkColor:(UIColor *)linkColor {
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[UIColor darkGrayColor] set];
	CGContextFillRect(context, CGRectMake(point.x + kIndentWidth, point.y + (self.height / 2), self.width - kIndentWidth * 2, 1));
}

- (CGFloat)height {
	return 17.0;
}

@end
