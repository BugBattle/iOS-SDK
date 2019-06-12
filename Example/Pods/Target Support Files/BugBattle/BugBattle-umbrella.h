#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BugBattle.h"
#import "BugBattleBugDetailsViewController.h"
#import "BugBattleCore.h"
#import "BugBattleImageEditorViewController.h"
#import "BugBattleTouchDrawImageView.h"
#import "UIWindow+BugBattleShakeRecognizer.h"

FOUNDATION_EXPORT double BugBattleVersionNumber;
FOUNDATION_EXPORT const unsigned char BugBattleVersionString[];

