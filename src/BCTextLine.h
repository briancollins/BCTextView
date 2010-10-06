@class BCTextNode;

@interface BCTextLine : NSObject {
	NSMutableArray *stack;
	CGFloat width;
	CGFloat pos;
	CGFloat height;
}

- (id)initWithWidth:(CGFloat)width;
- (void)drawAtPoint:(CGPoint)point;
- (void)addNode:(BCTextNode *)node height:(CGFloat)aHeight;

@property (readonly) CGFloat widthRemaining;
@property (readonly) CGFloat width;
@property (nonatomic) CGFloat height;

@end
