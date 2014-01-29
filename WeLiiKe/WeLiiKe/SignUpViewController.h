//
//  SignUpViewController.h
//  WeLiiKe
//
//  Created by techvalens on 12/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WeLiikeWebService.h"
#import "HudView.h"
#import "UIImage+Resize.h"
#import "WeliikeCropViewController.h"

@interface SignUpViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,croppedImageDelegate>{
    
    UITextField *txtViewForName;
    UITextField *txtViewForSurname;
    UITextField *txtViewForEmail;
    UITextField *txtViewForpassword;
    UIImageView *imgViewProfile;
    UIImage *imageForCover;
    HudView *aHUD;
    int checkForImage;
    UIScrollView *scrollViewForRegi;
}
@property(nonatomic,retain)IBOutlet UIScrollView *scrollViewForRegi;
@property(nonatomic,retain)IBOutlet UIImageView *imgViewProfile;
@property(nonatomic,retain)IBOutlet UITextField *txtViewForName,*txtViewForSurname,*txtViewForEmail,*txtViewForpassword;
-(IBAction)actionOnBack:(id)sender;
-(IBAction)actionOnCookieUse:(id)sender;
-(IBAction)actionOnSignUp:(id)sender;
-(IBAction)actionOnCamera:(id)sender;
-(NSString *)Base64Encode:(NSData *)theData;
- (void)showImagePicker:(UIImagePickerControllerSourceType)sourceType;
@end