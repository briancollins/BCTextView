#import "BCTextView.h"
#import "BCTextFrame.h"

@interface BCTextView ()
@property (nonatomic, retain) BCTextFrame *textFrame;
@end


@implementation BCTextView
@synthesize textFrame;

- (id)initWithHTML:(NSString *)html {
	if ((self = [super init])) {
		self.textFrame = [[[BCTextFrame alloc] initWithHTML:html] autorelease];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor blackColor] set];
	[self.textFrame drawInRect:self.bounds];
}

- (void)setFrame:(CGRect)aFrame {
	[super setFrame:aFrame];
	self.textFrame.width = aFrame.size.width;
	[self setNeedsDisplay];
}

@end
