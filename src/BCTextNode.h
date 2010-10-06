@interface BCTextNode : NSObject {
	NSString *text;
	UIFont *font;
	CGFloat width;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (readonly) CGFloat width;

- (id)initWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)aWidth;
- (void)drawAtPoint:(CGPoint)point;

@end
