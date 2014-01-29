//
//  PostViewController.m
//  WeLiiKe
//
//  Created by techvalens on 16/01/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PostViewController.h"
#import "SelectCategoryViewController.h"
#import "UITabBarController+hidable.h"
#import "ApplyFilterViewController.h"
#import "UIImage+Resize.h"
#import "Foursquare2.h"
#import "UIImage+Resize.h"
#import "SVGeocoder.h"

extern UIImage *imageFinal;
extern BOOL pushApplyFilter;
extern NSString *stringForCategoryName;
NSDictionary *dicForCategorySelected;
 BOOL B_PostLock;

@implementation PostViewController
CGFloat fontHeight;
CGFloat textViewHeight;
@synthesize imgView,txtView,txtField,btnForSelecte,tableViewForSearchEntity,strForSeletedAppID;
@synthesize strForAddress,lblForWrite,scrollViewForPost,strForCity,strForSubcategoryName;
@synthesize parentView,btn_Back,ImgView_StarRating,v_BottomView,btn_Share,btn_Done;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}
- (void) killHUD
{
	if(aHUD != nil ){
		[aHUD.loadingView removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];
        aHUD = nil;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}
//
////Initialize and display the progress view
- (void) showHUD
{
	if(aHUD == nil)
	{
		aHUD = [[HudView alloc]init];
        [aHUD loadingViewInView:self.view text:@"Please Wait..."];
		[aHUD setUserInteractionEnabledForSuperview:self.view.superview];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}
-(void)killActivityindicator{
    [activityIndicatorView stopAnimating];
}
-(void)showActivityindicator{
    [activityIndicatorView startAnimating];
}




- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(IBAction)actionOnBack:(id)sender{
    
    [txtView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self.view];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    //[txtView resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"GroupIdToShare"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.arrayOfUserForMessage count]>0) {
        [appDelegate.arrayOfUserForMessage removeAllObjects];
    }
    
    dicForCategorySelected=nil;
    [btnForSelecte setTitle:@"Select Category" forState:UIControlStateNormal];
    txtField.text=@"";
    txtField.placeholder=@"NAME...";
    txtView.text=@"";
    lblForWrite.hidden=NO;
    [customRank setValue:0];
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"captionText"];
    [btnForTakePicture removeFromSuperview];
    [btnForTakePicture setImage:nil];
    imageFinal=nil;
     [[[self.tabBarController viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:YES];
    self.tabBarController.selectedIndex=1;
    //[self.tabBarController setTabBarHidden:NO animated:NO];
    [self.tabBarController setTabBarHidden:NO animated:NO completion:NULL];
}
-(IBAction)actionOnSelectCategory:(id)sender{
    
        ImgView_StarRating.hidden = NO;
    [activityIndicatorView stopAnimating];
    //[self performSelector:@selector(callItunesWebService:) withObject:@"" afterDelay:0.2];
//    SelectCategoryViewController *obj=[[SelectCategoryViewController alloc] init];
//    [self presentModalViewController:obj animated:YES];
      [txtView resignFirstResponder];
      [txtField resignFirstResponder];
    SelectCategoryViewController *obj=[[SelectCategoryViewController alloc] init];
    [self.parentView addSubview:obj.view];
    obj.can.hidden=NO;
    CGRect frame = self.parentView.frame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
    [UIView beginAnimations:@"slideMenu" context:(__bridge void *)(self.parentView)];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDuration:0.5];
    if (frame.origin.y==0) {
        frame.origin.y = -410;
    }else{
        frame.origin.y = 40;
    }
    self.parentView.frame = frame;
    [UIView commitAnimations];
  
    
    
}


-(IBAction)actionOnShare:(id)sender{
    B_Share = true;
    ShareSettingViewController *obj=[[ShareSettingViewController alloc] init];
    [self.navigationController pushViewController:obj animated:YES];
    
}

//- (BOOL)touchesShouldCancelInContentView:(UIView *)view
//{
//    return ![view isKindOfClass:[UIButton class]];
//}

-(IBAction)actionOnDone:(id)sender{
    //
    if(checkStatus==true)
    {
        UIImageWriteToSavedPhotosAlbum(btnForTakePicture.image, nil,nil, nil);
        //            checkStatus = false;
    }
   NSString *strForTitle=[btnForSelecte currentTitle];
  if ([btnForTakePicture image]==nil) {
      UIAlertView *errorAlert = [[UIAlertView alloc]
                                 initWithTitle: @"Message"
                                 message: @"Please upload a picture."
                                 delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
      [errorAlert show];
      
  }else if ([[btnForSelecte currentTitle] isEqualToString:@"Select category"]){
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Message"
                                   message: @"Please choose a category"
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];

  }else if ([strForTitle isEqualToString:@"Apps & Games"]|| [strForTitle isEqualToString:@"Music"]|| [strForTitle isEqualToString:@"Books"]|| [strForTitle isEqualToString:@"Movies & TV"]|| [strForTitle isEqualToString:@"Restaurants"] || [strForTitle isEqualToString:@"Bars & Nightlife"]||[strForTitle isEqualToString:@"Places & Activities"]){
    
      if ([txtField.text length]==0) {
          UIAlertView *errorAlert = [[UIAlertView alloc]
                                     initWithTitle: @"Message"
                                     message: @"Please enter a name for your post"
                                     delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
          [errorAlert show];
      }else{
          [self showHUD];
//          [activityIndicatorView startAnimating];
          //[self performSelector:@selector(callService) withObject:nil afterDelay:0.0];
          [self performSelector:@selector(callService) withObject:nil afterDelay:0.5];
      }
        

        
    }else{
        strForSeletedAppID=@"";
        strForSubcategoryName=@"";
        [self showHUD];
        // [activityIndicatorView startAnimating];
        //[self performSelector:@selector(callService) withObject:nil afterDelay:0.0];
        [self performSelector:@selector(callService) withObject:nil afterDelay:0.5];
    }
    
}
UIImage* imageFromView(UIImage* srcImage, CGRect* rect)
{
    CGImageRef cr = CGImageCreateWithImageInRect(srcImage.CGImage, *rect);
    UIImage* cropped = [UIImage imageWithCGImage:cr];
    
    CGImageRelease(cr);
    return cropped;
}
-(void)callService{
    
    //[self performSelector:@selector(postOnWall)];
    WeLiikeWebService *service=[[WeLiikeWebService alloc] initWithDelegate:self callback:@selector(saveMediaHandler:)];
    
    CGRect visibleRect;
    float scale = 1.0f/scrollViewTakePhoto.zoomScale;
    visibleRect.origin.x = scrollViewTakePhoto.contentOffset.x * scale;
    visibleRect.origin.y = scrollViewTakePhoto.contentOffset.y * scale;
    visibleRect.size.width = scrollViewTakePhoto.bounds.size.width * scale;
    visibleRect.size.height = scrollViewTakePhoto.bounds.size.height * scale;
    
    NSLog(@"**************%@", NSStringFromCGRect(visibleRect));
     UIImage *img2=btnForTakePicture.image;
     UIImage* cropped = imageFromView(img2, &visibleRect);
     UIImage *img1=cropped;
    if (img1==nil) {
        img1=[btnForTakePicture image];
    }
    NSString *strForCaption=[txtView.text stringByReplacingOccurrencesOfString:@";" withString:@""] ;
    
    NSLog(@"star caption = %@", strForCaption);
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setValue:img1 forKey:@"image"];
    [dic setValue:strForCaption forKey:@"caption"];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TWPost"]) {
        [self performSelector:@selector(postOnTwitter:) withObject:dic];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FBPost"]) {
       [self performSelector:@selector(postOnFb:) withObject:dic];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FBPost"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TWPost"];
    //return;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"value of array %@",appDelegate.arrayOfEmailContact);
    
    NSMutableArray *arrayForEmail=[[NSMutableArray alloc] init];
    for (int i=0; i<[appDelegate.arrayOfEmailContact count]; i++) {
        [arrayForEmail addObject:[[appDelegate.arrayOfEmailContact objectAtIndex:i] valueForKey:@"EMAIL"]];
    }
    
    NSString *strEmai=[arrayForEmail componentsJoinedByString:@","];
    
    NSData *imageData=UIImageJPEGRepresentation(img1, 0.7);
    //NSData *imageData=UIImagePNGRepresentation(img);
    NSString *strBase=[self Base64Encode:imageData];
    
    NSString *strID=[[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *strForlate=[NSString stringWithFormat:@"%f",delegate.currentLatitude];
    NSString *strForlong=[NSString stringWithFormat:@"%f",delegate.currentLongitute];
    if (selectedCategory==1) {
        strForlate=strForLatFourSqaure;
        strForlong=strForLongFourSqaure;
        
        
        NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@&sensor=false",strForlate,strForlong];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        NSURLResponse *response = nil;
        NSError *requestError = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: &requestError];
        NSString *responseString = [[NSString alloc] initWithData: responseData encoding:NSUTF8StringEncoding];
        
        //NSLog(@"responseString %@ ",[[responseString JSONValue] valueForKey:@"results"]);
        
        if ([responseString length]>0) {
            
            if ([[[responseString JSONValue] valueForKey:@"status"] isEqualToString:@"OK"] ) {
                NSLog(@"responseString %@",[[[responseString JSONValue] valueForKey:@"results"] objectAtIndex:0]);
                NSArray *resultsArray = [[responseString JSONValue] valueForKey:@"results"];
                
                if ([resultsArray count]>0) {
                    strForAddress = [[resultsArray objectAtIndex:0] valueForKey:@"formatted_address"];
                    //NSLog(@"value at address Fourqaure ^^^^^^^^ %@",strForAddress);
                }
                
                // use the address variable to access the ADDRESS :)
            } else {
                
            }
        }
        
    }
    
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<[appDelegate.arrayOfUserForMessage count] ; i++) {
        
        [array addObject:[[appDelegate.arrayOfUserForMessage objectAtIndex:i] valueForKey:@"user_id"]];
    }
    NSLog(@"defaulf image  = = == =   = %d", appDelegate.B_defualf);
    NSString *strForUserIDToShare=[array componentsJoinedByString:@","];
    [txtView resignFirstResponder];
    [txtField resignFirstResponder];  

    [SVGeocoder reverseGeocode:CLLocationCoordinate2DMake(strForlate.floatValue, strForlong.floatValue)
                    completion:^(NSArray *placemarks, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSLog(@"placemarks = %@", placemarks);
                        
                        strForCity = [[placemarks valueForKey:@"subAdministrativeArea"]objectAtIndex:0];
                        
                    }];
    NSLog(@"string for city name = = = = = %d", B_PostLock);
    [service saveMedia:txtField.text comment:strForCaption address:strForAddress lat:strForlate longitude:strForlong master_category_id:[dicForCategorySelected valueForKey:@"master_category_id"] entity_image:strBase user_id:strID user_category_id:[dicForCategorySelected valueForKey:@"user_category_id"] api_id:strForSeletedAppID rating_count:[NSString stringWithFormat:@"%d",(int)customRank.value] group_id:[[NSUserDefaults standardUserDefaults] valueForKey:@"GroupIdToShare"] email:strEmai receiver_id:strForUserIDToShare feed:[[NSUserDefaults standardUserDefaults] valueForKey:@"newsfeedshare"] sub_category:strForSubcategoryName city:strForCity def:appDelegate.B_defualf is_active:B_PostLock];
   // NSLog(@"value of savemedia response %@",strForResponce);
        //******************[btnForTakePicture setBackgroundImage:nil forState:UIControlStateNormal];
}


