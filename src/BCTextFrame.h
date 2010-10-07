#import <libxml/HTMLparser.h>

@class BCTextLine;
@protocol BCTextFrameDelegate;


@interface BCTextFrame : NSObject {
	xmlNode *node;
	CGFloat fontSize;
	NSMutableArray *lines;
	CGFloat height;
	CGFloat width;
	UIColor *textColor;
	UIColor *linkColor;
	BOOL whitespaceNeeded;
	id <BCTextFrameDelegate> delegate;
}

- (id)initWithHTML:(NSString *)html;
- (void)drawInRect:(CGRect)rect;

@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *linkColor;
@property (nonatomic, assign) id <BCTextFrameDelegate> delegate;

@end

@protocol BCTextFrameDelegate

- (UIImage *)imageForURL:(NSString *)url;

@end

