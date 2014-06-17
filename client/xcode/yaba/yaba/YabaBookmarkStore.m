//
//  YabaBookmarkStore.m
//  yaba
//
//  Created by TwoPi on 14/5/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#import "YabaBookmarkStore.h"
#import "YabaBookmark.h"
#import "YabaDefines.h"
#import "YabaConnection.h"
#import "YabaUtil.h"

@import CoreData;

@interface YabaBookmarkStore ()

@property (nonatomic) NSMutableArray *internalBmList;
@property (nonatomic, strong) YabaConnection *connection;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;
@end

NSString * const kYabaBookmarkStoreInitialSyncCompleteKey = @"YabaBookmarkStoreInitialSyncCompleted";
NSString * const kYabaBookmarkStoreSyncCompletedNotificationName = @"YabaBookmarkStoreSyncCompleted";

@implementation YabaBookmarkStore

+ (instancetype)sharedStore
{
    static YabaBookmarkStore *bmStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bmStore = [[self alloc] initPrivate];
    });
    
    return bmStore;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[YabaBookmarkStore bmStore]" userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        //_internalBmList = [[NSMutableArray alloc] init];;
        _internalBmList = nil;
        _connection = [[YabaConnection alloc] init];
        
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        NSURL *storeURL = [NSURL fileURLWithPath:[self bmArchivePath]];
        
        NSError *error = nil;
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil URL:storeURL options:nil error:&error]) {
            @throw [NSException exceptionWithName:@"OpenFailure" reason:[error localizedDescription] userInfo:nil];
        }
        
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _context.persistentStoreCoordinator = psc;
        [self loadAllBms];
    }
    
    return self;
}

/*- (void) startSync
{
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self fetchBookmarks:YES];
        });
    }
}

- (void)fetchBookmarks:(BOOL)useUpdateDate {
    
}

- (BOOL)initialSyncComplete
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kYabaBookmarkStoreInitialSyncCompleteKey] boolValue];
}

- (void) setInitialSyncCompleted
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kYabaBookmarkStoreInitialSyncCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)executeSyncCompleteOperations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        [[NSNotificationCenter defaultCenter] postNotificationName:kYabaBookmarkStoreSyncCompletedNotificationName object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}

- (NSDate *)mostRecentUpdateDate
{
    __block NSDate *date = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"YabaBookmark"];
    [request setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO]]];
    [request setFetchLimit:1];
    [self.context performBlockAndWait:^{
        NSError *error=nil;
        NSArray *results = [self.context executeFetchRequest:request error:&error];
        if ([results lastObject]) {
            date = [[results lastObject] valueForKey:@"updated"];
        }
    }];
    
    return date;
}*/

- (BOOL)saveChanges
{
    NSError *error;
    BOOL successful = [self.context save:&error];
    if (!successful) {
        NSLog(@"Error saving: %@",[error localizedDescription]);
    }
    return successful;
}

- (void) loadAllBms
{
    if (!self.internalBmList) {

        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"YabaBookmark"
                                             inManagedObjectContext:self.context];
        fetchRequest.entity = e;
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:NO];
        fetchRequest.sortDescriptors = @[sd];
        NSError * error;
        NSArray *result = [self.context executeFetchRequest:fetchRequest error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }

        self.internalBmList = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (NSArray*) allBookmarks
{
    return self.internalBmList;
}

- (void)refreshBookmarks:(handlerBlock)completionHandler
{
    [_connection refreshData:[self wrappedCompletionHandler:completionHandler]];
}

- (void) loginWithFacebookAndRefreshBookmarks:(handlerBlock)completionHandler
{
    [_connection login:YabaSignInProviderFacebook withHandler:[self wrappedCompletionHandler:completionHandler]];
}

- (void) loginWithGoogleAndRefreshBookmarks:(handlerBlock)completionHandler
{
    [_connection login:YabaSignInProviderGoogle withHandler:[self wrappedCompletionHandler:completionHandler]];
}

