//
//  XSCommand.m
//  AAA
//
//  Created by xisi on 2021/7/31.
//  Copyright © 2021 xisi. All rights reserved.
//

#import "XSCommand.h"
#import <objc/runtime.h>

@implementation XSCommand

//  先找Storyboard，再找Nib，最后找Code。
- (__kindof UIViewController *)command {
    if ([self conformsToProtocol:@protocol(XSCommandStoryboard)]) {
        return [self vcFromStoryboard];
    }
    if ([self conformsToProtocol:@protocol(XSCommandNib)]) {
        return [self vcFromNib];
    }
    return [self vcFromCode];
}

//  storyboard方式生成控制器。
- (__kindof UIViewController *)vcFromStoryboard {
    Class cls = NSClassFromString(self.className);
    NSAssert1(cls != NULL, @"没有此控制器: %@", self.className);
    NSBundle *bundle = [NSBundle bundleForClass:cls];
    NSString *sbName = [(XSCommand<XSCommandStoryboard> *)self storyboardName];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:sbName bundle:bundle];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:self.className];
    [self assignValueToVC:vc];
    return vc;
}

//  nib方式生成控制器。
- (__kindof UIViewController *)vcFromNib {
    Class cls = NSClassFromString(self.className);
    NSAssert1(cls != NULL, @"没有此控制器: %@", self.className);
    NSBundle *bundle = [NSBundle bundleForClass:cls];
    UIViewController *vc = [[cls alloc] initWithNibName:self.className bundle:bundle];
    [self assignValueToVC:vc];
    return vc;
}

//  code方式生成控制器（非nib、非storyboard方式）
- (__kindof UIViewController *)vcFromCode {
    Class cls = NSClassFromString(self.className);
    NSAssert1(cls != NULL, @"没有此控制器: %@", self.className);
    UIViewController *vc = [cls new];
    [self assignValueToVC:vc];
    return vc;
}

//  为控制器的属性赋值
- (void)assignValueToVC:(__kindof UIViewController *)vc {
    unsigned int count = 0;
    objc_property_t *props = class_copyPropertyList([self class], &count);
    Class vcClass = [vc class];
    for (unsigned int i = 0; i < count; i++) {
        objc_property_t prop = props[i];
        const char *name = property_getName(prop);
        objc_property_t vcProp = class_getProperty(vcClass, name);
        //  没有此key，跳过；
        if (vcProp == NULL) {
            continue;
        }
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [vc setValue:value forKey:key];
    }
    free(props);
}

@end


#pragma mark -
@implementation XSCommand (Show)

- (void)show {
    UIViewController *vc = [self command];
    UIViewController *currentVC = [XSCommand currentViewController];
    if ([currentVC isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)currentVC pushViewController:vc animated:YES];
    } else {
        [currentVC presentViewController:vc animated:YES completion:nil];
    }
}

+ (UIViewController *)currentViewController {
    UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
    UIViewController *curVC = window.rootViewController;
    while (YES) {
        if (curVC.presentedViewController) {
            curVC = curVC.presentedViewController;
        } else {
            if ([curVC isKindOfClass:[UINavigationController class]]) {
                curVC = ((UINavigationController *)curVC).visibleViewController;
            } else if ([curVC isKindOfClass:[UITabBarController class]]) {
                curVC = ((UITabBarController *)curVC).selectedViewController;
            } else {
                break;
            }
        }
    }
    return curVC;
}

@end
