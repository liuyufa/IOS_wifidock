//
//  WFSmbTool.m
//  WiFiDock
//
//  Created by apple on 14-12-23.
//  Copyright (c) 2014年 cn.hualu.WiFiDock. All rights reserved.
//

#import "WFSmbTool.h"
#import "WFSmbUser.h"
#import "WFSmbFileState.h"
#import "WFSmbItem.h"
#import "WFSmbDirectory.h"
#import "WFSmbItem.h"
#import "WFFile.h"
#import "WFFileUtil.h"
#import "libsmbclient.h"

@interface WFSmbTool ()
{
    SMBCCTX *_smbContext;
}


@end
@implementation WFSmbTool

single_implementation(WFSmbTool)

- (id)init
{
    if (self = [super init]) {
        
        
        SMBCCTX *smbContext = smbc_new_context();
        if (smbContext) {
            
            NSLog(@"打开共享库失败！");
            
        }else{
            
            NSLog(@"打开共享库成功！");
        }
    }
    return self;
}

//smbc_init
/*
+ (SMBCCTX *) openSmbContext
{
    
    if (!smbContext)return NULL;
    
    smbc_setDebug(smbContext, 0);
    smbc_setTimeout(smbContext, 5000);
    smbc_setOptionOneSharePerServer(smbContext, false);
    smbc_setFunctionAuthData(smbContext, my_smbc_get_auth_data_fn);
    if (!smbc_init_context(smbContext)) {
        smbc_free_context(smbContext, NO);
        return NULL;
    }
    
    smbc_set_context(smbContext);
    return smbContext;
}
 */

-(void)closeSmbContext:(SMBCCTX *)smbContext
{
//   smbc_cl
}

static void my_smbc_get_auth_data_fn(const char *srv,
                                     const char *shr,
                                     char *workgroup, int wglen,
                                     char *username, int unlen,
                                     char *password, int pwlen)
{
    WFSmbUser *auth = nil;
    auth = [WFSmbUser smbUserWithGroup:@"" username:SAMBA_USERNAME password:SAMBA_PWD];
    if (auth.username.length)
        strncpy(username, auth.username.UTF8String, unlen - 1);
    else
        strncpy(username, "guest", unlen - 1);
    
    if (auth.password.length)
        strncpy(password, auth.password.UTF8String, pwlen - 1);
    else
        password[0] = 0;
    
    if (auth.workgroup.length)
        strncpy(workgroup, auth.workgroup.UTF8String, wglen - 1);
    else
        workgroup[0] = 0;
}



@end
