//
//  AsyncImageViewSmall.h
//  Beautifo!
//
//  Created by techvalens on 22/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "TJSpinner.h"

@interface AsyncImageViewSmall : UIButton{

@private
	NSURLConnection *connection;
	NSMutableData   *imageData;
	AppDelegate *delegate;
	NSMutableArray *arrayForURL;
    TJSpinner *spinner;
    
	//ProgressBar
	
	int totalfilesize;
	int filesizereceived;
	float filepercentage;
	
}

-(void) setimage:(UIImage*)image;
-(void)loadImage:(NSString *)url;

@end

