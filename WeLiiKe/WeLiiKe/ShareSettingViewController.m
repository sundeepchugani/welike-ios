//
//  ShareSettingViewController.m
//  WeLiiKe
//
//  Created by techvalens on 20/02/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ShareSettingViewController.h"
#import "UserForMessageController.h"

extern  BOOL B_PostLock;
extern int checkForFB;
@implementation ShareSettingViewController
@synthesize btnForDone,tableForSearch,txtForGroup,txtForMessage;
@synthesize btnForFb,btnForEmail,btnForTwitter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleChange:)
                                                 name:@"FBLoginSetting"
                                               object:nil];
    B_PostLock = true;
    checkForHideGroupAndMessage=0;
    arrayForServerData=[[NSMutableArray alloc] init];
    dicForSelecteGroup=[[NSMutableDictionary alloc] init];
    [self performSelector:@selector(makeScreen)];
    // Do any additional setup after loading the view from its nib.
}
- (void)handleChange:(NSNotification *)note {
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![[delegate facebook] isSessionValid]) {
        //[self showLoggedOut];
    } else {
        [self apiFQLIMe];
    }

    
}

-(void)viewDidAppear:(BOOL)animated{
   
    [super viewDidAppear:animated];
    [self performSelector:@selector(callWebServiceForGourp) withObject:nil afterDelay:0.2];
}