-(void)saveMediaHandler:(id)sender{
    
    [self killHUD];
     // [activityIndicatorView stopAnimating];
    if([sender isKindOfClass:[NSError class]]) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Error"
                                   message: @"Error from server please try again later."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        
    }else{
        NSError *error=nil;
        NSString *str=[sender stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        //NSLog(@"value of data %@",str);
        id strForResponce = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        
        if (error==nil) {
            
            AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"GroupIdToShare"];
            if ([appDelegate.arrayOfUserForMessage count]>0) {
                [appDelegate.arrayOfUserForMessage removeAllObjects];
            }
             [btnForTakePicture setImage:nil];
            dicForCategorySelected=nil;
            [btnForSelecte setTitle:@"Select category" forState:UIControlStateNormal];
            txtField.text=@"";
            txtField.placeholder=@"NAME...";
            txtView.text=@"";
            lblForWrite.hidden=NO;
            [customRank setValue:0];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"captionText"];
            [btnForTakePicture removeFromSuperview];
            imageFinal=nil;
            if ([strForResponce count]>0) {
                //[self performSelector:@selector(moveNextScreen)];
                dicForCategorySelected=nil;
                [[[self.tabBarController viewControllers] objectAtIndex:1] popToRootViewControllerAnimated:YES];
                self.tabBarController.selectedIndex=1;
                [self.tabBarController setTabBarHidden:NO animated:NO completion:NULL];
//                UIAlertView *errorAlert = [[UIAlertView alloc]
//                                           initWithTitle: @"Message"
//                                           message: @"Image Post Successfully..."
//                                           delegate:nil
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//                [errorAlert show];
               
                
                
            }else{
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle: @"Error"
                                           message: @"Error from server please try again later."
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                [errorAlert show];
                
            }

            
        }else{
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle: @"Error"
                                       message: @"Error from server please try again later."
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            [errorAlert show];
            
        }
        
    }
}

-(void)postOnTwitter:(NSDictionary*)dic{
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        // Create account store, followed by a twitter account identifier
        // At this point, twitter is the only account type available
        
        ACAccountStore *accountStore=[[ACAccountStore alloc] init];
        ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:twitterType];
        
        if ([twitterAccounts count]>0) {
            
            ACAccount *acct = [twitterAccounts objectAtIndex:0];
            
            
            UIImage * image = [dic valueForKey:@"image"];
            
            TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"] parameters:nil requestMethod:TWRequestMethodPOST];
            [postRequest setAccount:acct];
            
            //add text
            [postRequest addMultiPartData:[[dic valueForKey:@"caption"] dataUsingEncoding:NSUTF8StringEncoding] withName:@"status" type:@"multipart/form-data"];
            //add image
            [postRequest addMultiPartData:UIImagePNGRepresentation(image) withName:@"media" type:@"multipart/form-data"];
            
            // Set the account used to post the tweet.
            [postRequest setAccount:acct];
            
            // Post the request
            // Block handler to manage the response
            [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
             {
                 NSLog(@"Twitter response, HTTP response: %i", [urlResponse statusCode]);
             }];
            
            //[self performSelector:@selector(getTwitterFriendsForAccount:) withObject:acct afterDelay:0.0];
            
        }
        
    }
}

-(void)postOnFb:(NSDictionary*)dic{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([[delegate facebook] isSessionValid]) {
        
        UIImage *img  = [dic valueForKey:@"image"];
        NSData *imageData = UIImagePNGRepresentation(img);
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [dic valueForKey:@"caption"], @"message", imageData, @"source", nil];
        [[delegate facebook] requestWithGraphPath:@"me/photos" andParams:params andHttpMethod:@"POST" andDelegate:self];
    }
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */



- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        if ([result count]>0) {
            result = [result objectAtIndex:0];
        }
    }
    
    NSLog(@"value of result %@",result);
    if ([result valueForKey:@"uid"]!=nil) {
        [[NSUserDefaults standardUserDefaults] setValue:[result valueForKey:@"uid"] forKey:@"facebookIdFB"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FBIdUpdate" object:self userInfo:nil];
    }

}

- (void)requestLoading:(FBRequest *)request{

    //NSLog(@"valkue iof %@",request);
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
   // NSLog(@"valkue iof %@",data);
}



-(void)getAddressLocation{

    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:delegate.locationManager.location // You can pass aLocation here instead 
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       dispatch_async(dispatch_get_main_queue(),^ {                           
                           if (placemarks.count == 1) {
                               CLPlacemark *place = [placemarks objectAtIndex:0];                               
                               //NSString *zipString = [place.addressDictionary valueForKey:@"ZIP"];
                               NSArray *arrayForAddress=[place.addressDictionary valueForKey:@"FormattedAddressLines"];
                               NSLog(@"value of address %@",place.addressDictionary);
                               strForCity=[place.addressDictionary valueForKey:@"City"];
                               [self performSelectorInBackground:@selector(showWeatherFor:) withObject:[arrayForAddress componentsJoinedByString:@","]];
                               
                           }
                           
                       });
                       
                   }];
}
-(void)showWeatherFor:(NSString *)zipString{
    strForAddress=zipString;
}

