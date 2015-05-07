//
//  UIImageView+ZCDownload.h
//  aifenxiang
//
//  Created by jyh2014 on 15/1/28.
//  Copyright (c) 2015年 ___zc___. All rights reserved.
//

#import <UIKit/UIKit.h>
//进度条imageView
typedef void  (^ZCDownloadCompletedBlock)(UIImage *image, NSError *error);

@interface UIImageView (ZCDownload)
/*
 *异步下载图片带进度条
 *url 图片下载地址
 *completedBlock 下载完成调用的block
 */
- (void)zcSetImageAnimationWithURL:(NSURL *)url completed:(ZCDownloadCompletedBlock)completedBlock;
@end
