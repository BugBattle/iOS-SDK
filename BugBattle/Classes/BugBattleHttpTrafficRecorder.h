//
//  BugBattleNetworkLogger.h
//  BugBattle
//
//  Created by Lukas Boehler on 28.03.21.
//

#import <Foundation/Foundation.h>

/**
 * An BugBattleHttpTrafficRecorder lets you intercepts the http requests made by an application and records their responses in a specified format.
 */
@interface BugBattleHttpTrafficRecorder : NSObject

/**
 * Returns the shared recorder object.
 */
+ (instancetype)sharedRecorder;

/**
 *  Method to start recording using default path.
 */
- (BOOL)startRecording;

/**
 *  Method to start recording and saves recorded files at a specified location using given session configuration.
 *  @param sessionConfig The NSURLSessionConfiguration which will be modified.
 */
- (BOOL)startRecordingForSessionConfiguration:(NSURLSessionConfiguration *)sessionConfig;

/**
 *  Method to stop recording.
 */
- (void)stopRecording;

/**
 *  Returns all network logs.
 */
- (NSArray *)networkLogs;

/**
 *  Clears all network logs.
 */
- (void)clearLogs;

/**
 * Sets the maximum requests amount.
 */
- (void)setMaxRequests:(int)maxRequests;

/**
 *  A Boolean value which indicates whether the recording is recording traffic.
 */
@property(nonatomic, readonly, assign) BOOL isRecording;

@end