-(NSString *)Base64Encode:(NSData *)theData{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] ;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"string for category name %@",stringForCategoryName );
    if(stringForCategoryName.length==0){
        SelectCategoryViewController *obj=[[SelectCategoryViewController alloc] init];
        [self.parentView addSubview:obj.view];
        CGRect frame = self.parentView.frame;
        if (frame.origin.y==0) {
            frame.origin.y = -410;
        }else{
            frame.origin.y = 40;
        }
        self.parentView.frame = frame;
        [UIView commitAnimations];
    }

     B_PostLock = true;
    
       UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.scrollViewForPost addGestureRecognizer:tap];
//    [self.imgView setImage:[UIImage imageNamed:@"fb_post.png"]];
    [self.imgView addGestureRecognizer:tap];
    txtView.delegate=self;
    txtView.layer.cornerRadius=4.0;
    txtView.layer.masksToBounds=YES;
    txtView.layer.borderWidth=0;
    txtView.layer.borderColor=[UIColor colorWithRed:51.0/255.0 green:170.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    selectedCategory=0;
    
    customRank=[[CustomStarRank alloc] initWithFrame:CGRectMake(40, 324,240, 40)];
    [customRank setValue:0];
    [customRank setUserInteractionEnabled:YES];
    [scrollViewForPost addSubview:customRank];
    
    
    scrollViewTakePhoto=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 200)];
    [scrollViewTakePhoto setBackgroundColor:[UIColor whiteColor]];
    scrollViewTakePhoto.delegate=self;
    [scrollViewTakePhoto setShowsHorizontalScrollIndicator:NO];
    [scrollViewTakePhoto setShowsVerticalScrollIndicator:NO];
      [scrollViewForPost addSubview:scrollViewTakePhoto];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    
    [scrollViewTakePhoto addGestureRecognizer:singleTap];
    
    //UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //[scrollViewForPost addGestureRecognizer:singleTap1];

    
    UIImageView *imageTouch=[[UIImageView alloc] initWithFrame:CGRectMake(280, 210, 30, 23)];
    [imageTouch setImage:[UIImage imageNamed:@"hand.png"]];
    [self.scrollViewForPost addSubview:imageTouch];
    
    arrayForEntitySearch=[[NSMutableArray alloc] init];
    tableViewForSearchEntity=[[UITableView alloc] initWithFrame:CGRectMake(0, 80, 320, 390)];
    tableViewForSearchEntity.delegate=self;
    tableViewForSearchEntity.dataSource=self;
    tableViewForSearchEntity.hidden=YES;
    [self.view addSubview:tableViewForSearchEntity];
    
    
    [scrollViewForPost setContentSize:CGSizeMake(320, 410)];
    scrollViewForPost.userInteractionEnabled = YES;
    //scrollViewForPost.exclusiveTouch = YES;
    parentView = [[UIView alloc]initWithFrame:CGRectMake(0, -460, 320, 460)];
    [self.view addSubview:parentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectCategory)
                                                 name:@"selectCategory" object:nil];
      activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.frame = CGRectMake(0, 0, 90, 90);
    activityIndicatorView.center = self.view.center;
    [self.view addSubview:activityIndicatorView];
    [btnForTakePicture setBackgroundColor:[UIColor lightGrayColor]];
    UITapGestureRecognizer *gestureOnbackbutton = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(actionOnBack:)];
    gestureOnbackbutton.numberOfTapsRequired=1;
    [btn_Back addGestureRecognizer:gestureOnbackbutton];
    UITapGestureRecognizer *gestureOnDonebutton = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(actionOnDone:)];
    gestureOnDonebutton.numberOfTapsRequired=1;
    [btn_Done addGestureRecognizer:gestureOnDonebutton];
    UITapGestureRecognizer *gestureOnSharebutton = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(actionOnShare:)];
    gestureOnSharebutton.numberOfTapsRequired=1;
    [btn_Share addGestureRecognizer:gestureOnSharebutton];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{

     if(stringForCategoryName.length==0 && !B_Share){
        SelectCategoryViewController *obj=[[SelectCategoryViewController alloc] init];
         [self.parentView addSubview:obj.view];
        CGRect frame = self.parentView.frame;
        if (frame.origin.y==0) {
            frame.origin.y = -410;
        }else{
            frame.origin.y = 40;
        }
        self.parentView.frame = frame;
        [UIView commitAnimations];
//       stringForCategoryName = @"";
   }
    checkStatus =   [[[NSUserDefaults standardUserDefaults] valueForKey:@"swichOnOffStatus"] boolValue];
    NSLog(@"status  = = = = = =  = = = = = = = = %d", checkStatus);
     [activityIndicatorView stopAnimating];
    [self.view endEditing:YES];
    [txtView resignFirstResponder];
    if(B_Share){
        [scrollViewForPost setContentSize:CGSizeMake(320, (410+txtView.frame.size.height))];
//          [scrollViewForPost setContentSize:CGSizeMake(320, 410+txtView.contentSize.height)];
        
        B_Share = false;
    }
    [scrollViewForPost setContentOffset:CGPointMake(0, 0) animated:YES];
    [btn_Share setFrame:CGRectMake(256, 260, 54, 24)];
    [self.tabBarController setTabBarHidden:YES animated:NO completion:NULL];
    
    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.btnPost.hidden = YES;
    strForAddress=delegate.strForAddressDelegate;
    [self performSelector:@selector(getAddressLocation) withObject:nil afterDelay:0.5];
    self.navigationController.navigationBar.hidden=YES;
    
    if (pushApplyFilter) {
        pushApplyFilter=NO;
        
        ApplyFilterViewController *filObj=[[ApplyFilterViewController alloc] init];
        filObj.imageOrg=[imageFinal copy];//[imageFinal thumbnailImage:640 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
        //filObj.imageOrg=[image copy];
        [self.navigationController pushViewController:filObj animated:YES];
        
        //        CropViewController *obj=[[CropViewController alloc] init];
        //        obj.imgSet=[imageFinal copy];
        //        obj.delegate=self;
        //        obj.sizeForCrop=CGRectMake(1, 100, 318, 250);
        //        [self.navigationController pushViewController:obj animated:YES];
        return;
    }
    
   
        if (btnForTakePicture!=nil) {
            [btnForTakePicture removeFromSuperview];
        }
        if (imageFinal!=nil) {
        btnForTakePicture=[[UIImageView alloc] initWithImage:imageFinal];
             [scrollViewTakePhoto setScrollEnabled:YES];
        }
        UIImage *imageload=[btnForTakePicture image];
    CGFloat imageWidth = imageload.size.width;
    CGFloat imageHeight = imageload.size.height;
    
    int scrollWidth = scrollViewTakePhoto.frame.size.width;
    int scrollHeight = scrollViewTakePhoto.frame.size.height;
    
    float scaleX = scrollWidth / imageWidth;
    float scaleY = scrollHeight / imageHeight;
    float scaleScroll =  (scaleX < scaleY ? scaleY : scaleX);
    //scrollViewTakePhoto.bounds = CGRectMake(0, 0,imageWidth , imageHeight );
    scrollViewTakePhoto.contentSize = imageload.size;
    scrollViewTakePhoto.maximumZoomScale = scaleScroll*3;
    scrollViewTakePhoto.minimumZoomScale = scaleScroll;
    scrollViewTakePhoto.zoomScale = scaleScroll;
   
    
       if (imageload==nil) {
        imageload=[UIImage imageNamed:@"placeholderImage.png"];
           btnForTakePicture=[[UIImageView alloc] initWithImage:imageload];
          [btnForTakePicture setFrame:CGRectMake(0, 0, 320, 200)];
         scrollViewTakePhoto.contentSize = CGSizeMake(320, 200);
           [scrollViewTakePhoto setScrollEnabled:NO];
       }
         [scrollViewTakePhoto addSubview:btnForTakePicture];
        //btnForTakePicture=[[UIImageView alloc] initWithImage:imageload];//welike_screen5
       
    if (dicForCategorySelected==nil) {
        [self performSelector:@selector(callSelect) withObject:nil afterDelay:0.3];
    }else{
        
        if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Books"]) {
            //Book
            selectedCategory=0;
            txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Restaurants"]) {
            //Restaurant
            selectedCategory=1;
            txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Music"]) {
            //Music
            selectedCategory=2;
            txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Movies & TV"]) {
            //Movie & TV
            selectedCategory=3;
            txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Apps & Games"]) {
            //Apps & Games
            selectedCategory=4;
            txtField.returnKeyType = UIReturnKeySearch;
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Bars & Nightlife"]) {
            //Bars & Nightlife
            selectedCategory=1;
            txtField.returnKeyType = UIReturnKeySearch;
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Places & Activities"]) {
            //Places & Activities
            selectedCategory=1;
            txtField.returnKeyType = UIReturnKeySearch;
        }
        
        
        [btnForSelecte setTitle:[dicForCategorySelected valueForKey:@"master_category_name"] forState:UIControlStateNormal];
    }
   
    if ([txtView.text length]>80) {
        CGRect newTextFrame = txtView.frame;
        newTextFrame.size = txtView.contentSize;
        [customRank setFrame:CGRectMake(40,(txtView.contentSize.height-28)+318 ,240, 40)];
        //    customRank=[[CustomStarRank alloc] initWithFrame:CGRectMake(40,(textView.contentSize.height-34)+318 ,240, 40)];
        [btn_Back setFrame:CGRectMake(btn_Back.frame.origin.x, (txtView.contentSize.height-34)+364, btn_Back.frame.size.width, btn_Back.frame.size.height)];
        [btn_Done setFrame:CGRectMake(btn_Done.frame.origin.x, (txtView.contentSize.height-34)+364, btn_Done.frame.size.width, btn_Done.frame.size.height)];
        [ImgView_StarRating setFrame:CGRectMake(ImgView_StarRating.frame.origin.x, (txtView.contentSize.height-34)+323, ImgView_StarRating.frame.size.width, ImgView_StarRating.frame.size.height)];
        [v_BottomView setFrame:CGRectMake(0, (txtView.contentSize.height-34)+318, 320, 87)];
        [btn_Share setFrame:CGRectMake(255, (txtView.contentSize.height+240), 54, 25)];
        newTextFrame.size.height = newTextFrame.size.height + fontHeight;
        
        
        txtView.frame = newTextFrame;
        textViewHeight = txtView.frame.size.height;
        [scrollViewForPost setContentSize:CGSizeMake(320, 410+txtView.contentSize.height)];
        [scrollViewForPost setContentOffset:CGPointMake(0, 200+txtView.contentSize.height) animated:YES];

    }    
}
-(void)viewWillDisappear:(BOOL)animated
{
    if(B_Share){
//        B_Share = false;
         [scrollViewForPost setContentSize:CGSizeMake(320, (410+txtView.frame.size.height+fontHeight))];
        [scrollViewForPost setContentOffset:CGPointMake(320, (410+txtView.frame.size.height+fontHeight)) animated:YES];
    }
    else{
        [btn_Back setFrame:CGRectMake(btn_Back.frame.origin.x, 364, btn_Back.frame.size.width, btn_Back.frame.size.height)];
        [btn_Done setFrame:CGRectMake(btn_Done.frame.origin.x, 364, btn_Done.frame.size.width, btn_Done.frame.size.height)];
        [ImgView_StarRating setFrame:CGRectMake(ImgView_StarRating.frame.origin.x, 323, ImgView_StarRating.frame.size.width, ImgView_StarRating.frame.size.height)];
    [txtView setFrame:CGRectMake(9,255, 301, 62)];
     [v_BottomView setFrame:CGRectMake(0,318, 320, 95)];
     [scrollViewForPost setContentSize:CGSizeMake(320, 410)];
    [customRank setFrame:CGRectMake(40, 324,240, 40)];
    }
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
}

