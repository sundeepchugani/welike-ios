//
//  AddFriendForCategory.m
//  WeLiiKe
//
//  Created by techvalens on 06/03/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AddFriendForCategory.h"
#import "AggregateViewController.h"
#import "WelcomeSearchScreen.h"

extern NSMutableArray *arrayForCateSelected;
extern int countSelectedCategory;
extern BOOL checkForLogInAndSignUp;

@implementation AddFriendForCategory
@synthesize txtFieldForSearch,tableForFriends,labelForName,btnForAtoZ,btnForList;

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
- (void) killHUD
{
	if(aHUD != nil ){
		[aHUD.loadingView removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];
        aHUD = nil;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

//Initialize and display the progress view
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrayForServerData=[[NSMutableArray alloc] init];
    arrayForSearchResult=[[NSMutableArray alloc] init];
    dicForSelectFriend=[[NSMutableDictionary alloc] init];
    
    //txtFieldForSearch.returnKeyType=UIReturnKeySearch;
    txtFieldForSearch.delegate=self;
    // Do any additional setup after loading the view from its nib.
//    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
//                                initWithKey:@"first_name"
//                                ascending:YES
//                                selector:@selector(localizedCaseInsensitiveCompare:)] ;
//    
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sorter];
//    NSArray *sortedArray = [arrayForSearchResult sortedArrayUsingDescriptors:sortDescriptors];
//    arrayForSearchResult=[[NSMutableArray alloc] initWithArray:sortedArray];
//    [tableForFriends reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showHUD];
    [self performSelector:@selector(callWebService) withObject:nil afterDelay:0.2];
}
-(void)callWebService{
    
    if (countSelectedCategory>0) {
        
        WeLiikeWebService *service=[[WeLiikeWebService alloc] initWithDelegate:self callback:@selector(GetAllFriendUserIDHandler:)];
        int countObj=[arrayForCateSelected count]-countSelectedCategory;
//        labelForName.text=[[arrayForCateSelected objectAtIndex:countObj] valueForKey:@"user_category_name"];//510646adf7e4f33e2c000005
  labelForName.text=[[arrayForCateSelected objectAtIndex:countObj] valueForKey:@"Sharing"];//
        NSString *strID=[[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
        [service GetAllFriendUserID:strID];
    }
        // NSArray *strForResponce=[service GetFriendsByCategory:@"510646adf7e4f33e2c000005"];
}


-(void)GetAllFriendUserIDHandler:(id)sender{
    [self killHUD];
    
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
            [self killHUD];
            NSString *strID=[[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
            if ([strForResponce count]>0) {
                NSLog(@"value of %d",[strForResponce count]);
                //NSDictionary *dic=(NSDictionary*)strForResponce;
                //NSArray *aarayFordata=[dic valueForKey:@"user_category"];
                arrayForServerData=[[NSMutableArray alloc] init];
                for (int i=0; i<[strForResponce count]; i++) {
                    // if (i%2 !=0) {
                    
                    if (![[[strForResponce objectAtIndex:i] valueForKey:@"user_id"] isEqualToString:strID]) {
                        [arrayForServerData addObject:[strForResponce objectAtIndex:i]];
                    }
                    
                    //}
                }
                arrayForSearchResult=[arrayForServerData mutableCopy];
                NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                            initWithKey:@"first_name"
                                            ascending:YES
                                            selector:@selector(localizedCaseInsensitiveCompare:)] ;
                
                NSArray *sortDescriptors = [NSArray arrayWithObject:sorter];
                NSArray *sortedArray = [arrayForSearchResult sortedArrayUsingDescriptors:sortDescriptors];
                arrayForSearchResult=[[NSMutableArray alloc] initWithArray:sortedArray];
                [tableForFriends reloadData];
                
            }else{
                [arrayForSearchResult removeAllObjects];
                [tableForFriends reloadData];
                UIAlertView *errorAlert = [[UIAlertView alloc]
                                           initWithTitle: @"Error"
                                           message: @"Error from server please try again later."
                                           delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
                [errorAlert show];
                
            }
        }else{
            labelForName.text=@"";
            [arrayForSearchResult removeAllObjects];
            [tableForFriends reloadData];
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle: @"Message"
                                       message: @"No data found."
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
            [errorAlert show];
            
        }
    }
}


-(void)callWebServiceForCategory{
    
    WeLiikeWebService *service=[[WeLiikeWebService alloc] initWithDelegate:self callback:@selector(GetCategoryByUserIDHandler:)];
    NSString *strID=[[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    [service GetCategoryByUserID:strID];
    
    
        
}


-(void)GetCategoryByUserIDHandler:(id)sender{
    [self killHUD];
    
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
                
                arrayForServerCategory=[[NSMutableArray alloc] init];
                for (int i=0; i<[strForResponce count]; i++) {
                    if (i%2 !=0) {
                        [arrayForServerCategory addObject:[strForResponce objectAtIndex:i]];
                    }
                }
                NSLog(@"array for %@",arrayForServerCategory);
                [tableForFriends reloadData];
                
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (btnForList.tag==1) {
        return 2;
    }else{
        return 1;
    }
	return 1;
}     


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0 && btnForList.tag==1) {
        return [arrayForSearchResult count];
    }else if (section==1 && btnForList.tag==1){
    return [arrayForSearchResult count];
    }
	return [arrayForSearchResult count];    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
	static NSString *CellIdentifier1 = @"Cell1";
    CustomCellLikeList *cell= (CustomCellLikeList*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    
    if (cell == nil) {
        cell = [[CustomCellLikeList alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (btnForList.tag==1) {
        if (indexPath.section==0) {
            CustomCellLikeList *cell1= (CustomCellLikeList*)[tableView dequeueReusableCellWithIdentifier:@"New"];
            
            if (cell1 == nil) {
                cell1 = [[CustomCellLikeList alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"New"];
            }
            cell1.lblName.text=[[arrayForServerCategory objectAtIndex:indexPath.row] valueForKey:@"category_name"];
            return cell1;

        }else if (indexPath.section==1){
        
            NSString *str=[NSString stringWithFormat:@"%@",[[arrayForSearchResult objectAtIndex:indexPath.row ] valueForKey:@"profile_picture"]];
            [cell.imgProfile setBackgroundColor:[UIColor grayColor]];
            cell.imgProfile.tag=indexPath.row;
            [cell.imgProfile loadImage:str];
            [cell.lblName setBackgroundColor:[UIColor clearColor]];
            cell.lblName.text=[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"first_name"];
            if ([[dicForSelectFriend valueForKey:[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"user_id"]] isEqualToString:@"added"]) {
                
                UIImageView *img1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
                [img1 setImage:[UIImage imageNamed:@"center_bar.png"]];
                cell.backgroundView=img1;
                
                UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 20)];
                [img setImage:[UIImage imageNamed:@"plus_active.png"]];
                
                cell.accessoryView=img;
            }

            
        }
    }else{
        NSString *str=[NSString stringWithFormat:@"%@",[[arrayForSearchResult objectAtIndex:indexPath.row ] valueForKey:@"profile_picture"]];
        [cell.imgProfile setBackgroundColor:[UIColor grayColor]];
        cell.imgProfile.tag=indexPath.row;
        [cell.imgProfile loadImage:str];
        [cell.lblName setBackgroundColor:[UIColor clearColor]];
        if ([[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"first_name"]!=[NSNull null]) {
            cell.lblName.text=[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"first_name"];
        }
        
        if ([[dicForSelectFriend valueForKey:[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"user_id"]] isEqualToString:@"added"]) {
            
            UIImageView *img1=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 55)];
            [img1 setImage:[UIImage imageNamed:@"center_bar.png"]];
            cell.backgroundView=img1;
            
            UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 20)];
            [img setImage:[UIImage imageNamed:@"plus_active.png"]];
            cell.accessoryView=img;
        }

    }
    
         
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
        
    if ((indexPath.section==1 && btnForList.tag==1) || (indexPath.section==0 && btnForList.tag==0)) {
        
    if (indexPath.row<[arrayForSearchResult count] && ![[dicForSelectFriend valueForKey:[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"user_id"]] isEqualToString:@"added"]) {
        //[self callWebserviceFor:indexPath.row];
        [dicForSelectFriend setValue:@"added" forKey:[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
        [tableForFriends reloadData];
        
    }else{
        
        [dicForSelectFriend setValue:nil forKey:[[arrayForSearchResult objectAtIndex:indexPath.row] valueForKey:@"user_id"]];
        [tableForFriends reloadData];
        
        //************************ call Add category  ***************************
    }
    }
}

-(void)callWebserviceFor:(NSString *)index{

    checkForUpdate=YES;
    NSMutableArray *arrayForCate=[[NSMutableArray alloc] init];
    for (int i=0 ;i<[arrayForCateSelected count]; i++) {
        //if ([key intValue]<[arrayForServerData count]) {
        [arrayForCate addObject:[[arrayForCateSelected objectAtIndex:i] valueForKey:@"user_category_id"]];
        //}
    }
    NSString *str=[arrayForCate componentsJoinedByString:@","];
    
    NSMutableArray *arrayForFriend=[[NSMutableArray alloc] init];
    
    for (NSString *key in dicForSelectFriend) {
        [arrayForFriend addObject:key];
    }
    
    NSString *strFriend=[arrayForFriend componentsJoinedByString:@","];
    NSLog(@"value of Friend ID ***************** %@",strFriend);
    WeLiikeWebService *service=[[WeLiikeWebService alloc] initWithDelegate:self callback:@selector(addFriendByCategoryHandler:)];
    NSString *strID=[[NSUserDefaults standardUserDefaults] valueForKey:@"UserID"];
    
    [service addFriendByCategory:strID friend_user_id:strFriend user_category_id:str];

}



-(void)addFriendByCategoryHandler:(id)sender{
    [self killHUD];
    
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
            
            [self killHUD];
            NSLog(@"value of responce %@",strForResponce);
            if ([strForResponce count]>0) {
                
                if (checkForUpdate==YES) {
                    checkForLogInAndSignUp=YES;
                    WelcomeSearchScreen *obj=[[WelcomeSearchScreen alloc] init];
                    [self.navigationController pushViewController:obj animated:YES];
                }else {
                    UIAlertView *errorAlert = [[UIAlertView alloc]
                                               initWithTitle: @"Message"
                                               message: @"Please select at least one friend."
                                               delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
                    [errorAlert show];
                    
                }
                
            }else{
                //[arrayForServerData removeAllObjects];
                [tableForFriends reloadData];
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0 && btnForList.tag==1) {
        return @"List suggested";
    }else if (section==1 && btnForList.tag==1){
        return @"A to Z";
    }
    if (section==0 && btnForList.tag==0){
        return @"A to Z";
    }
    return @"A to Z";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSLog(@"value of string %d %@",[textField.text length],string);
    
    if ([textField.text length]>0 && [textField.text length]>1) {
        //resultObjectsArray = [NSMutableArray array];
        [arrayForSearchResult removeAllObjects];
        for(NSDictionary *wine in arrayForServerData)
        {
            NSString *wineName = [wine objectForKey:@"first_name"];
            NSRange range = [wineName rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            if(range.location != NSNotFound)
                [arrayForSearchResult addObject:wine];
        }
        [tableForFriends reloadData];
    }else if ([textField.text length]==1 && [string isEqualToString:@""]){
        [arrayForSearchResult removeAllObjects];
        arrayForSearchResult=[arrayForServerData mutableCopy];
        [tableForFriends reloadData];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    //if ([textField.text length]==0) {
        [arrayForSearchResult removeAllObjects];
        arrayForSearchResult=[arrayForServerData mutableCopy];
        [tableForFriends reloadData];
    //}
    return YES;
}

-(IBAction)actionForBack:(id)sender{
    NSArray *array = [self.navigationController viewControllers];
    NSLog(@"array = %@", array);
    [self.navigationController popToViewController:[array objectAtIndex:4] animated:YES];
}

-(IBAction)actionOnList:(id)sender{
 
    if (btnForList.tag==0) {
        //btnForList.tag=1;
        //[self performSelector:@selector(callWebServiceForCategory)];
    }else{
       // btnForList.tag=0;
       // [tableForFriends reloadData];
    }
    
}

//-(IBAction)actionOnAtoZ:(id)sender{
//   
//    if (btnForAtoZ.tag==0) {
//        btnForAtoZ.tag=1;
//        [btnForAtoZ setImage:[UIImage imageNamed:@"a-z_btnBlue.png"] forState:UIControlStateNormal];
//        //NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES];
//        
//        NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
//                                     initWithKey:@"first_name"
//                                     ascending:YES
//                                     selector:@selector(localizedCaseInsensitiveCompare:)] ;
//        
//        NSArray *sortDescriptors = [NSArray arrayWithObject:sorter];
//        NSArray *sortedArray = [arrayForSearchResult sortedArrayUsingDescriptors:sortDescriptors];
//        arrayForSearchResult=[[NSMutableArray alloc] initWithArray:sortedArray];
//        [tableForFriends reloadData];
//        
//    }else{
//        btnForAtoZ.tag=0;
//         [btnForAtoZ setImage:[UIImage imageNamed:@"a-z_btn.png"] forState:UIControlStateNormal];
////        NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"first_name"
////                                                                     ascending:NO];
////        NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
////        NSArray *sortedArray = [arrayForSearchResult sortedArrayUsingDescriptors:sortDescriptors];
//        arrayForSearchResult=[[NSMutableArray alloc] initWithArray:arrayForServerData];
//        [tableForFriends reloadData];
//
//    }
//
//}



-(IBAction)actionOnNext:(id)sender{

//    if (countSelectedCategory>1) {
//        countSelectedCategory=countSelectedCategory-1;
//        //[arrayForCateSelected removeObjectAtIndex:0];
//        AddFriendForCategory *obj=[[AddFriendForCategory alloc] init];
//        [self.navigationController pushViewController:obj animated:YES];
//    }else{
//        //countSelectedCategory=[arrayForCateSelected count];
//        AggregateViewController *obj=[[AggregateViewController alloc] init];
//        [self.navigationController pushViewController:obj animated:YES];
//       
//    }
    
    [self showHUD];
    [self performSelector:@selector(callWebserviceFor:) withObject:nil afterDelay:0.2];
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
