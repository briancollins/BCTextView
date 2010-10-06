#import "BCTextFrame.h"
#import "BCTextLine.h"
#import "BCTextNode.h"

typedef enum {
	BCTextNodePlain = 0,
	BCTextNodeBold = 1,
	BCTextNodeItalic = 1 << 1
} BCTextNodeAttributes;

@interface BCTextFrame ()
- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr;

@property (nonatomic, retain) BCTextLine *currentLine;
@end

@implementation BCTextFrame
@synthesize fontSize, currentLine;

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

- (void)pushText:(NSString *)text withFont:(UIFont *)font yPos:(CGFloat *)yPos {
	CGSize size = [text sizeWithFont:font];
	if (size.width > self.currentLine.widthRemaining) {
		NSRange spaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (spaceRange.location == NSNotFound || spaceRange.location == text.length - 1) {
			[self.currentLine drawAtPoint:CGPointMake(0, *yPos)];
			*yPos += self.currentLine.height;
			self.currentLine = [[[BCTextLine alloc] initWithWidth:self.currentLine.width] autorelease];
		} else {
			[self pushText:[text substringWithRange:NSMakeRange(0, spaceRange.location + 1)] withFont:font yPos:yPos];
			[self pushText:[text substringWithRange:NSMakeRange(spaceRange.location + 1, text.length - (spaceRange.location + 1))]
				  withFont:font
					  yPos:yPos];
		}
	} else {
		[self.currentLine addNode:[[[BCTextNode alloc] initWithText:text font:font width:size.width] autorelease]
						   height:size.height];
	}
}

- (void)drawNode:(xmlNode *)n attributes:(BCTextNodeAttributes)attr yPos:(CGFloat *)yPos {
	if (!n) return;
	
	for (xmlNode *curNode = n; curNode; curNode = curNode->next) {
		if (curNode->type == XML_TEXT_NODE) {
			UIFont *textFont = [self fontWithAttributes:attr];
			NSString *text = [NSString stringWithUTF8String:(char *)curNode->content];
			
			[self pushText:text withFont:textFont yPos:yPos];
		} else {
			BCTextNodeAttributes childrenAttr = attr;
			
			if (curNode->name) {
				if (!strcmp((char *)curNode->name, "b")) {
					childrenAttr |= BCTextNodeBold;
				} else if (!strcmp((char *)curNode->name, "i")) {
					childrenAttr |= BCTextNodeItalic;
				}
			}

			[self drawNode:curNode->children attributes:childrenAttr yPos:yPos];
		}
	}
}

- (void)drawInRect:(CGRect)rect {
	self.currentLine = [[[BCTextLine alloc] initWithWidth:rect.size.width] autorelease];
	[self drawNode:node attributes:BCTextNodePlain yPos:&rect.origin.y];
	[self.currentLine drawAtPoint:CGPointMake(0, rect.origin.y)];
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