#pragma mark-Inner method

-(void)keyboardWillShow:(NSNotification*)noti{
    
    if (checkKeyBoard==YES) {
    [scrollViewForPost setContentSize:CGSizeMake(320, (410+220+txtView.frame.size.height))];
          [scrollViewForPost setContentOffset:CGPointMake(0, 220+fontHeight) animated:YES];
        NSLog(@"total content size = = = = %f", (txtView.frame.size.height+180+410));
    UIView *viewForReturn=[[UIView alloc] initWithFrame:CGRectMake(240+2-3, 174-5, 78-10+10+5, 38+10)];
    [viewForReturn setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"KeyPadBackgroundColor.png"]]];
    viewForReturn.userInteractionEnabled=YES;
    
    //Add button to keyboard
    UIButton *atTheRateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    atTheRateBtn.frame = CGRectMake(5, 2+2, 30, 36+6);
    atTheRateBtn.adjustsImageWhenHighlighted = NO;
    [atTheRateBtn.layer setCornerRadius:3];
    
    [atTheRateBtn setBackgroundImage:[UIImage imageNamed:@"btn_at_the_rate.png"] forState:UIControlStateNormal];
    atTheRateBtn.tag=1;
    [atTheRateBtn addTarget:self action:@selector(actionOnKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *hashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hashButton.frame = CGRectMake(40, 2+2, 30, 36+5+1);
    hashButton.adjustsImageWhenHighlighted = NO;
    hashButton.tag=2;
    [hashButton.layer setCornerRadius:3];
    [hashButton setBackgroundImage:[UIImage imageNamed:@"btn_hash.png"] forState:UIControlStateNormal];
    [hashButton addTarget:self action:@selector(actionOnKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    UIView* keyboard;
    for(int i=0; i<[tempWindow.subviews count]; i++) {
        keyboard = [tempWindow.subviews objectAtIndex:i];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
            if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)  {
                
                [keyboard addSubview:viewForReturn];
                [viewForReturn addSubview:atTheRateBtn];
                [viewForReturn addSubview:hashButton];
            }
        } else {
            if([[keyboard description] hasPrefix:@"<UIKeyboard"] == YES) {
                
                [keyboard addSubview:viewForReturn];
                [viewForReturn addSubview:atTheRateBtn];
                [viewForReturn addSubview:hashButton];
            }
        }
    }
  }
}
-(void)dismissKeyboard {
    [txtView resignFirstResponder];
    [txtField resignFirstResponder];
    if(txtView.text==0){
        [scrollViewForPost setContentSize:CGSizeMake(320, (410))];
        [scrollViewForPost setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else{
     [scrollViewForPost setContentSize:CGSizeMake(320, (410+fontHeight+textViewHeight)-60)];
    [scrollViewForPost setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(void)actionOnKeyBoard:(UIButton *)btn{
    //AudioServicesPlaySystemSound(0x450);
    lblForWrite.hidden=YES;
    if (btn.tag==1) {
        NSString *strForInput=[NSString stringWithFormat:@"%@@",txtView.text];
        [self.txtView setTextColor:[UIColor blueColor] ];
        txtView.text=strForInput;
        //isPrevious=YES;
    }else if (btn.tag==2){
        NSString *strForInput=[NSString stringWithFormat:@"%@#",txtView.text];
        [self.txtView setTextColor:[UIColor blueColor] ];
        txtView.text=strForInput;
        //isPrevious=NO;
    }
    else{
        NSLog(@"I m here");
    }
    
}


- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    // single tap handling
    id obj=gestureRecognizer.view;
    if ([obj isEqual:scrollViewForPost]) {
        
        [self.view endEditing:YES];
        [scrollViewForPost setContentSize:CGSizeMake(320, 450)];
        [scrollViewForPost setContentOffset:CGPointMake(0, 0) animated:YES];

    }else{
        NSLog(@"sinlgeTap called");
        [self.view endEditing:YES];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

        if(keyBordUp)
        {
             [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
            keyBordUp = false;
        }
        else{
            CameraViewController *myViewController = [[CameraViewController alloc] init];
            myViewController.dicForAllMasterCategory = [dicForCategorySelected copy];
            [self presentModalViewController:myViewController animated:YES];

        }
     
    }
    

}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}     


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"number of entity %d", [arrayForEntitySearch count]);
    if([arrayForEntitySearch count]== 0)
        return 0;
    else
	return  [arrayForEntitySearch count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	static NSString *CellIdentifier1 = @"Cell";
    
    UITableViewCell *cellSug= (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    if (cellSug == nil) {
        cellSug = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
    }
    cellSug.selectionStyle=UITableViewCellSelectionStyleNone;
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0f,15.0f, 150.0f, 20.0f)];
    [lbl setText:@"can't find it?"];
//    [[lbl setFont ]UIFont systemFontOfSize:16];
    lbl.font = [UIFont systemFontOfSize:16];
    lbl.textColor = [UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0];

//    cellSug.textLabel.text=@"can't find it?";//suggest_btn
  
   
    [cellSug.textLabel setFont:[UIFont systemFontOfSize:16]];;
    [cellSug.textLabel setTextColor:[UIColor colorWithRed:51.0/255.0 green:153.0/255.0 blue:255.0/255.0 alpha:1.0]];
      [cellSug addSubview:lbl];
    UIImageView *imgeSug=[[UIImageView alloc] initWithFrame:CGRectMake(150, 10, 150, 30)];
    [imgeSug setImage:[UIImage imageNamed:@"suggest_btn.png"]];
    [cellSug addSubview:imgeSug];
    NSLog(@"number of index path = %d", indexPath.row);
    if (indexPath.row ==[arrayForEntitySearch count]) {
        return cellSug;
    }
    int index=indexPath.row;
    SearchResultEntity *cell= (SearchResultEntity*)[tableView dequeueReusableCellWithIdentifier:nil];
    
    if (cell == nil) {
        cell = [[SearchResultEntity alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    
    //[cell.textLabel setFont:[UIFont boldSystemFontOfSize:16]];
    //[cell.textLabel setTextColor:[UIColor grayColor]];
    if (index<[arrayForEntitySearch count] && selectedCategory==0) {
        
        //cell.textLabel.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"entity_name"];
        if ([[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"artworkUrl100"] hasPrefix:@"http://"]) {
            [cell.imgForEntity loadImage:[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"artworkUrl100"]];
        }
        cell.lblForEntityName.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"trackCensoredName"];
        [cell.lblForEntityName setFont:[UIFont boldSystemFontOfSize:15]];
        NSArray *arrayGenres=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"genres"];
        cell.lblForEntityDisc.text=[arrayGenres componentsJoinedByString:@","];
    }else if (index<[arrayForEntitySearch count] && selectedCategory==1) {
        
        NSArray *arrayForCate=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"categories"];
        NSDictionary *dicForLocation=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"location"];
        NSArray *iconImg;
        
        
        if ([arrayForCate count]>0) {
            iconImg= [[arrayForCate objectAtIndex:0] valueForKey:@"icon"];
        }
        NSString *iconUrl = [iconImg valueForKey:@"prefix"];
        if ([iconUrl length] != 0) {
            if ([iconUrl hasSuffix:@"_"]) {
                NSRange range = NSMakeRange([iconUrl length]-1,1);
                NSString *newText = [iconUrl stringByReplacingCharactersInRange:range withString:@".png"];
                [cell.imgForEntity loadImage:newText];
                [cell.imgForEntity setBackgroundColor:[UIColor clearColor]];
            }
        }
        
        NSString *strForAddress1=@"";
        if ([dicForLocation valueForKey:@"city"]==nil && [dicForLocation valueForKey:@"country"]==nil) {
            strForAddress1=[NSString stringWithFormat:@"%@",[dicForLocation valueForKey:@"address"]];
        }else if ([dicForLocation valueForKey:@"country"]!=nil) {
            strForAddress1=[NSString stringWithFormat:@"%@ %@",[dicForLocation valueForKey:@"address"],[dicForLocation valueForKey:@"city"]];
        }else if ([dicForLocation valueForKey:@"address"]==nil) {
            strForAddress1=[NSString stringWithFormat:@"%@ %@",[dicForLocation valueForKey:@"city"],[dicForLocation valueForKey:@"country"]];
        }else{
            strForAddress1=[NSString stringWithFormat:@"%@ %@ %@",[dicForLocation valueForKey:@"address"],[dicForLocation valueForKey:@"city"],[dicForLocation valueForKey:@"country"]];
        }
        //cell.textLabel.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"name"];
        //if ([strForUrl hasPrefix:@"http://"]) {
        
        //}
        [cell.lblForEntityName setFont:[UIFont boldSystemFontOfSize:15]];
        cell.lblForEntityName.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"name"];
        
        //[[[[arrayForEntitySearch objectAtIndex:indexPath.row-1] valueForKey:@"categories"] objectAtIndex:0] valueForKey:@"name"];
        cell.lblForEntityDisc.text=[[[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"categories"] objectAtIndex:0] valueForKey:@"name"];
    }else if (index<[arrayForEntitySearch count] && (selectedCategory==2 || selectedCategory==3 || selectedCategory==4)) {
        
        //cell.textLabel.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"entity_name"];
        //[cell.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
        if ([[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"artworkUrl100"] hasPrefix:@"http://"]) {
            [cell.imgForEntity loadImage:[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"artworkUrl100"]];
        }
        if (selectedCategory==3 && [[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"collectionType"] isEqualToString:@"TV Season"]) {
            cell.lblForEntityName.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"collectionName"];
        }else{
            cell.lblForEntityName.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"trackCensoredName"];
        }
        
        cell.lblForEntityDisc.text=[[arrayForEntitySearch objectAtIndex:index] valueForKey:@"primaryGenreName"];
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row==[arrayForEntitySearch count]) {
        tableViewForSearchEntity.hidden=YES;
        
        addEnityViewController *obj=[[addEnityViewController alloc] init];
        obj.strForMasterCate=[dicForCategorySelected valueForKey:@"master_category_id"];
        [self.navigationController pushViewController:obj animated:YES];
        
        return;
    }
    
    if (indexPath.row<[arrayForEntitySearch count]) {
        
//        btnForTakePicture.image=nil;
        if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Books"] || [[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Music"] ||[[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Movies & TV"] ||[[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Apps & Games"] ) {
            //Book
            //selectedCategory=0;
            NSString *strForKind=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"collectionType"];
            if ([[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"artworkUrl100"] hasPrefix:@"http://"]) {
                //[cell.imgForEntity loadImage:[[arrayForEntitySearch objectAtIndex:indexPath.row-1] valueForKey:@"artworkUrl100"]];
                NSMutableString *unescapedString = [[NSMutableString alloc] initWithString:[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"artworkUrl100"]];
                
                
                if ([strForKind isEqualToString:@"TV episode" ]||[strForKind isEqualToString:@"TV Season"]) {
                    [unescapedString replaceOccurrencesOfString:@".100x100-75" withString:@"" options:0 range:NSMakeRange(0, [unescapedString length])];
                    txtField.text=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"collectionName"];
                }else{
                    txtField.text=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"trackCensoredName"];
                    [unescapedString replaceOccurrencesOfString:@"100x100" withString:@"600x600" options:0 range:NSMakeRange(0, [unescapedString length])];
                }
                
                [self showHUD];
                //               [activityIndicatorView startAnimating];
                [self performSelector:@selector(loadImageFromURL:) withObject:unescapedString afterDelay:0.2];
            }
            
            if ([strForKind isEqualToString:@"TV episode" ]||[strForKind isEqualToString:@"TV Season"]) {
                strForSeletedAppID=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"collectionId"];
            }else{
                strForSeletedAppID=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"trackId"];
            }
            
            
            if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Books"]) {
                
                NSArray *arrayGenres=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"genres"];
                
                strForSubcategoryName=[arrayGenres componentsJoinedByString:@" "];
                
            }else {
                strForSubcategoryName=[NSString stringWithFormat:@"%@",[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"primaryGenreName"]];
            }
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Restaurants"]||[[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Bars & Nightlife"]||[[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Places & Activities"]) {
            //Restaurant
            
            NSDictionary *dicForLocation=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"location"];
            strForLatFourSqaure=[NSString stringWithFormat:@"%@",[dicForLocation valueForKey:@"lat"]];
            strForLongFourSqaure=[NSString stringWithFormat:@"%@",[dicForLocation valueForKey:@"lng"]];
            if (btnForTakePicture!=nil) {
                [btnForTakePicture removeFromSuperview];
            }
            
            
            selectedCategory=1;
            txtField.text=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"name"];
            strForSeletedAppID=[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"id"];
            
            if ([[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"categories"] count]>0) {
                strForSubcategoryName=[[[[arrayForEntitySearch objectAtIndex:indexPath.row] valueForKey:@"categories"] objectAtIndex:0] valueForKey:@"name"];
            }
            [self performSelector:@selector(callServiceForPhoto)];
            
        }
        tableViewForSearchEntity.hidden=YES;
    }
}

