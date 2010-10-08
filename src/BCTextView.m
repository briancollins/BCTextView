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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint point = [[touches anyObject] locationInView:self];
	[self.textFrame touchBeganAtPoint:point];
	[self setNeedsDisplay];
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint point = [[touches anyObject] locationInView:self];
	[self.textFrame touchEndedAtPoint:point];
	[self setNeedsDisplay];
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.textFrame touchCancelled];
	[self setNeedsDisplay];
	[super touchesCancelled:touches withEvent:event];
}

- (void)link:(NSValue *)link touchedInRects:(NSArray *)rects {
	for (NSValue *v in rects) {
		CGRect r = [v CGRectValue];
		UIView *v = [[[UIView alloc] initWithFrame:r] autorelease];
		v.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
		[self addSubview:v];
	}
}

@end
