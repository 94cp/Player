//
//  UITabBarController+Autorotate.m
//  Player
//
//  Created by chenp on 2018/9/17.
//  Copyright © 2018年 chenp. All rights reserved.
//

#import "UITabBarController+Autorotate.h"

@implementation UITabBarController (Autorotate)

- (BOOL)shouldAutorotate {
    if ( self.viewControllers.count <= 5 || self.selectedIndex < 4 ) {
        UIViewController *vc = self.selectedViewController;
        if ( [vc isKindOfClass:[UINavigationController class]] )
            return [((UINavigationController *)vc).topViewController shouldAutorotate];
        
        return [vc shouldAutorotate];
    }
    
    if ( self.selectedViewController == self.moreNavigationController )
        return [self.moreNavigationController shouldAutorotate];
    
    return [self.moreNavigationController.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ( self.viewControllers.count <= 5 || self.selectedIndex < 4 ) {
        UIViewController *vc = self.selectedViewController;
        if ( [vc isKindOfClass:[UINavigationController class]] )
            return [((UINavigationController *)vc).topViewController supportedInterfaceOrientations];
        
        return [vc supportedInterfaceOrientations];
    }
    
    if ( self.selectedViewController == self.moreNavigationController )
        return [self.moreNavigationController supportedInterfaceOrientations];
    
    return [self.moreNavigationController.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ( self.viewControllers.count <= 5 || self.selectedIndex < 4 ) {
        UIViewController *vc = self.selectedViewController;
        if ( [vc isKindOfClass:[UINavigationController class]] )
            return [((UINavigationController *)vc).topViewController preferredInterfaceOrientationForPresentation];
        
        return [vc preferredInterfaceOrientationForPresentation];
    }
    
    if ( self.selectedViewController == self.moreNavigationController )
        return [self.moreNavigationController preferredInterfaceOrientationForPresentation];
    
    return [self.moreNavigationController.topViewController preferredInterfaceOrientationForPresentation];
}

@end
