@class BCTextFrame;

@interface BCTextView : UIView {
	BCTextFrame *textFrame;
}

- (id)initWithHTML:(NSString *)html;
- (UIImage *)imageForURL:(NSString *)URL;

@property (nonatomic) CGFloat fontSize;

@end
