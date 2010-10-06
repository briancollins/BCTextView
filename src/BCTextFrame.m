#import "BCTextFrame.h"

typedef enum {
	BCTextNodePlain = 0,
	BCTextNodeBold = 1,
	BCTextNodeItalic = 1 << 1
} BCTextNodeAttributes;

typedef struct {
	BCTextNodeAttributes attr;
	size_t pos;
} BCTextNodeState;

typedef struct {
	CGPoint pos;
} BCLineState;

@interface BCTextFrame ()
- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr;
@end

@implementation BCTextFrame
@synthesize fontSize;

- (id)initWithHTML:(NSString *)html {
	if ((self = [super init])) {
		CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
		CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
		const char *enc = CFStringGetCStringPtr(cfencstr, 0);
		node = (xmlNode *)htmlReadDoc((xmlChar *)[html UTF8String],
									   "",
									   enc,
									   XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
	}
	
	return self;
}

- (void)drawNode:(xmlNode *)n inContext:(CGContextRef)context state:(BCTextNodeState)state lineState:(BCLineState *)lineState {
	if (!n) return;
	
	for (xmlNode *curNode = n; curNode; curNode = curNode->next) {
		if (curNode->type == XML_TEXT_NODE) {
			UIFont *textFont = [self fontWithAttributes:state.attr];
			NSString *text = [NSString stringWithUTF8String:(char *)curNode->content];
			
			[text drawAtPoint:lineState->pos withFont:textFont];
			lineState->pos.x += [text sizeWithFont:textFont].width;
		} else {
			BCTextNodeState childrenState = state;
			
			if (curNode->name) {
				if (!strcmp((char *)curNode->name, "b")) {
					childrenState.attr |= BCTextNodeBold;
				} else if (!strcmp((char *)curNode->name, "i")) {
					childrenState.attr |= BCTextNodeItalic;
				}
			}

			[self drawNode:curNode->children inContext:context state:childrenState lineState:lineState];
		}
	}
}

- (void)drawInContext:(CGContextRef)context {
	BCTextNodeState state = {BCTextNodePlain, 0};
	BCLineState lineState = {CGPointMake(0, 0)};
	[self drawNode:node inContext:context state:state lineState:&lineState];
}


- (void)dealloc {
	if (node) 
		xmlFreeDoc((xmlDoc *)node);
	
	node = NULL;
	[super dealloc];
}

- (CGFloat)fontSize {
	if (!fontSize) {
		fontSize = 12;
	}
	return fontSize;
}

- (UIFont *)regularFont {
	return [UIFont fontWithName:@"Helvetica" size:self.fontSize];
}

- (UIFont *)boldFont {
	return [UIFont fontWithName:@"Helvetica-Bold" size:self.fontSize];
}

- (UIFont *)italicFont {
	return [UIFont fontWithName:@"Helvetica-Oblique" size:self.fontSize];
}

- (UIFont *)boldItalicFont {
	return [UIFont fontWithName:@"Helvetica-BoldOblique" size:self.fontSize];
}

- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr {
	if (attr & BCTextNodeItalic && attr & BCTextNodeBold) {
		return [self boldItalicFont];
	} else if (attr & BCTextNodeItalic) {
		return [self italicFont];
	} else if (attr & BCTextNodeBold) {
		return [self boldFont];
	} else {
		return [self regularFont];
	}
}

@end