-(void)callServiceForPhoto{

    NSString *strForURl=[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos?client_id=TWGGGBVF2RXHKNWBNLJQGJ5HYKDXO5UIQJISNSF3CFR2ANIQ&client_secret=UU01JFEPXPO55ZNZIBQIIVXLSLGTEIY0SNXPLI402OGM4AOJ&group=venue&v=20130531",strForSeletedAppID];
    
    NSURL *url = [NSURL URLWithString:[strForURl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   NSError* parseError;
                                   id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                                   //NSLog(@"*************** image responce %@",parse);
                                   
                                   NSDictionary *dicResponse=(NSDictionary*)[parse objectForKey:@"response"];
                                   NSDictionary *arrayForPhotos=[dicResponse valueForKey:@"photos"];
                                   
                                   if ([arrayForPhotos count]>0) {
                                       
                                       NSArray *items=[arrayForPhotos  valueForKey:@"items"];
                                       
                                       if ([items count]>0) {
                                           
                                           NSString *strForUrl=[NSString stringWithFormat:@"%@%@x%@%@",[[items objectAtIndex:0] valueForKey:@"prefix"],[[items objectAtIndex:0] valueForKey:@"width"],[[items objectAtIndex:0] valueForKey:@"height"],[[items objectAtIndex:0] valueForKey:@"suffix"]];
                                           [self showHUD];
//                                            [activityIndicatorView startAnimating];
                                           [self performSelector:@selector(loadImageFromURL:) withObject:strForUrl afterDelay:0.2];
                                       }else{
                                       [self performSelector:@selector(loadDefualtImage)];
                                       }
                                       
                                   }else{
                                   
                                      [self performSelector:@selector(loadDefualtImage)];
                                   }
                                   
                               }else {
                                   [self performSelector:@selector(killHUD) withObject:nil afterDelay:1];
                                   UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"No image found on this venue." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                   [alert show];
                                   
                                   [self performSelector:@selector(loadDefualtImage)];
                                  
                                   
                               }
                               
                           }];
    
    
    //*************************************************************

}

