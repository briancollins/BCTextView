#import "BCTextLine.h"
#import "BCTextNode.h"

@interface BCTextLine ()
@property (nonatomic, retain) NSMutableArray *stack;
@end

@implementation BCTextLine
@synthesize stack, width, height;

- (id)initWithWidth:(CGFloat)aWidth {
	if ((self = [super init])) {
		self.stack = [NSMutableArray arrayWithCapacity:25];
		width = aWidth;
		pos = 0;
	}
	return self;
}

- (CGFloat)widthRemaining {
	return width - pos;
}

- (void)drawAtPoint:(CGPoint)point {
	int drawPos = 0;
	for (BCTextNode *node in self.stack) {
		[node drawAtPoint:CGPointMake(point.x + drawPos, point.y)];
		drawPos += node.width;
	}
}

- (void)addNode:(BCTextNode *)node height:(CGFloat)aHeight {
	[self.stack addObject:node];
	pos += node.width;
	
	if (aHeight > height) {
		height = aHeight;
	}
}

@end
