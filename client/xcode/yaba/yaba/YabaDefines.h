//
//  YabaDefines.h
//  yaba
//
//  Created by TwoPi on 9/6/14.
//  Copyright (c) 2014 TwoPi. All rights reserved.
//

#ifndef yaba_YabaDefines_h
#define yaba_YabaDefines_h

#define HTTP_OK                 200
#define HTTP_FORBIDDEN          403

#define FB_ACCESS_NOT_GRANTED   16000

#define StringFromBoolean(value) (value ? @"YES" : @"NO")

typedef enum
{
    YabaSignInProviderNone = 0,
    YabaSignInProviderFacebook,
    YabaSignInProviderGoogle
} YabaSignInProviderType;

typedef enum
{
    YabaObjectSynced = 0,
    YabaObjectCreated,
    YabaObjectUpdated,
    YabaObjectDeleted
} YabaObjectSyncStatus;

typedef void(^handlerBlock)(NSHTTPURLResponse* response,NSData* data,NSError *error,BOOL dataAvailable);

#endif