-(void)loadDefualtImage{

    
    NSString *strForTitle=[btnForSelecte currentTitle];
    if ([strForTitle isEqualToString:@"Restaurants"]) {
        btnForTakePicture=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Food.png"]];
    }else if ([strForTitle isEqualToString:@"Bars & Nightlife"]){
        btnForTakePicture=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bar&Night.png"]];
        
    }else if ([strForTitle isEqualToString:@"Places & Activities"]){
        btnForTakePicture=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Activity&Place.png"]];
        
    }
    UIImage *imageload=[btnForTakePicture image];
    //btnForTakePicture=[[UIImageView alloc] initWithImage:imageload];//welike_screen5
    CGFloat imageWidth = imageload.size.width;
    CGFloat imageHeight = imageload.size.height;
    
    int scrollWidth = scrollViewTakePhoto.frame.size.width;
    int scrollHeight = scrollViewTakePhoto.frame.size.height;
    
    float scaleX = scrollWidth / imageWidth;
    float scaleY = scrollHeight / imageHeight;
    float scaleScroll =  (scaleX < scaleY ? scaleY : scaleX);
    //scrollViewTakePhoto.bounds = CGRectMake(0, 0,imageWidth , imageHeight );
    scrollViewTakePhoto.contentSize = imageload.size;
    scrollViewTakePhoto.maximumZoomScale = scaleScroll*3;
    scrollViewTakePhoto.minimumZoomScale = scaleScroll;
    scrollViewTakePhoto.zoomScale = scaleScroll;
    [scrollViewTakePhoto addSubview:btnForTakePicture];
     [scrollViewTakePhoto setScrollEnabled:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row==0) {
//        return 50;
//    }
    return 75;
}

-(void)loadImageFromURL:(NSString *)str{

    NSLog(@"value of url %@",str);
    NSData *data=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:str]];
    
    UIImage *imageload=[UIImage imageWithData:data];
    
    if (btnForTakePicture!=nil) {
        [btnForTakePicture removeFromSuperview];
    }
    
    if (imageload!=nil) {
    
    btnForTakePicture=[[UIImageView alloc] initWithImage:imageload];//welike_screen5
    CGFloat imageWidth = imageload.size.width;
    CGFloat imageHeight = imageload.size.height;
    
    int scrollWidth = scrollViewTakePhoto.frame.size.width;
    int scrollHeight = scrollViewTakePhoto.frame.size.height;
    
    float scaleX = scrollWidth / imageWidth;
    float scaleY = scrollHeight / imageHeight;
    float scaleScroll =  (scaleX < scaleY ? scaleY : scaleX);
    //scrollViewTakePhoto.bounds = CGRectMake(0, 0,imageWidth , imageHeight );
    scrollViewTakePhoto.contentSize = imageload.size;
    scrollViewTakePhoto.maximumZoomScale = scaleScroll*3;
    scrollViewTakePhoto.minimumZoomScale = scaleScroll;
    scrollViewTakePhoto.zoomScale = scaleScroll;
      
    [scrollViewTakePhoto addSubview:btnForTakePicture];
     [scrollViewTakePhoto setScrollEnabled:YES];
       
    }else{
        [self performSelector:@selector(loadDefualtImage)];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error to load image" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
    }
    [self killHUD];
//      [activityIndicatorView stopAnimating];
}


