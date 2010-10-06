#import "BCTextNode.h"


@implementation BCTextNode
@synthesize text, font, width;

- (id)initWithText:(NSString *)aText font:(UIFont *)aFont width:(CGFloat)aWidth {
	if ((self = [super init])) {
		self.text = aText;
		self.font = aFont;
		width = aWidth;
	}
	
	return self;
}

- (void)drawAtPoint:(CGPoint)point {
	[self.text drawAtPoint:point withFont:self.font];
}

@end
