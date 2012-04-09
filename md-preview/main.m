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
	    if (argc != 1) {
			printUsage();
			return 1;
		}
		
		NSString *argument = [NSString stringWithCString:argv[0] encoding:NSUTF8StringEncoding];
		if (argument == nil) {
			printUsage();
			return 1;
		}
		
	    
	    
	}
    return 0;
}

