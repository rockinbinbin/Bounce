//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>

#import "AppConstant.h"
#import "Utility.h"

#import "pushnotification.h"

void ParsePushUserAssign(void)
{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
	PFInstallation *installation = [PFInstallation currentInstallation];
	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserAssign save error.");
		}
	}];
    }
}

void ParsePushUserResign(void)
{
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
	PFInstallation *installation = [PFInstallation currentInstallation];
	[installation removeObjectForKey:PF_INSTALLATION_USER];
	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			NSLog(@"ParsePushUserResign save error.");
		}
	}];
    }
}

void SendPushNotification(NSString *groupId, NSString *text, PFObject *currentRequest) {
    
    
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {

        PFRelation *usersRelation = [currentRequest relationForKey:@"joinedUsers"];
        PFQuery *query = [usersRelation query];
        [query whereKey:OBJECT_ID notEqualTo:[[PFUser currentUser] objectId]];
        [query includeKey:@"joinedUsers"];
        [query setLimit:1000];

        PFQuery *queryInstallation = [PFInstallation query];
        [queryInstallation whereKey:PF_INSTALLATION_USER matchesQuery:query];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:queryInstallation];
//	[push setMessage:text];
        NSDictionary *data = [[NSDictionary alloc] initWithObjects:@[groupId, text] forKeys:@[OBJECT_ID, NOTIFICATION_ALERT_MESSAGE]];
        [push setData:data];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) {
                 NSLog(@"SendPushNotification send error.");
             }
         }];
    }
}

void SendHomepointPush(PFObject *homepoint, NSString *text, NSString *groupId) {
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        
        PFRelation *usersRelation = [homepoint relationForKey:PF_GROUP_Users_RELATION];
        PFQuery *query = [usersRelation query];
        [query whereKey:OBJECT_ID notEqualTo:[[PFUser currentUser] objectId]];
        [query includeKey:PF_GROUP_Users_RELATION];
        [query setLimit:1000];

    
        PFQuery *queryInstallation = [PFInstallation query];
        [queryInstallation whereKey:PF_INSTALLATION_USER matchesQuery:query];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    //	[push setMessage:text];
    NSDictionary *data = [[NSDictionary alloc] initWithObjects:@[groupId, text] forKeys:@[OBJECT_ID, NOTIFICATION_ALERT_MESSAGE]];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"SendPushNotification send error.");
         }
     }];
    }
}

void SendPendingUserPush(PFObject *homepoint) {
    if ([[Utility getInstance] checkReachabilityAndDisplayErrorMessage]) {
        
        NSString *strng = [NSString stringWithFormat:@"Neighbors, galore! %@ has requested to join the %@ homepoint. Click the top right icon in your homepoint's chat view to approve them.", [[PFUser currentUser] valueForKey:@"username"], [homepoint valueForKey:@"groupName"]];
        
        PFRelation *usersRelation = [homepoint relationForKey:PF_GROUP_Users_RELATION];
        PFQuery *query = [usersRelation query];
        [query whereKey:OBJECT_ID notEqualTo:[[PFUser currentUser] objectId]];
        [query includeKey:PF_GROUP_Users_RELATION];
        [query setLimit:1000];
        
        PFQuery *queryInstallation = [PFInstallation query];
        [queryInstallation whereKey:PF_INSTALLATION_USER matchesQuery:query];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:queryInstallation];
        //	[push setMessage:text];
        NSDictionary *data = [[NSDictionary alloc] initWithObjects:@[strng] forKeys:@[NOTIFICATION_ALERT_MESSAGE]];
        [push setData:data];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"SendPushNotification send error.");
             }
         }];
    }
}
