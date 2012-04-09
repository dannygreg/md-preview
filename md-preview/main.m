//
//  main.m
//  md-preview
//
//  Created by Danny Greg on 09/04/2012.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

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
	
		
	}

    return 0;
}

