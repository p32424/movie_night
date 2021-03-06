//
//  FollowersTableViewController.m
//  movie_night
//
//  Created by Ariana Antonio on 3/6/15.
//  Copyright (c) 2015 Ariana Antonio. All rights reserved.
//

#import "FollowersTableViewController.h"
#import "MovieClass.h"
#import <Parse/Parse.h>
#import "FriendProfileViewController.h"

@interface FollowersTableViewController ()

@end

@implementation FollowersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    userID = currentUser.objectId;
    
    followersArray = [[NSMutableArray alloc]init];
    
    if ([self.selectionType isEqualToString:@"following"]) {
        [self getFollowing];
        self.navBar.title = @"Following";
    } else {
        [self getFollowers];
        self.navBar.title = @"Followers";
    }
}
//get users current user is following
-(void)getFollowing {
    
    [followersArray removeAllObjects];

    //get user information
    PFQuery *query = [PFUser query];
    if ([self.passedUserId isEqualToString:@""] || self.passedUserId == nil) {
        [query whereKey:@"objectId" equalTo:userID];
    } else {
        [query whereKey:@"objectId" equalTo:self.passedUserId];
    }
    NSArray *userArray = [query findObjects];
    NSDictionary *userData = [userArray firstObject];
    
    //get user ids stored in friends array in table
    NSArray *followingArray = [userData objectForKey:@"friends"];
    
    //iterate through returned array of friends
    if ([followingArray count] > 0) {
        for (int i = 0; i < [followingArray count]; i++) {
            MovieClass *userFollowing = [[MovieClass alloc]init];

            //get info for each following user
            PFQuery *query = [PFUser query];
            [query whereKey:@"objectId" equalTo:[followingArray objectAtIndex:i]];
            NSArray *userArray2 = [query findObjects];
            NSDictionary *userInfo = [userArray2 firstObject];
            userFollowing.username = [userInfo objectForKey:@"username"];
            userFollowing.user_photo_file = [UIImage imageWithData:[(PFFile *)userInfo[@"profile_pic"]getData]];;
            userFollowing.userID = [followingArray objectAtIndex:i];
            [followersArray addObject:userFollowing];
        }
    }
    [_followersTable reloadData];
}
//get users who are following the current user
-(void)getFollowers {
    [followersArray removeAllObjects];
    
    //query where current users id is contained in another users friends array
    PFQuery *query = [PFUser query];
    if ([self.passedUserId isEqualToString:@""] || self.passedUserId == nil) {
        [query whereKey:@"friends" equalTo:userID];
    } else {
        [query whereKey:@"friends" equalTo:self.passedUserId];
    }
    NSArray *followersFoundArray = [query findObjects];
    
    //iterate through returned followers array
    if ([followersFoundArray count] > 0) {
        for (int i = 0; i < [followersFoundArray count]; i++) {
            MovieClass *userFollowing = [[MovieClass alloc]init];
            
            //get user info for each follower
            PFQuery *query = [PFUser query];
            [query whereKey:@"objectId" equalTo:[[followersFoundArray objectAtIndex:i]objectId]];
            NSArray *userArray2 = [query findObjects];
            NSDictionary *userInfo = [userArray2 firstObject];
            userFollowing.username = [userInfo objectForKey:@"username"];
            userFollowing.user_photo_file = [UIImage imageWithData:[(PFFile *)userInfo[@"profile_pic"]getData]];;
            userFollowing.userID = [[followersFoundArray objectAtIndex:i]objectId];
            [followersArray addObject:userFollowing];
            
        }
    }
    [_followersTable reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [followersArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
    
    MovieClass *user = [followersArray objectAtIndex:indexPath.row];
    
    if (cell !=nil) {
        UIImageView *profilePic = (UIImageView *) [cell viewWithTag:1];
        profilePic.image = user.user_photo_file;
        UILabel *nameLabel = (UILabel *) [cell viewWithTag:2];
        nameLabel.text = user.username;
        
    return cell;
    }
    return nil;
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    FriendProfileViewController *fpvc = [segue destinationViewController];
    if (fpvc != nil) {
        UITableViewCell *cell = (UITableViewCell*)sender;
        NSIndexPath *indexPath = [_followersTable indexPathForCell:cell];
        
        MovieClass *userSelected = [followersArray objectAtIndex:indexPath.row];
        fpvc.userIdPassed = [userSelected userID];
    }
}


@end
