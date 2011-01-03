@class BCTextFrame;

@interface BCTextView : UIView {
	BCTextFrame *textFrame;
	NSArray *linkHighlights;
}

- (id)initWithHTML:(NSString *)html;
- (UIImage *)imageForURL:(NSString *)URL;

@property (nonatomic) CGFloat fontSize;

@end
