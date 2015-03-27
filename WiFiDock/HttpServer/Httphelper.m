//
//  Httphelper.m
//  WiFiDock
//
//  Created by hualu on 15-1-28.
//  Copyright (c) 2015年 cn.hualu.WiFiDock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Httphelper.h"

@implementation Httphelper

//这个函数是判断网络是否可用的函数（wifi或者蜂窝数据可用，都返回YES）
+ (BOOL)NetWorkIsOK{
    if(
       ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus]
        != NotReachable)
       &&
       ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]
        != NotReachable)
       ){
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)setURLRequest:(NSString *)info{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:info]];
    [request setHTTPMethod:@"GET"];
    NSString *contentType = [NSString stringWithFormat:@"text/xml"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    //同步返回请求，并获得返回数据
    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    //请求返回状态，如有中文无法发送请求，并且stausCode 值为 0
    NSLog(@"response code:%d",[urlResponse statusCode]);
    if([urlResponse statusCode] >= 200 && [urlResponse statusCode] <300){
        return YES;
    }
    else
    {
        return NO;
    }
    
}
//post异步请求封装函数
+ (void)post:(NSString *)URL FinishBlock:(void (^)(NSURLResponse *response, NSData *data, NSError *connectionError)) block{
    //把传进来的URL字符串转变为URL地址
    NSURL *url = [NSURL URLWithString:URL];
    //请求初始化，可以在这针对缓存，超时做出一些设置
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:20];
    //解析请求参数，用NSDictionary来存参数，通过自定义的函数parseParams把它解析成一个post格式的字符串
    // NSString *parseParamsResult = [self parseParams:params];
    // NSData *postData = [parseParamsResult dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    //[request setHTTPBody:postData];
    
    //创建一个新的队列（开启新线程）
    NSOperationQueue *queue = [NSOperationQueue new];
    //发送异步请求，请求完以后返回的数据，通过completionHandler参数来调用
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:block];
}

//把NSDictionary解析成post格式的NSString字符串
+ (NSString *)parseParams:(NSDictionary *)params{
    NSString *keyValueFormat;
    NSMutableString *result = [NSMutableString new];
    //实例化一个key枚举器用来存放dictionary的key
    NSEnumerator *keyEnum = [params keyEnumerator];
    id key;
    while (key = [keyEnum nextObject]) {
        keyValueFormat = [NSString stringWithFormat:@"%@=%@&",key,[params valueForKey:key]];
        [result appendString:keyValueFormat];
        NSLog(@"post()方法参数解析结果：%@",result);
    }
    return result;
}

//同步封装
+(NSData*)httpPostSyn:(NSString *)str
{
    NSLog(@"httpPostSyn...");
    
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:str];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    [request setHTTPBody:nil];//设置参数
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = [[NSError alloc] init];
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if([urlResponse statusCode] >= 200 && [urlResponse statusCode] <300){
        return received;
    }
    else{
        return nil;
    }
}
+(BOOL)ifIPInfoValidity:(NSString *)ipinfo :(int)index{
    NSString *info = ipinfo;
    int countalldot=0;
    int len = [info length];
    char dot = '.';
    //NSString *temp[]={@"",@"",@"",@""};
    /*备域名服务器是否为空*/
    if(0==len&&index==4){
        return YES;
    }
    /*字符串是否符合长度7-15*/
    if(6<len&&len<16){
        /*计算.符号个数*/
        for(int i=0;i<len;i++){
            if(dot ==[info characterAtIndex:i] ){
                /*是否首尾为空*/
                if(i==0||i==len-1){
                    return NO;
                }
                countalldot++;
                /*是否连续两个.符号*/
                if(len-1!=i){
                    if([info characterAtIndex:i]==[info characterAtIndex:i+1]){
                        return NO;
                    }
                }
            }
        }
        if(3==countalldot){
            /*以.符号为标志拆分字符串*/
            NSArray *array=[info componentsSeparatedByString:@"."];
            for(int i=0;i<[array count];i++){
                int size = [[array objectAtIndex:i] length];
                /*是否全为数字*/
                for(int j=0;j<size;j++){
                    if('0'>[[array objectAtIndex:i] characterAtIndex:j]||'9'<[[array objectAtIndex:i] characterAtIndex:j]){
                        return NO;
                    }
                }
                if(size >1){
                    /*首字符不为0*/
                    if('0'==[[array objectAtIndex:i] characterAtIndex:0]){
                        return NO;
                    }
                }
                /*是否为0-255*/
                int intString = [[array objectAtIndex:i] intValue];
                if(0 > intString||255<intString){
                    return NO;
                }
                /*子网掩码首字符必须为255*/
                if(1==index&&255!=[[array objectAtIndex:0] intValue]){
                    return NO;
                }
            }
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
    return YES;
}
@end