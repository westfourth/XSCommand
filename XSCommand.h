//
//  XSCommand.h
//  AAA
//
//  Created by xisi on 2021/7/31.
//  Copyright © 2021 xisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//  Storyboard方式初始化
@protocol XSCommandStoryboard
@property (nonatomic) NSString *storyboardName;
@end

//  Nib方式初始化
@protocol XSCommandNib
@end

@interface XSCommand : NSObject

@property (nonatomic) NSString *className;

//  生成ViewController
- (__kindof UIViewController *)command;

@end


#pragma mark -
@interface XSCommand (Show)

//  展示ViewController
- (void)show;

@end

NS_ASSUME_NONNULL_END
