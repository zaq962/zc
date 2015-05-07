//
//  UIButton+ZCDownload.m
//  aifenxiang
//
//  Created by jyh2014 on 15/2/10.
//  Copyright (c) 2015年 ___zc___. All rights reserved.
//

#import "UIButton+ZCDownload.h"
#import "SDImageCache.h"
#import <objc/runtime.h>
@interface UIButton()<NSURLConnectionDataDelegate>
@property (nonatomic,strong)    NSMutableData                   *downloadData;
@property(nonatomic,assign)     long long                       sumLength;
@property(nonatomic,strong)     ZCBtnDownloadCompletedBlock        block;
@property(nonatomic,copy)       NSString                        *urlString;
@property(nonatomic,assign)     UIControlState                  zcstate;
@end

@implementation UIButton (ZCDownload)
static char urlStringKey;
static char blockKey;
static char sumLengthKey;
//static char currentLengthKey;
static char downloadDataKey;
static char zcstateKey;
-(void)zcSetImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(ZCBtnDownloadCompletedBlock)completedBlock{
    self.block=completedBlock;
    self.urlString=url.absoluteString;
    self.zcstate=state;
    [self setImage:[UIImage imageNamed:@"Load001"] forState:state];
    if (self.downloadData==nil) {
        self.downloadData=[NSMutableData  data];
    }else{
        [self.downloadData setLength:0];
    }
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    
    UIImage *image=[[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.urlString];
    if (image==nil) {

        [[NSURLConnection connectionWithRequest:request delegate:self] start];
        
    }else
    {
        [self setImage:image forState:state];
        self.block(image,self,nil);
    }
}
-(NSString *)urlString{
    return objc_getAssociatedObject(self, &urlStringKey);
}
-(void)setUrlString:(NSString *)urlString{
    objc_setAssociatedObject(self, &urlStringKey,
                             urlString,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(ZCBtnDownloadCompletedBlock)block{
    return objc_getAssociatedObject(self, &blockKey);
}
-(void)setBlock:(ZCBtnDownloadCompletedBlock)block{
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
-(UIControlState)zcstate{
    return (UIControlState)[(NSNumber *)objc_getAssociatedObject(self, &zcstateKey) integerValue];
}
-(void)setZcstate:(UIControlState)zcstate{
    objc_setAssociatedObject(self, &zcstateKey,
                             [NSNumber numberWithInteger:zcstate],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark    - url connectionDelegate
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
    [self setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Load00%d",(int)((double)(progress*19+1))]] forState:self.zcstate];
    
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
#if DEBUG
    
    NSLog(@"%lld",self.sumLength);
#endif
//    NSString *str=connection.currentRequest.URL.absoluteString;
//    
//    NSData   *data=self.downloadData;

    [[SDImageCache sharedImageCache] storeImage:[[UIImage alloc]initWithData:self.downloadData] forKey:self.urlString];
    
    [self setImage:[[UIImage alloc]initWithData:self.downloadData] forState:self.zcstate];
    self.block(self.imageView.image,self,nil);
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:10.f];
    
    //    [request setValue:[NSString stringWithFormat:@"bytes %d-%d/%d",(int)self.downloadData.length,(int)self.sumLength,(int)self.sumLength] forHTTPHeaderField:@"Content-Range"];
    //    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request addValue:[NSString stringWithFormat:@"bytes=%llu-",(unsigned long long)self.downloadData.length] forHTTPHeaderField:@"Range"];
    
    [[NSURLConnection connectionWithRequest:request delegate:self] start];
    
    
    
}
@end
