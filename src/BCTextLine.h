@class BCTextNode;

@interface BCTextLine : NSObject {
	NSMutableArray *stack;
	CGFloat width;
	CGFloat pos;
	CGFloat height;
	BOOL indented;
	CGFloat y;
}

- (id)initWithWidth:(CGFloat)width;
- (void)drawAtPoint:(CGPoint)point textColor:(UIColor *)textColor linkColor:(UIColor *)linkColor;
- (void)addNode:(BCTextNode *)node height:(CGFloat)aHeight;

@property (readonly) CGFloat widthRemaining;
@property (readonly) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat y;
@property (nonatomic) BOOL indented;


@end

#define kIndentWidth 10