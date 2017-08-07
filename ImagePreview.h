//
//  ImagePreview.h
//  DKChat
//
//  Created by liudukun on 16/7/6.
//  Copyright © 2016年 com.ldk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePreview : UIView

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSString *imageURL;

+ (instancetype)showInView:(UIView*)view;

@end