- (void)completeSignup:(NSURL *)url withProvider:(NSString *)provider
              withData:(NSString *)data withHandler:(handlerBlock)completionHandler
{
    YabaSignInProviderType prov = YabaSignInProviderFacebook;
    
    if ([provider isEqualToString:@"Google"]) {
        prov = YabaSignInProviderGoogle;
    }
    
    [_connection completeSignup:url
                   withProvider:prov
                       withData:data
                    withHandler:[self wrappedCompletionHandler:completionHandler]];
}

- (void)logout
{
    [_connection logout];
    //_internalBmList = [[NSMutableArray alloc] init];
    self.internalBmList = nil;
}

/*- (YabaBookmark *)createBm
{
    YabaBookmark *bm = [YabaBookmark randomBm];
    
    //NSLog(@"Bm=%@",bm);
    [self.internalBmList addObject:bm];
    return bm;
}*/

- (void)removeBm:(YabaBookmark *)bm withHandler:(handlerBlock)completionHandler
{
    [_connection updateData:bm isDelete:YES
                withHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error, BOOL dataAvailable) {
                    
                    if (!error && [response statusCode] != HTTP_FORBIDDEN) {
                        [self.internalBmList removeObjectIdenticalTo:bm];
                    }
                    if (completionHandler) {
                        completionHandler(response,data,error,dataAvailable);
                    }
                }];
}

- (void)updateBm:(YabaBookmark *)bm atIndex:(NSInteger)index withHandler:(handlerBlock)completionHandler
{
    [_connection updateData:bm isDelete:NO
                withHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error, BOOL dataAvailable) {
                    
                    if (!error && [response statusCode] != HTTP_FORBIDDEN) {
                        self.internalBmList[index] = bm;
                    }
                    if (completionHandler) {
                        completionHandler(response,data,error,dataAvailable);
                    }
                }];
}

- (void)moveBmAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    
    YabaBookmark * bm = [self.internalBmList objectAtIndex:fromIndex];
    [self.internalBmList removeObjectAtIndex:fromIndex];
    [self.internalBmList insertObject:bm atIndex:toIndex];
}

- (handlerBlock)wrappedCompletionHandler:(handlerBlock)completionHandler
{
    handlerBlock block = ^void(NSHTTPURLResponse* response, NSData* data, NSError* error, BOOL dataAvailable) {
        if (dataAvailable) {
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                [self populateBookmarkList:jsonObject[@"results"]];
            } else if ([jsonObject isKindOfClass:[NSArray class]]){
                [self populateBookmarkList:jsonObject];
            } else {
                NSLog(@"Unknown type JSON data");
            }
        }
        
        if (completionHandler) {
            completionHandler(response,data,error,dataAvailable);
        }
    };
    
    return block;
}

- (void)dataAddNewBookmark:(NSDictionary *)jsonBm
{
    YabaBookmark *bm = [NSEntityDescription insertNewObjectForEntityForName:@"YabaBookmark" inManagedObjectContext:self.context];
    
    bm.oid = [NSString stringWithFormat:@"%@",jsonBm[@"id"]];
    bm.name = [YabaUtil NullToNil:jsonBm[@"name"]];
    bm.url = [YabaUtil NullToNil:jsonBm[@"url"]];
    bm.imageUrl = [YabaUtil NullToNil:jsonBm[@"image_url"]];
    bm.synopsis = [YabaUtil NullToNil:jsonBm[@"description"]];
    bm.added = [YabaUtil dateFromUTCString:jsonBm[@"added"]];
    bm.updated = [YabaUtil dateFromUTCString:jsonBm[@"updated"]];
    bm.hasNotify = [jsonBm[@"has_notify"] boolValue];
    NSString * notifyOn = [YabaUtil NullToNil:jsonBm[@"notify_on"]];
    if (!notifyOn || [notifyOn length]==0) {
        notifyOn = @"1970-01-01T00:00:00Z";
    }
    bm.notifyOn = [YabaUtil dateFromUTCString:notifyOn];
    bm.user = [YabaUtil NullToNil:jsonBm[@"user"]];
    NSString * tags = [YabaUtil NullToNil:jsonBm[@"tags"]];
    if (tags && [tags length]) {
        NSArray * tagsList = [tags componentsSeparatedByString:@","];
        for (NSString* t in tagsList) {
            NSString *trimTag = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimTag && [trimTag length]) {
                [self addOrUpdateTags:bm tag:trimTag isNewBookmark:YES];
            }
        }
    }
    bm.syncStatus = [NSNumber numberWithInt:YabaObjectSynced];
    [self.internalBmList addObject:bm];
}