-(void)callWebServiceForGourp{
    
    
    WeLiikeWebService *service=[[WeLiikeWebService alloc] initWithDelegate:self callback:@selector(GetGroupHandler:)];
    //service.delegateService=self;
    //NSString *strForImageData=[self Base64Encode:imageData];
    NSString *strID=[[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    [service GetGroup:strID];
       
    
}


-(void)GetGroupHandler:(id)sender{
    
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
            
            NSLog(@"value of string %@",strForResponce);
            
            if ([strForResponce count]>0) {
                //[self performSelector:@selector(moveNextScreen)];
                arrayForServerData=[[NSMutableArray alloc] initWithArray:strForResponce copyItems:YES];
                arrayForSearchResult=[arrayForServerData mutableCopy];
                NSLog(@"array for %@",arrayForServerData);
                
                [tableForSearch reloadData];
            }else{
                //        UIAlertView *errorAlert = [[UIAlertView alloc]
                //                                   initWithTitle: @"Error"
                //                                   message: @"Error from server please try again later."
                //                                   delegate:nil
                //                                   cancelButtonTitle:@"OK"
                //                                   otherButtonTitles:nil];
                //        [errorAlert show];
                
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


-(void)makeScreen{
    
    if ([[self.view subviews] count]>6) {
        for (int i=[self.view.subviews count]; i>6; i--) {
            NSLog(@"count of i = %d",i);
            UIView *view=[self.view.subviews objectAtIndex:i-1];
            [view removeFromSuperview];
        }
    }
    
    UIView *viewForNewsFeedAndGroup=[[UIView alloc] initWithFrame:CGRectMake(0, 90, 320, 100)];
    [viewForNewsFeedAndGroup setBackgroundColor:[UIColor whiteColor]];
    
    
    UIImageView *imgViewForSaprator=[[UIImageView alloc] initWithFrame:CGRectMake(0, -2, 320, 4)];
    [imgViewForSaprator setImage:[UIImage imageNamed:@"seperator_line.png"]];
    [viewForNewsFeedAndGroup addSubview:imgViewForSaprator];
    
    UIButton *btnForNewsFeed=[[UIButton alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    [btnForNewsFeed setTitle:@"NewsFeed" forState:UIControlStateNormal];
    [btnForNewsFeed setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnForNewsFeed.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [btnForNewsFeed setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnForNewsFeed setBackgroundColor:[UIColor clearColor]];
    //btnForComment.layer.cornerRadius=5;
    //btnForComment.layer.masksToBounds=YES;
    //[btnForComment addTarget:self action:@selector(actionOnComment:) forControlEvents:UIControlEventTouchUpInside];
    [viewForNewsFeedAndGroup addSubview:btnForNewsFeed];
    
    //plus_inactive
    
    btnForFeedShare =[[UIButton alloc] initWithFrame:CGRectMake(240, 8, 40, 23)];
    btnForFeedShare.tag=1;
    [btnForFeedShare addTarget:self action:@selector(actionOnFeedShare:) forControlEvents:UIControlEventTouchUpInside];
    [btnForFeedShare setImage:[UIImage imageNamed:@"plus_active.png"] forState:UIControlStateNormal];
    [btnForNewsFeed addSubview:btnForFeedShare];
    
    UIImageView *imgViewForSaprator1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 320, 4)];
    [imgViewForSaprator1 setImage:[UIImage imageNamed:@"seperator_line.png"]];
    [viewForNewsFeedAndGroup addSubview:imgViewForSaprator1];
    
    UIButton *btnForGroup=[[UIButton alloc] initWithFrame:CGRectMake(10, 50, 300, 40)];
    [btnForGroup setTitle:@"Groups" forState:UIControlStateNormal];
    [btnForGroup setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnForGroup.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [btnForGroup setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnForGroup setBackgroundColor:[UIColor clearColor]];
    //btnForComment.layer.cornerRadius=5;
    //btnForComment.layer.masksToBounds=YES;
    [btnForGroup addTarget:self action:@selector(actionOnGroup:) forControlEvents:UIControlEventTouchUpInside];
    [viewForNewsFeedAndGroup addSubview:btnForGroup];
    UIImageView *imgViewPlus1=[[UIImageView alloc] initWithFrame:CGRectMake(240, 8, 40, 23)];
    [imgViewPlus1 setImage:[UIImage imageNamed:@"plus_inactive.png"]];
    [btnForGroup addSubview:imgViewPlus1];
    
    UIImageView *imgViewForSaprator2=[[UIImageView alloc] initWithFrame:CGRectMake(0, 98, 320, 4)];
    [imgViewForSaprator2 setImage:[UIImage imageNamed:@"seperator_line.png"]];
    [viewForNewsFeedAndGroup addSubview:imgViewForSaprator2];
    [self.view addSubview:viewForNewsFeedAndGroup];
    
    tableForSearch=[[UITableView alloc] initWithFrame:CGRectMake(0, 100, 320, 0)];
    [tableForSearch setDelegate:self];
    [tableForSearch setBackgroundColor:[UIColor clearColor]];
    [tableForSearch setDataSource:self];
    [viewForNewsFeedAndGroup addSubview:tableForSearch];
    
    
    
    UIView *viewForMessage=[[UIView alloc] initWithFrame:CGRectMake(0, 190, 320, 50)];
    [viewForMessage setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *btnForMessage=[[UIButton alloc] initWithFrame:CGRectMake(10, 0, 300, 50)];
    [btnForMessage setTitle:@"Messages" forState:UIControlStateNormal];
    [btnForMessage setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnForMessage.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [btnForMessage setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnForMessage setBackgroundColor:[UIColor clearColor]];
    //btnForComment.layer.cornerRadius=5;
    //btnForComment.layer.masksToBounds=YES;
    [btnForMessage addTarget:self action:@selector(actionOnMessage:) forControlEvents:UIControlEventTouchUpInside];
    [viewForMessage addSubview:btnForMessage];
    
    UIImageView *imgViewPlus2=[[UIImageView alloc] initWithFrame:CGRectMake(240, 8, 40, 23)];
    [imgViewPlus2 setImage:[UIImage imageNamed:@"plus_inactive.png"]];
    [btnForMessage addSubview:imgViewPlus2];

    
    UIImageView *imgViewForSaprator3=[[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 320, 4)];
    [imgViewForSaprator3 setImage:[UIImage imageNamed:@"seperator_line.png"]];
    [viewForMessage addSubview:imgViewForSaprator3];
    [self.view addSubview:viewForMessage];
    
    UIImageView *imgViewForbg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 320, 50)];
    imgViewForbg.hidden=YES;
    [imgViewForbg setImage:[UIImage imageNamed:@"center_bar.png"]];
    [viewForMessage addSubview:imgViewForbg];
    
    txtForMessage = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, 280, 30)];
    [txtForMessage setBorderStyle:UITextBorderStyleRoundedRect];
    [txtForMessage setPlaceholder:@"To: Type a name"];
    [txtForMessage setTextColor:[UIColor darkGrayColor]];
    [txtForMessage setFont:[UIFont systemFontOfSize:15]];
    txtForMessage.delegate=self;
    txtForMessage.hidden=YES;
    [viewForMessage addSubview:txtForMessage];
    
    
    UIView *viewForShare=[[UIView alloc] initWithFrame:CGRectMake(0, 250, 320, 70)];
    [viewForShare setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lblForAddress=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 30)];
    [lblForAddress setText:@"Other social networks"];
    [lblForAddress setFont:[UIFont boldSystemFontOfSize:15]];
    [lblForAddress setTextAlignment:UITextAlignmentLeft];
    [lblForAddress setBackgroundColor:[UIColor clearColor]];
    [lblForAddress setTextColor:[UIColor darkGrayColor]];
    [viewForShare addSubview:lblForAddress];
    
    [self.view addSubview:viewForShare];
    
    btnForFb=[[UIButton alloc] initWithFrame:CGRectMake(10, 30, 35, 35)];
    [btnForFb setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnForFb setBackgroundColor:[UIColor clearColor]];
        
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FBPost"]) {
        
        //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FBPost"];
        btnForFb.tag=1;
        [btnForFb setImage:[UIImage imageNamed:@"fb_selectPost.png"] forState:UIControlStateNormal];
        
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FBPost"];
        btnForFb.tag=0;
        [btnForFb setImage:[UIImage imageNamed:@"fb_post.png"] forState:UIControlStateNormal];
        
    }
        
    [btnForFb addTarget:self action:@selector(actionOnFb:) forControlEvents:UIControlEventTouchUpInside];
    [viewForShare addSubview:btnForFb];
    
        
    btnForTwitter=[[UIButton alloc] initWithFrame:CGRectMake(60, 30, 45, 35)];
    
    [btnForTwitter setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnForTwitter setBackgroundColor:[UIColor clearColor]];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"TWPost"]) {
        
        btnForTwitter.tag=1;
        [btnForTwitter setImage:[UIImage imageNamed:@"twitter_selectPost.png"] forState:UIControlStateNormal];
        
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TWPost"];
        btnForTwitter.tag=0;
        [btnForTwitter setImage:[UIImage imageNamed:@"twitter_Post.png"] forState:UIControlStateNormal];
    }
    
    [btnForTwitter addTarget:self action:@selector(actionOnTwitter:) forControlEvents:UIControlEventTouchUpInside];
    [viewForShare addSubview:btnForTwitter];
    
    btnForEmail=[[UIButton alloc] initWithFrame:CGRectMake(115, 30, 45, 35)];
    [btnForEmail setImage:[UIImage imageNamed:@"email_post.png"] forState:UIControlStateNormal];
    [btnForEmail setBackgroundColor:[UIColor clearColor]];
    btnForEmail.tag=0;
    [btnForEmail addTarget:self action:@selector(actionOnEmail:) forControlEvents:UIControlEventTouchUpInside];
    [viewForShare addSubview:btnForEmail];
    

    if (checkForHideGroupAndMessage==1) {
        
        [UIView beginAnimations:@"Resize" context:nil];
        [UIView setAnimationDuration:0.3];
        
        [tableForSearch setFrame:CGRectMake(0, 100, 320, 140)];
        [viewForNewsFeedAndGroup setFrame:CGRectMake(0, 90, 320, 240)];
        [viewForMessage setFrame:CGRectMake(0, 190+140, 320, 50)];
        [viewForShare setFrame:CGRectMake(0, 250+140, 320, 70)];
        
        [UIView commitAnimations];
        
    }
    if (checkForHideGroupAndMessage==2) {
        //[tableForSearch setFrame:CGRectMake(0, 100, 320, 140)];
        //[viewForNewsFeedAndGroup setFrame:CGRectMake(0, 90, 320, 240)];
        
        [UIView beginAnimations:@"Resize" context:nil];
        [UIView setAnimationDuration:0.3];
        [viewForMessage setFrame:CGRectMake(0, 190, 320, 100)];
        txtForMessage.hidden=NO;
        imgViewForbg.hidden=NO;
        [viewForShare setFrame:CGRectMake(0, 250+50, 320, 70)];
        [UIView commitAnimations];
    }
}

