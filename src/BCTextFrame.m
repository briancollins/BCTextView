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

@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) BCTextLine *currentLine;
@end

@implementation BCTextFrame
@synthesize fontSize, height, width, lines;

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

- (void)pushText:(NSString *)text withFont:(UIFont *)font {
	CGSize size = [text sizeWithFont:font];

	if (size.width > self.currentLine.widthRemaining) {
		NSRange spaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// a word that needs to wrap
		if (spaceRange.location == NSNotFound || spaceRange.location == text.length - 1) {
			height += self.currentLine.height;
			self.currentLine = [[[BCTextLine alloc] initWithWidth:self.width] autorelease];
			if (size.width > self.width) { // word is too long even for its own line
				CGFloat partWidth;
				NSString *textPart;
				NSString *lastPart = nil;
				NSInteger length = 1;
				
				do {
					lastPart = textPart;
					textPart = [text substringToIndex:length++];
					partWidth = [textPart sizeWithFont:font].width;
				} while (partWidth < self.width);
				
				[self pushText:lastPart withFont:font];
				[self pushText:[text substringFromIndex:length - 2] withFont:font];
			} else {
				[self pushText:text withFont:font];
			}
		} else {
			[self pushText:[text substringWithRange:NSMakeRange(0, spaceRange.location + 1)] withFont:font];
			[self pushText:[text substringWithRange:NSMakeRange(spaceRange.location + 1, text.length - (spaceRange.location + 1))]
				  withFont:font];
		}
	} else {
		[self.currentLine addNode:[[[BCTextNode alloc] initWithText:text font:font width:size.width] autorelease]
						   height:size.height];
	}
}

- (void)layoutNode:(xmlNode *)n attributes:(BCTextNodeAttributes)attr {
	if (!n) return;
	
	for (xmlNode *curNode = n; curNode; curNode = curNode->next) {
		if (curNode->type == XML_TEXT_NODE) {
			UIFont *textFont = [self fontWithAttributes:attr];
			NSString *text = [NSString stringWithUTF8String:(char *)curNode->content];
			
			[self pushText:text withFont:textFont];
		} else {
			BCTextNodeAttributes childrenAttr = attr;
			
			if (curNode->name) {
				if (!strcmp((char *)curNode->name, "b")) {
					childrenAttr |= BCTextNodeBold;
				} else if (!strcmp((char *)curNode->name, "i")) {
					childrenAttr |= BCTextNodeItalic;
				}
			}

			[self layoutNode:curNode->children attributes:childrenAttr];
		}
	}
}

- (void)drawInRect:(CGRect)rect {
	CGFloat y = 0;
	for (BCTextLine *line in self.lines) {
		[line drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y + y)];
		y += line.height;
	}
}

- (BCTextLine *)currentLine {
	return [self.lines lastObject];
}

- (void)setCurrentLine:(BCTextLine *)aLine {
	[self.lines addObject:aLine];
}

- (void)setWidth:(CGFloat)aWidth {
	width = aWidth;
	self.lines = [NSMutableArray array];
	self.currentLine = [[[BCTextLine alloc] initWithWidth:width] autorelease];
	height = 0;
	[self layoutNode:node attributes:BCTextNodePlain];
	height += self.currentLine.height;
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
