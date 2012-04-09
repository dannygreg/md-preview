//*******************************************************************************

// Copyright (c) 2012 Danny Greg

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Created by Danny Greg on 09/04/2012

//*******************************************************************************

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

#import "html.h"
#import "markdown.h"

void printUsage()
{
	NSLog(@"md-preview takes 1 argument: the path to a markdown document.");
}

int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    if (argc != 2) {
			printUsage();
			return EXIT_FAILURE;
		}
		
		NSString *argument = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
		if (argument == nil) {
			printUsage();
			return EXIT_FAILURE;
		}
		
		argument = [argument stringByExpandingTildeInPath];
		
		NSString *pwd = [NSString stringWithCString:getenv("PWD") encoding:NSUTF8StringEncoding];
		if (pwd == nil) {
			NSLog(@"You appear not to have a pwd… I have no idea how you have managed that so I'm getting the hell out of here!");
			return EXIT_FAILURE;
		}
		
		NSString *initialChar = [argument substringToIndex:1];
		if (![initialChar isEqualToString:@"~"] && ![initialChar isEqualToString:@"/"]) {
			argument = [pwd stringByAppendingPathComponent:argument];
		}
		
	    NSURL *fileLocation = [NSURL fileURLWithPath:argument];
		if (fileLocation == nil) {
			printUsage();
			return EXIT_FAILURE;
		}
		
		if (![fileLocation.pathExtension isEqualToString:@"md"] && ![fileLocation.pathExtension isEqualToString:@"markdown"])
			NSLog(@"This doesn't seem to be a markdown file… Imma try… but look, I'm not promising anything.");
	
		NSError *err = nil;
		NSString *fileContents = [NSString stringWithContentsOfURL:fileLocation encoding:NSUTF8StringEncoding error:&err]; //Yeah… I should figure out the encoding but cba.
		if (fileContents == nil) {
			NSLog(@"Couldn't load the markdown file. Here is what the NSError has to say about it:\n\n%@", err.localizedDescription);
			return EXIT_FAILURE;
		}
		
		const char *prose = [fileContents UTF8String];
		struct buf *ib = bufnew(strlen(prose));
		bufputs(ib, prose);
		
		struct buf *ob = bufnew(64);
		struct sd_callbacks callbacks;
		struct html_renderopt options;
		sdhtml_renderer(&callbacks, &options, 0);
		struct sd_markdown *markdown = sd_markdown_new(0, 16, &callbacks, &options);
		sd_markdown_render(ob, ib->data, ib->size, markdown);
		sd_markdown_free(markdown);
		
		NSString *html = [NSString stringWithUTF8String:bufcstr(ob)];
		bufrelease(ib);
		bufrelease(ob);
		 
		//Put the html right next to the original .md. This way we don't have to worry about cluttering up the system with rogue html files
		NSURL *htmlLocation = [[fileLocation URLByDeletingPathExtension] URLByAppendingPathExtension:@"html"];
		if (![html writeToURL:htmlLocation atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
			NSLog(@"We couldn't write out the completed html. Here is what the NSError has to say:\n\n%@", err.localizedDescription);
			return EXIT_FAILURE;
		}
		
		[[NSWorkspace sharedWorkspace] openURL:htmlLocation];
	}

    return EXIT_SUCCESS;
}