-(void)actionOnFeedShare:(UIButton*)sender{
    
    if (sender.tag==1) {
        sender.tag=0;
        [sender setImage:[UIImage imageNamed:@"plus_inactive.png"] forState:UIControlStateNormal];
    }else {
        sender.tag=1;
        [sender setImage:[UIImage imageNamed:@"plus_active.png"] forState:UIControlStateNormal];
    }
    
}


-(void)actionOnFb:(id)sender{

    UIButton *btn=(UIButton*)sender;
    
    if (btn.tag==0) {
        
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        // HackbookAppDelegate *delegate = (HackbookAppDelegate *)[[UIApplication sharedApplication] delegate];
        checkForFB=2;
        if (![[appDelegate facebook] isSessionValid]) {
             NSArray *permissions = [[NSArray alloc] initWithObjects:@"publish_stream",@"read_stream",@"offline_access",@"email", nil];
            [[appDelegate facebook] authorize:permissions];
        } else {
            //btn.tag=1;
            //[btn setImage:[UIImage imageNamed:@"fb_selectPost.png"] forState:UIControlStateNormal];
            [self apiFQLIMe];
        }

    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FBPost"];
        btn.tag=0;
        [btn setImage:[UIImage imageNamed:@"fb_post.png"] forState:UIControlStateNormal];
    }
    
}
- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([[appDelegate facebook] isSessionValid]) {
        btnForFb.tag=1;
        [btnForFb setImage:[UIImage imageNamed:@"fb_selectPost.png"] forState:UIControlStateNormal];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FBPost"];
    } 
}

