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
		self.textFrame.delegate = (id <BCTextFrameDelegate>)self;
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

- (void)setFontSize:(CGFloat)aFontSize {
	self.textFrame.fontSize = aFontSize;
}

- (CGFloat)fontSize {
	return self.textFrame.fontSize;
}

- (UIImage *)imageForURL:(NSString *)URL {
	return [UIImage imageNamed:@"emot-sweden.gif"];
}

@end
