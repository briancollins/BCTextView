#import "BCTextNode.h"


@implementation BCTextNode
@synthesize text, font, width, link, height;

- (id)initWithText:(NSString *)aText font:(UIFont *)aFont width:(CGFloat)aWidth height:(CGFloat)aHeight link:(BOOL)isLink {
	if ((self = [super init])) {
		self.text = aText;
		self.font = aFont;
		self.link = isLink;
		width = aWidth;
		height = aHeight;
	}
	
	return self;
}

- (void)drawAtPoint:(CGPoint)point {
	[self.text drawAtPoint:point withFont:self.font];
}

@end