-(void)actionOnTwitter:(id)sender{

    UIButton *btn=(UIButton*)sender;
    
    if (btn.tag==0) {
        
        
        AppDelegate *appDelegate =(AppDelegate *) [UIApplication sharedApplication].delegate;
        
        //Get Twitter account, stored in on the device, for the first time.
        [appDelegate getTwitterAccountOnCompletion:^(ACAccount *twitterAccount)
         {
             //If we successfully retrieved a Twitter account
             if(twitterAccount)
             {
                 //Make sure anything UI related happens on the main queue
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                    btn.tag=1;
                                    [btn setImage:[UIImage imageNamed:@"twitter_selectPost.png"] forState:UIControlStateNormal];
                                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"TWPost"];
                                    //[self performSelector:@selector(fetchData)];
                                    //return ;
                                    
                                });
             }else{
                 
             }
         }];
        
        
    }else{
        btn.tag=0;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"TWPost"];
        [btn setImage:[UIImage imageNamed:@"twitter_Post.png"] forState:UIControlStateNormal];
    }
}

-(void)actionOnEmail:(id)sender{

    UIButton *btn=(UIButton*)sender;
    
    if (btn.tag==0) {
        btn.tag=1;
        [btn setImage:[UIImage imageNamed:@"email_selectPost.png"] forState:UIControlStateNormal];
        EmailContects *obj=[[EmailContects alloc] init];
        [self.navigationController pushViewController:obj animated:YES];
        
    }else{
        btn.tag=0;
        [btn setImage:[UIImage imageNamed:@"email_post.png"] forState:UIControlStateNormal];
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}     


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return  [arrayForSearchResult count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	static NSString *CellIdentifier1 = @"Cell1";
    FollowAndFollowingCell *cell= (FollowAndFollowingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    if (cell == nil) {
        cell = [[FollowAndFollowingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    if (indexPath.row<[arrayForSearchResult count]) {
        cell.lblName.text=[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"group_name"];
        cell.imgBg.hidden=NO;
        NSString *strProfile=[NSString stringWithFormat:@"%@",[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"group_image_url"]];
        [cell.imgProfile loadImage:strProfile];
        [cell.imgProfile setBackgroundColor:[UIColor grayColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        cell.imgProfile.tag=indexPath.row;
        //[cell.imgProfile loadImage:strProfile];
        [cell.lblName setText:[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"group_name"]];//user_name
        cell.lblForCountEntity.hidden=YES;
        cell.imgForAddSing.hidden=NO;
        if ([[dicForSelecteGroup valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]] isEqualToString:@"YES"]) {
            //cell.imgBg.hidden=NO;
            [cell.imgForAddSing setImage:[UIImage imageNamed:@"plus_active.png"] forState:UIControlStateNormal];
        }else{
            [cell.imgForAddSing setImage:[UIImage imageNamed:@"plus_inactive.png"] forState:UIControlStateNormal];
        }
        return cell;
        

    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row<[arrayForSearchResult count] && indexPath.section==0) {
        if ([[dicForSelecteGroup valueForKey:[NSString stringWithFormat:@"%d",indexPath.row]] isEqualToString:@"YES"]) {
            [dicForSelecteGroup setValue:@"NO" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        }else{
            [dicForSelecteGroup setValue:@"YES" forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
        }
        
        [tableForSearch reloadData];
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   return  50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   return  0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
  
    UIView *viewForHeader=[[UIView alloc] initWithFrame:CGRectMake(0, -5, 320, 45)];
    UIImageView *imgViewForBg=[[UIImageView alloc] initWithFrame:CGRectMake(0,-5, 320, 45)];
    [imgViewForBg setImage:[UIImage imageNamed:@"center_bar.png"]];
    [viewForHeader addSubview:imgViewForBg];
    //search_bar
    UIImageView *imgViewForSaprator3=[[UIImageView alloc] initWithFrame:CGRectMake(20, 3, 280, 32)];
    [imgViewForSaprator3 setImage:[UIImage imageNamed:@"search_bar.png"]];
    [viewForHeader addSubview:imgViewForSaprator3];
    [viewForHeader setBackgroundColor:[UIColor clearColor]];
    
    txtForGroup = [[UITextField alloc] initWithFrame:CGRectMake(55, 9, 220, 25)];
    [txtForGroup setPlaceholder:@"Type a group name"];
    [txtForGroup setTextColor:[UIColor darkGrayColor]];
    [txtForGroup setFont:[UIFont systemFontOfSize:15]];
    txtForGroup.delegate=self;
    [viewForHeader addSubview:txtForGroup];
    
    return viewForHeader;

}

-(void)actionOnGroup:(id)sender{
    if (checkForHideGroupAndMessage==1) {
        checkForHideGroupAndMessage=0;
    }else{
        checkForHideGroupAndMessage=1;
    }
    
    [self performSelector:@selector(makeScreen)];
}

-(void)actionOnMessage:(id)sender{
    if (checkForHideGroupAndMessage==2) {
        checkForHideGroupAndMessage=0;
    }else{
        checkForHideGroupAndMessage=2;
    }
    
    [self performSelector:@selector(makeScreen)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[arrayForSearchResult removeAllObjects];
    //arrayForSearchResult=[arrayForServerData mutableCopy];
    [textField resignFirstResponder];
    //[tableForSearch reloadData];
    if (txtForMessage==textField) {
        
       if ([txtForMessage.text length]>1) {
           
           UserForMessageController *obj=[[UserForMessageController alloc] init];
           obj.strForSearch=textField.text;
           [self.navigationController pushViewController:obj animated:YES];
           
        }else{
//                    UIAlertView *errorAlert = [[UIAlertView alloc]
//                                               initWithTitle: @"Message"
//                                               message: @"Please enter more one character to search friends."
//                                               delegate:nil
//                                               cancelButtonTitle:@"OK"
//                                               otherButtonTitles:nil];
//                    [errorAlert show];
       }
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextView *)textView{
    
    CGPoint currentCenter = [self.view center];
    CGPoint newCenter = CGPointMake(currentCenter.x, currentCenter.y - 150);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.view setCenter:newCenter];
    [UIView commitAnimations];
    
    
}
- (void)textFieldDidEndEditing:(UITextView *)textView{
    
    CGPoint currentCenter = [self.view center];
    CGPoint newCenter = CGPointMake(currentCenter.x, currentCenter.y + 150);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.view setCenter:newCenter];
    [UIView commitAnimations];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([textField.text length]>0) {
        //resultObjectsArray = [NSMutableArray array];
        [arrayForSearchResult removeAllObjects];
        for(NSDictionary *wine in arrayForServerData)
        {
            NSString *wineName = [wine objectForKey:@"first_name"];
            NSRange range = [wineName rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound)
                [arrayForSearchResult addObject:wine];
        }
        [tableForSearch reloadData];
    }
    return YES;
}



-(IBAction)actionOnBack:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)actionOnDone:(id)sender{
    
    NSMutableArray *arrayForGroupID=[[NSMutableArray alloc] init];
    
    for (NSString *key in dicForSelecteGroup) {
        if ([[dicForSelecteGroup valueForKey:key] isEqualToString:@"YES"]) {
            //if (![appDelegate.arrayOfUserForMessage containsObject:[arrayForUserList objectAtIndex:[key intValue]]]) {
                [arrayForGroupID addObject:[[arrayForSearchResult objectAtIndex:[key intValue]] valueForKey:@"_id"]];
            //}
            
        }
        
    }
    NSString *strForGroupID=[arrayForGroupID componentsJoinedByString:@","];
    [[NSUserDefaults standardUserDefaults] setValue:strForGroupID forKey:@"GroupIdToShare"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",btnForFeedShare.tag] forKey:@"newsfeedshare"];
   [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    btn_ForLock = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)actionOnLock:(id)sender {
    if(B_PostLock == false)
    {
        NSLog(@"lock value = = = = %d", B_PostLock);
        [btn_ForLock setBackgroundImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateNormal];
        B_PostLock = true;
        NSLog(@" I am in ture block------======== condition measns b_post lock is true");
    }
    else{
       [btn_ForLock setBackgroundImage:[UIImage imageNamed:@"a-z_btnBlue.png"] forState:UIControlStateNormal];
        B_PostLock = false;
        NSLog(@" I am in false condition measns b_post lock is false");

    }
    
}
@end