- (void)dataUpdateBookmark:(NSDictionary *)jsonBm forBookmark:(YabaBookmark *)bm
{
    bm.name = [YabaUtil NullToNil:jsonBm[@"name"]];
    bm.url = [YabaUtil NullToNil:jsonBm[@"url"]];
    bm.imageUrl = [YabaUtil NullToNil:jsonBm[@"image_url"]];
    bm.synopsis = [YabaUtil NullToNil:jsonBm[@"description"]];
    bm.added = [YabaUtil dateFromUTCString:jsonBm[@"added"]];
    bm.updated = [YabaUtil dateFromUTCString:jsonBm[@"updated"]];
    bm.hasNotify = [jsonBm[@"has_notify"] boolValue];
    NSString * notifyOn = [YabaUtil NullToNil:jsonBm[@"notify_on"]];
    if (!notifyOn || [notifyOn length]==0) {
        notifyOn = @"1970-01-01T00:00:00Z";
    }
    bm.notifyOn = [YabaUtil dateFromUTCString:notifyOn];
    bm.user = [YabaUtil NullToNil:jsonBm[@"user"]];
    
    [bm removeTags:bm.tags];
    
    NSString * tags = [YabaUtil NullToNil:jsonBm[@"tags"]];
    if (tags && [tags length]) {
        NSArray * tagsList = [tags componentsSeparatedByString:@","];
        for (NSString* t in tagsList) {
            NSString *trimTag = [t stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimTag && [trimTag length]) {
                [self addOrUpdateTags:bm tag:trimTag isNewBookmark:NO];
            }
        }
    }
    
    bm.syncStatus = [NSNumber numberWithInt:YabaObjectSynced];
}

- (void)addOrUpdateTags:(YabaBookmark *)bm tag:(NSString*)tag isNewBookmark:(BOOL)isNewBookmark
{
    YabaBookmarkTag *tagObj = [self dataFindTag:tag];
    if (!tagObj) {
        tagObj = [NSEntityDescription insertNewObjectForEntityForName:@"YabaBookmarkTag" inManagedObjectContext:self.context];
    }
    
    [bm addTagsObject:tagObj];
    [tagObj addBookmarksObject:bm];
    tagObj.tagValue = tag;
}

- (YabaBookmarkTag *)dataFindTag:(NSString *)tag
{
    __block NSArray * results = nil;
    
    if (tag && [tag length]) {
        NSManagedObjectContext *context = self.context;
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"YabaBookmarkTag"];
        NSPredicate * pred = [NSPredicate predicateWithFormat:@"tagValue = %@",tag];
        [request setPredicate:pred];
        [context performBlockAndWait:^{
            NSError *error = nil;
            results = [context executeFetchRequest:request error:&error];
        }];
    }
    
    if (results && [results count]) {
        return [results lastObject];
    }
    return nil;
}

- (void) populateBookmarkList:(NSArray *)jsonData
{
    if (!self.internalBmList) {
        [self loadAllBms];
    }
    
    if (jsonData && [jsonData count]) {
        NSArray * oidList = [self.internalBmList valueForKey:@"oid"];
        NSDictionary * oids = [NSDictionary dictionaryWithObjects:self.internalBmList forKeys:oidList];
        
        for (NSDictionary *jsonBm in jsonData) {
            YabaBookmark *bm = [oids objectForKey:[NSString stringWithFormat:@"%@",jsonBm[@"id"]]];
            if (!bm) {
                [self dataAddNewBookmark:jsonBm];
            } else {
                //NSLog(@"bm.oid=%@ exists",bm.oid);
                [self dataUpdateBookmark:jsonBm forBookmark:bm];
            }
        }
    }
}

- (NSString *) bmArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString * documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}


@end
