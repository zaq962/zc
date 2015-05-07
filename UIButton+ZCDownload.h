//
//  UIButton+ZCDownload.h
//  aifenxiang
//
//  Created by jyh2014 on 15/2/10.
//  Copyright (c) 2015年 ___zc___. All rights reserved.
//

#import <UIKit/UIKit.h>

//进度条btn
typedef void  (^ZCBtnDownloadCompletedBlock)(UIImage *image,UIButton *btn ,NSError *error);

@interface UIButton (ZCDownload)
- (void)zcSetImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(ZCBtnDownloadCompletedBlock)completedBlock;
@end
