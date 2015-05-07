//
//  UIImageView+ZCDownload.m
//  aifenxiang
//
//  Created by jyh2014 on 15/1/28.
//  Copyright (c) 2015年 ___zc___. All rights reserved.
//

#import "UIImageView+ZCDownload.h"
#import "SDImageCache.h"
#import <objc/runtime.h>
@interface  UIImageView()<NSURLConnectionDataDelegate>
@property (nonatomic,strong)    NSMutableData                   *downloadData;
@property(nonatomic,assign)     long long                       sumLength;
@property(nonatomic,strong)     ZCDownloadCompletedBlock        block;
@property(nonatomic,copy)       NSString                        *urlString;
@end

@implementation UIImageView (ZCDownload)
static char urlStringKey;
static char blockKey;
static char sumLengthKey;
//static char currentLengthKey;
static char downloadDataKey;


- (void)zcSetImageAnimationWithURL:(NSURL *)url completed:(ZCDownloadCompletedBlock)completedBlock{
    self.block=completedBlock;
    self.urlString=url.absoluteString;
    self.image=[UIImage imageNamed:@"Load001"];
    if (self.downloadData==nil) {
        self.downloadData=[NSMutableData data];
    }
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    UIImage *image=[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.urlString];
    if (image==nil) {

        [[NSURLConnection connectionWithRequest:request delegate:self] start];

    }else
    {
        self.image=image;
        self.block(image,nil);
    }
}
#pragma mark    - get & set
-(NSString *)urlString{
    return objc_getAssociatedObject(self, &urlStringKey);
}
-(void)setUrlString:(NSString *)urlString{
    objc_setAssociatedObject(self, &urlStringKey,
                             urlString,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ZCDownloadCompletedBlock)block{
    return objc_getAssociatedObject(self, &blockKey);
}
-(void)setBlock:(ZCDownloadCompletedBlock)block{
    objc_setAssociatedObject(self, &blockKey,
                             block,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(long long)sumLength{
    return [(NSNumber *)objc_getAssociatedObject(self, &sumLengthKey) longLongValue];
    
}
-(void)setSumLength:(long long)sumLength{
    objc_setAssociatedObject(self, &sumLengthKey,
                             [NSNumber numberWithLongLong:sumLength],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableData *)downloadData{
 return objc_getAssociatedObject(self, &downloadDataKey);
}
-(void)setDownloadData:(NSMutableData *)downloadData{
    objc_setAssociatedObject(self, &downloadDataKey,
                            downloadData,
                             OBJC_ASSOCIATION_RETAIN);
}
#pragma mark    - url ConnextionDelegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if(self.sumLength==0){
        self.sumLength=response.expectedContentLength;
    }
#if DEBUG
    NSLog(@"%lld",response.expectedContentLength);
#endif
//    [self.downloadData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

#if DEBUG
    NSLog(@"%d",(int)self.downloadData.length);
    NSLog(@"%lld",self.sumLength);

#endif
    
    [self.downloadData appendData:data];
    double progress=(double)self.downloadData.length/self.sumLength;
//    NSLog(@"%@",[NSString stringWithFormat:@"Load00%d",(int)((double)(progress*19+1))]);
    self.image=[UIImage imageNamed:[NSString stringWithFormat:@"Load00%d",(int)((double)(progress*19+1))]];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
#if DEBUG
 
    NSLog(@"%lld",self.sumLength);
#endif
  
    [[SDImageCache sharedImageCache] storeImage:[[UIImage alloc]initWithData:self.downloadData] forKey:self.urlString];
    
    self.image=[[UIImage alloc]initWithData:self.downloadData];
     self.block(self.image,nil);
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:10.f];
 
//    [request setValue:[NSString stringWithFormat:@"bytes %d-%d/%d",(int)self.downloadData.length,(int)self.sumLength,(int)self.sumLength] forHTTPHeaderField:@"Content-Range"];
//    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request addValue:[NSString stringWithFormat:@"bytes=%llu-",(unsigned long long)self.downloadData.length] forHTTPHeaderField:@"Range"];

    [[NSURLConnection connectionWithRequest:request delegate:self] start];
    

    
}
@end