/****** UIScrollView delegate for zooming **********/
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return btnForTakePicture;
//}
/**************************************************/


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqual:@"\n"]) {
        if ([txtView.text length]==0) {
            lblForWrite.hidden=NO;
    }
        [textView resignFirstResponder];
        return NO;
    }else if ([txtView.text length]==1 && [text isEqualToString:@""]){
        lblForWrite.hidden=NO;
    }else{
        lblForWrite.hidden=YES;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    fontHeight = (textView.font.ascender - textView.font.descender) + 1;
    CGRect newTextFrame = textView.frame;
    newTextFrame.size = textView.contentSize;
    [customRank setFrame:CGRectMake(40,(textView.contentSize.height-28)+318 ,240, 40)];
//    customRank=[[CustomStarRank alloc] initWithFrame:CGRectMake(40,(textView.contentSize.height-34)+318 ,240, 40)];
    [btn_Back setFrame:CGRectMake(btn_Back.frame.origin.x, (textView.contentSize.height-34)+364, btn_Back.frame.size.width, btn_Back.frame.size.height)];
    [btn_Done setFrame:CGRectMake(btn_Done.frame.origin.x, (textView.contentSize.height-34)+364, btn_Done.frame.size.width, btn_Done.frame.size.height)];
    [ImgView_StarRating setFrame:CGRectMake(ImgView_StarRating.frame.origin.x, (textView.contentSize.height-34)+323, ImgView_StarRating.frame.size.width, ImgView_StarRating.frame.size.height)];
     [btn_Share setFrame:CGRectMake(250, (textView.contentSize.height-70)+315, 54, 25)];
    [v_BottomView setFrame:CGRectMake(0, (textView.contentSize.height-34)+318, 320, 87)];
    // [btn_Share setFrame:CGRectMake(255, (textView.contentSize.height+240), 54, 25)];
    newTextFrame.size.height = newTextFrame.size.height + fontHeight;
   
   
    txtView.frame = newTextFrame;
    textViewHeight = txtView.frame.size.height;
    [scrollViewForPost setContentSize:CGSizeMake(320, 630+textView.contentSize.height)];
     [scrollViewForPost setContentOffset:CGPointMake(0, 200+textView.contentSize.height) animated:YES];
//    newTextFrame.origin.y = newTextFrame.origin.y-20;
 
   
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView{

    lblForWrite.hidden=YES;
    checkKeyBoard=YES;
    
    [txtField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"KeyBoardHide" object:nil];
//    [scrollViewForPost setContentSize:CGSizeMake(320, (410+fontHeight+40))];
//    [scrollViewForPost setContentOffset:CGPointMake(0, 220) animated:YES];
    
//[btn_Share setFrame:CGRectMake(250, 330-220, 54, 25)];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
   //lblForWrite.hidden=NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
   
    
        [scrollViewForPost setContentSize:CGSizeMake(320, (410+fontHeight+80))];
     [scrollViewForPost setContentOffset:CGPointMake(0, 0) animated:YES];
    

}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return ![view isKindOfClass:[UIButton class]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
     [scrollViewForPost setContentSize:CGSizeMake(320, 410)];
    [txtView resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"KeyBoardHide"
                                                  object:nil];
}
-(void)keyboardWillHide:(NSNotification*)noti{
     [scrollViewForPost setContentOffset:CGPointMake(0, 220+txtView.frame.size.height) animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardShow" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
    [txtView resignFirstResponder];
    if ([dicForCategorySelected count]==0) {
        [self performSelector:@selector(showAlert)];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    keyBordUp = true;
    checkKeyBoard=NO;
    [txtView resignFirstResponder];
    [txtField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KeyBoardHide" object:nil];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{

    
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:@"KeyBoardHide" object:nil];
//    [activityIndicatorView startAnimating];
}
-(void)showAlert{
  
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Please select category." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.text.length>1 )
    {
        if ([dicForCategorySelected count]==0) {
//             [self performSelector:@selector(showAlert)];
        }
        else if ([[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Places & Activities"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Bars & Nightlife"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Apps & Games"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Movies & TV"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Music"] || [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Restaurants"]||[[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Books"])
        {
                [activityIndicatorView startAnimating];
        }

    
    }
    else{
        [activityIndicatorView stopAnimating];
    }
    NSString *strForTitle=[btnForSelecte currentTitle];
    if ([strForTitle isEqualToString:@"Apps & Games"]|| [strForTitle isEqualToString:@"Music"]|| [strForTitle isEqualToString:@"Books"]|| [strForTitle isEqualToString:@"Movies & TV"]|| [strForTitle isEqualToString:@"Restaurants"] || [strForTitle isEqualToString:@"Bars & Nightlife"]||[strForTitle isEqualToString:@"Places & Activities"]){
        
        if ([textField.text length]>1) {
            
//            if ([arrayForEntitySearch count]>0) {
//                [arrayForEntitySearch removeAllObjects];
//            }
            //[tableViewForSearchEntity reloadData];
            tableViewForSearchEntity.hidden=NO;
//            [self showHUD];
//              [activityIndicatorView startAnimating];
            if ([strForTitle isEqualToString:@"Apps & Games"]|| [strForTitle isEqualToString:@"Music"]|| [strForTitle isEqualToString:@"Books"]|| [strForTitle isEqualToString:@"Movies & TV"]) {
                
                
                [self performSelector:@selector(callItunesWebService:) withObject:textField.text afterDelay:0.2];
                //[self performSelector:@selector(callSearchService:) withObject:textField.text afterDelay:0];
                
            }else if ([strForTitle isEqualToString:@"Restaurants"] || [strForTitle isEqualToString:@"Bars & Nightlife"] || [strForTitle isEqualToString:@"Places & Activities"]){
                
                AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                NSString *strForlate=[NSString stringWithFormat:@"%f",delegate.currentLatitude];
                NSString *strForlong=[NSString stringWithFormat:@"%f",delegate.currentLongitute];
               
                NSString *strForCategoryID=@"";
                if ([strForTitle isEqualToString:@"Restaurants"]) {
                    strForCategoryID=@"4d4b7105d754a06374d81259";
                }else if ([strForTitle isEqualToString:@"Bars & Nightlife"]){
                    strForCategoryID=@"4d4b7105d754a06376d81259";
                }else if ([strForTitle isEqualToString:@"Places & Activities"]){
                    strForCategoryID=@"4d4b7104d754a06370d81259,4d4b7105d754a06375d81259,4d4b7105d754a06372d81259,4bf58dd8d48988d17b941735,4e67e38e036454776db1fb3a,4d4b7105d754a06377d81259,4d4b7105d754a06378d81259,4d4b7105d754a06379d81259";//name: "College & University"
                }
                
                NSString *strForURl=[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?categoryId=%@&ll=%@,%@&query=%@&radius=10000&intent=browse&v=20130506&client_secret=UU01JFEPXPO55ZNZIBQIIVXLSLGTEIY0SNXPLI402OGM4AOJ&client_id=TWGGGBVF2RXHKNWBNLJQGJ5HYKDXO5UIQJISNSF3CFR2ANIQ",strForCategoryID, strForlate,strForlong,textField.text];
                
                NSURL *url = [NSURL URLWithString:[strForURl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           if (!error) {
                                               NSError* parseError;
                                               id parse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
                                               arrayForEntitySearch = [[[parse objectForKey:@"response"] objectForKey:@"venues"] copy];
                                               NSLog(@"value of array %@",arrayForEntitySearch);
                                                if ([arrayForEntitySearch count]==0) {
                                                    self.tableViewForSearchEntity.hidden=YES;
                                                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No data found." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                    [alert show];
                                                }
                                               
                                               [tableViewForSearchEntity reloadData];
                                               [self performSelector:@selector(killActivityindicator) withObject:nil afterDelay:1];
                                               
                                           }else {
                                               [self performSelector:@selector(killActivityindicator) withObject:nil afterDelay:1];
                                               UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No data found." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                               [alert show];
                                           }

                                       }];
                
                
                //*************************************************************
                
                
            }
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Please enter more then two character." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }
    [txtField resignFirstResponder];
    return YES;
}

//******************** Search category ***********************************
///https://api.foursquare.com/v2/venues/search?categoryId=4bf58dd8d48988d121941735,4bf58dd8d48988d11f941735,4bf58dd8d48988d1d8941735,4bf58dd8d48988d1e9931735,4bf58dd8d48988d1e7931735&ll=47.6097,-122.3331&radius=10000&intent=browse&v=20120801
//https://foursquare.com/v/last-supper-club/40b13b00f964a520a7f61ee3
//...?categoryId=4bf58dd8d48988d1d8941735&ll=47.6097,-122.3331&radius=10000&intent=browse&v=20120801

//http://itunes.apple.com/search?term=makamaka&media=software&lang=en_US&country=us
-(void)callItunesWebService:(NSString*)stringForSearch{

   [tableViewForSearchEntity setContentOffset:CGPointMake(0, 0) animated:YES];
    NSString *str=@"";
    if (selectedCategory==0) {
        str=[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=ebook&lang=en_US&limit=50",stringForSearch];
    }else if (selectedCategory==1) {
        str=[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=movie&media=tvShow&lang=en_US&limit=50",stringForSearch];
    }else if (selectedCategory==2) {
        //Music
        str=[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=music&lang=en_US&limit=50",stringForSearch];
    }else if (selectedCategory==3) {
        //Movie & TV
        str=[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=movie&media=tvShow&lang=en_US&limit=50",stringForSearch];
        [self performSelector:@selector(callItunesWebServiceMovieTV:) withObject:stringForSearch afterDelay:0.0];
        return;
        
    }else if (selectedCategory==4) {
        str=[NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@&media=software&lang=en_US&country=us&limit=50",stringForSearch];
    }
    //NSString *str=[NSString stringWithFormat:@"https://itunes.apple.com/search?term=sonu&media=movie&limit=25"];
    NSLog(@"value of str************* %@",str);
    NSURL *url=[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"value of url value ******** %@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60];
    //[request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response error:&error];
    
    if(error && [error code] == NSURLErrorUserCancelledAuthentication)
    {
    }
    if(response.statusCode != 200)
    {
        // [self interpretHTTPError:response.statusCode URLError:error forMethod:method];
        // return nil;ent
    }
    NSString* newStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] ;
    //NSString *str1=[newStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    //NSLog(@"value of data %@",str);
    id jsonArray = [NSJSONSerialization JSONObjectWithData: [newStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
       //NSLog(@"value of response %@",[[jsonArray class] description]);
//    [self killHUD];
     [activityIndicatorView stopAnimating];
    if ([[jsonArray valueForKey:@"results"] count]==0) {
        //self.tableViewForSearchEntity.hidden=YES;
        [tableViewForSearchEntity reloadData];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Message"
                                   message: @"No data found."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        return;
    }
    
    if(error)
    {
        //self.tableViewForSearchEntity.hidden=YES;
        [tableViewForSearchEntity reloadData];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Error"
                                   message: @"Error from server please try again later."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];

        NSLog(@"JSONObjectWithData failed with error: %@\n", error);
    }else{
        arrayForEntitySearch=[[NSMutableArray alloc] initWithArray:[jsonArray valueForKey:@"results"] copyItems:YES];
        [tableViewForSearchEntity reloadData];
    }
    //NSLog(@"value of JSon array %@",jsonArray);
    
     //https://itunes.apple.com/search?term=jack+johnson&entity=musicVideo
    //https://itunes.apple.com/search?term=jack+johnson&entity=musicVideo
    //https://itunes.apple.com/search?term=jack+johnson&entity=musicVideo
    
}


-(void)callItunesWebServiceMovieTV:(NSString*)stringForSearch{
    
    
    NSString *str=[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=movie&lang=en_US&limit=50",stringForSearch];
        
    NSURL *url=[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60];
    //[request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&response error:&error];
    
    if(error && [error code] == NSURLErrorUserCancelledAuthentication)
    {
    }
    if(response.statusCode != 200)
    {
    }
    NSString* newStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] ;
    //NSString *str1=[newStr stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    //NSLog(@"value of data %@",str);
    id jsonArray = [NSJSONSerialization JSONObjectWithData: [newStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
    NSArray *arrayForTV;
    if (selectedCategory==3) {
        NSString *str=[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=tvSeason&lang=en_US&limit=50",stringForSearch];
        
        NSURL *url=[NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:60];
        //[request setHTTPMethod:@"GET"];
        
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *result = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:&response error:&error];
        
        if(error && [error code] == NSURLErrorUserCancelledAuthentication)
        {
        }
        if(response.statusCode != 200)
        {
            // [self interpretHTTPError:response.statusCode URLError:error forMethod:method];
            // return nil;ent
        }
        NSString* newStr = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] ;
        
        id jsonArrayLocal = [NSJSONSerialization JSONObjectWithData: [newStr dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        
        if ([[jsonArrayLocal valueForKey:@"results"] count]==0) {
            
        }else if(error)
        {
            
        }else{
            if ([[jsonArray valueForKey:@"results"] count]==0) {
                arrayForEntitySearch=[[NSMutableArray alloc] initWithArray:[jsonArrayLocal valueForKey:@"results"] copyItems:YES];
                [tableViewForSearchEntity reloadData];
                
                NSLog(@"value of arrayForEntitySearch %@",arrayForEntitySearch);
//                [self killHUD];
                [activityIndicatorView stopAnimating];
                return;
            }else{
                arrayForTV=[[NSArray alloc] initWithArray:[jsonArrayLocal valueForKey:@"results"] copyItems:YES];
            }
        }
        
    }
    
//    [self killHUD];
    [activityIndicatorView stopAnimating];
    if ([[jsonArray valueForKey:@"results"] count]==0) {
        [tableViewForSearchEntity reloadData];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Message"
                                   message: @"No data found."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
    }else if(error)
    {
        [tableViewForSearchEntity reloadData];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Error"
                                   message: @"Error from server please try again later."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        
    }else{
        arrayForEntitySearch=[[NSMutableArray alloc] initWithArray:[jsonArray valueForKey:@"results"] copyItems:YES];
        
        if ([arrayForTV count]>0) {
            for (int i=0; i<[arrayForTV count]; i++) {
                NSDictionary *dic=[arrayForTV objectAtIndex:i];
                [arrayForEntitySearch addObject:dic];
            }
            
        }
        
        [tableViewForSearchEntity reloadData];
    }
    //NSLog(@"value of Json array %@",arrayForEntitySearch);
     NSLog(@"value of arrayForEntitySearch %@",arrayForEntitySearch);
}


-(void)callSearchService:(NSString *)stringSearch{

    WeLiikeWebService *service=[[WeLiikeWebService alloc] initWithDelegate:self callback:@selector(EntitySearchHandler:)];
    [service EntitySearch:stringSearch];
        
}

-(void)EntitySearchHandler:(id)sender{
    
//    [self killHUD];
     [activityIndicatorView stopAnimating];
    if([sender isKindOfClass:[NSError class]]) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Error"
                                   message: @"Error from server please try again later."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [errorAlert show];
        
    }else{
        NSError *error=nil;
        NSString *str=[sender stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
        //NSLog(@"value of data %@",str);
        id strForResponce = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
        
        if (error==nil) {
            
            if ([strForResponce count]>0) {
                
                //NSLog(@"value of response %@",strForResponce);
                arrayForEntitySearch=[[NSMutableArray alloc] initWithArray:strForResponce copyItems:YES];
                [tableViewForSearchEntity reloadData];
                
            }else{
                tableViewForSearchEntity.hidden=YES;
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle: @"Error"
                                           message: @"Error from server please try again later."
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                [errorAlert show];
                
            }

            
        }else{
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle: @"Error"
                                       message: @"Error from server please try again later."
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            [errorAlert show];
            
        }
        
    }
}

-(void)selectCategory
{
//    btnForTakePicture.image=nil;
    txtField.text=@"";

    if ([dicForCategorySelected count]>0) {
        // NSLog(@"value of selected dictionary %@",dicForCategorySelected);
        
        if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Books"]) {
            //Book
            selectedCategory=0;
                        txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Restaurants"]) {
            //Restaurant
            selectedCategory=1;
                        txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Music"]) {
            //Music
            selectedCategory=2;
                        txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Movies & TV"]) {
            //Movie & TV
            selectedCategory=3;
                        txtField.returnKeyType = UIReturnKeySearch;
            
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Apps & Games"]) {
            //Apps & Games
            selectedCategory=4;
                        txtField.returnKeyType = UIReturnKeySearch;
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Bars & Nightlife"]) {
            //Bars & Nightlife
            selectedCategory=1;
                        txtField.returnKeyType = UIReturnKeySearch;
        }else if ([[dicForCategorySelected valueForKey:@"master_category_name"] isEqualToString:@"Places & Activities"]) {
            //Places & Activities
            selectedCategory=1;
            txtField.returnKeyType = UIReturnKeySearch;
        }
        else if (![[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Places & Activities"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Bars & Nightlife"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Apps & Games"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Movies & TV"]|| [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Music"] || [[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Restaurants"]||[[dicForCategorySelected valueForKey:@"master_category_name"]  isEqualToString:@"Books"])
        {
            txtField.returnKeyType = UIReturnKeyDone;
        }
        tableViewForSearchEntity.hidden=YES;
        [btnForSelecte setTitle:[dicForCategorySelected valueForKey:@"master_category_name"] forState:UIControlStateNormal];
    }else{
      
    }

}


-(void)callSelect{

    if ([[btnForSelecte currentTitle] isEqualToString:@"Select category"]) {
        SelectCategoryViewController *obj=[[SelectCategoryViewController alloc] init];
        [self.parentView addSubview:obj.view];
        CGRect frame = self.parentView.frame;
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector( animationDidStop:finished:context: )];
//        [UIView beginAnimations:@"slideMenu" context:(__bridge void *)(self.parentView)];
//        [UIView setAnimationDelay:0.1];
//        [UIView setAnimationDuration:0.5];
        if (frame.origin.y==0) {
            frame.origin.y = -410;
        }else{
            frame.origin.y = 40;
        }
        self.parentView.frame = frame;
        [UIView commitAnimations];

//[self presentModalViewController:obj animated:YES];
    }
    
}

-(void)getCroppedImage:(UIImage *)image{
    ApplyFilterViewController *filObj=[[ApplyFilterViewController alloc] init];
    //filObj.imageOrg=[image thumbnailImage:640 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    filObj.imageOrg=[image copy];
    [self.navigationController pushViewController:filObj animated:YES];
}


//********************** four square ******************************
//"https://api.foursquare.com/v2/venues/4b522afaf964a5200b6d27e3?client_id=CLIENT_ID&client_secret=CLIENT_SECRET


- (void)viewDidUnload
{
    [self setImgView_StarRating:nil];
    [self setV_BottomView:nil];
    //btn_Share = nil;
     [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//********************************************************************************


//********************************************************************************

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)btn_LockForpost:(id)sender {
}

@end
