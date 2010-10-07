#import "BCTextFrame.h"
#import "BCTextLine.h"
#import "BCTextNode.h"
#import "BCImageNode.h"

typedef enum {
	BCTextNodePlain = 0,
	BCTextNodeBold = 1,
	BCTextNodeItalic = 1 << 1,
	BCTextNodeLink = 1 << 2
} BCTextNodeAttributes;

@interface BCTextFrame ()
- (UIFont *)fontWithAttributes:(BCTextNodeAttributes)attr;

@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) BCTextLine *currentLine;
@end

@implementation BCTextFrame
@synthesize fontSize, height, width, lines, textColor, linkColor, delegate;

- (id)initWithHTML:(NSString *)html {
	if ((self = [super init])) {
		CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
		CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
		const char *enc = CFStringGetCStringPtr(cfencstr, 0);
		node = (xmlNode *)htmlReadDoc((xmlChar *)[html UTF8String],
									   "",
									   enc,
									   XML_PARSE_NOERROR | XML_PARSE_NOWARNING);
		self.textColor = [UIColor blackColor];
		self.linkColor = [UIColor blueColor];
	}
	
	return self;
}

- (void)pushNewline {
	if (self.currentLine.height == 0) {
		self.currentLine.height = self.fontSize;
	}
	height += self.currentLine.height;
	self.currentLine = [[[BCTextLine alloc] initWithWidth:self.width] autorelease];
}

- (void)pushText:(NSString *)text withFont:(UIFont *)font link:(BOOL)link {
	CGSize size = [text sizeWithFont:font];

	if (size.width > self.currentLine.widthRemaining) {
		NSRange spaceRange = [text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		// a word that needs to wrap
		if (spaceRange.location == NSNotFound || spaceRange.location == text.length - 1) {
			[self pushNewline];
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
				
				[self pushText:lastPart withFont:font link:link];
				[self pushText:[text substringFromIndex:length - 2] withFont:font link:link];
			} else {
				[self pushText:text withFont:font link:link];
			}
		} else {
			[self pushText:[text substringWithRange:NSMakeRange(0, spaceRange.location + 1)] withFont:font
					  link:link];
			[self pushText:[text substringWithRange:NSMakeRange(spaceRange.location + 1, text.length - (spaceRange.location + 1))]
				  withFont:font
					  link:link];
		}
	} else {
		[self.currentLine addNode:[[[BCTextNode alloc] initWithText:text font:font width:size.width height:size.height link:link] autorelease]
						   height:size.height];
	}
}

- (void)pushImage:(NSString *)src {
	if ([(NSObject *)self.delegate respondsToSelector:@selector(imageForURL:)]) {
		UIImage *img = [self.delegate imageForURL:src];
		if (img.size.width > self.currentLine.widthRemaining) {
			[self pushNewline];
		}
		[self.currentLine addNode:[[[BCImageNode alloc] initWithImage:img] autorelease] height:img.size.height];
		whitespaceNeeded = YES;
	}
}

- (NSString *)stripWhitespace:(char *)str {
	char *stripped = malloc(strlen(str) + 1);
	int i = 0;
	
	for (*str; *str != '\0'; *str++) {
		if (*str == ' ' || *str == '\t' || *str == '\n') {
			if (whitespaceNeeded) {
				stripped[i++] = ' ';
				whitespaceNeeded = NO;
			}
		} else {
			whitespaceNeeded = YES;
			stripped[i++] = *str;
		}
	}
	stripped[i++] = '\0';
	NSString *strippedString = [NSString stringWithUTF8String:stripped];
	free(stripped);
	return strippedString;
}

- (void)layoutNode:(xmlNode *)n attributes:(BCTextNodeAttributes)attr {
	if (!n) return;
	
	for (xmlNode *curNode = n; curNode; curNode = curNode->next) {
		if (curNode->type == XML_TEXT_NODE) {
			UIFont *textFont = [self fontWithAttributes:attr];
			
			NSString *text = [self stripWhitespace:(char *)curNode->content];
			
			[self pushText:text withFont:textFont link:(attr & BCTextNodeLink)];
		} else {
			BCTextNodeAttributes childrenAttr = attr;
			
			if (curNode->name) {
				if (!strcmp((char *)curNode->name, "b")) {
					childrenAttr |= BCTextNodeBold;
				} else if (!strcmp((char *)curNode->name, "i")) {
					childrenAttr |= BCTextNodeItalic; 
				} else if (!strcmp((char *)curNode->name, "a")) {
					childrenAttr |= BCTextNodeLink;
				} else if (!strcmp((char *)curNode->name, "br")) {
					[self pushNewline];
					whitespaceNeeded = NO;
				} else if (!strcmp((char *)curNode->name, "img")) {
					NSString *src = [NSString stringWithUTF8String:(char *)xmlGetProp(curNode, (xmlChar *)"src")];
					[self pushImage:src];
				}
			}

			[self layoutNode:curNode->children attributes:childrenAttr];
		}
	}
}

- (void)drawInRect:(CGRect)rect {
	CGFloat y = 0;
	for (BCTextLine *line in self.lines) {
		[line drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y + y) textColor:self.textColor linkColor:self.linkColor];
		y += line.height;
		if (y > rect.size.height) {
			return;
		}
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
