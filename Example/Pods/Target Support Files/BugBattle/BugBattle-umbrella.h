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
#import "BugBattleCore.h"
#import "BugBattleHttpTrafficRecorder.h"
#import "BugBattleImageEditorViewController.h"
#import "BugBattleReplayHelper.h"
#import "BugBattleTouchDrawImageView.h"
#import "BugBattleTouchHelper.h"
#import "BugBattleTranslationHelper.h"
#import "UIWindow+BugBattleShakeRecognizer.h"
#import "UIWindow+BugBattleTouchRecognizer.h"

FOUNDATION_EXPORT double BugBattleVersionNumber;
FOUNDATION_EXPORT const unsigned char BugBattleVersionString[];

