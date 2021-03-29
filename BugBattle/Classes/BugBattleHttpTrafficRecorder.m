//
//  BugBattleNetworkLogger.m
//  BugBattle
//
//  Created by Lukas Boehler on 28.03.21.
//

#import "BugBattleHttpTrafficRecorder.h"
#import "BugBattleCore.h"

NSString * const BugBattleHTTPTrafficRecordingProgressRequestKey   = @"REQUEST_KEY";
NSString * const BugBattleHTTPTrafficRecordingProgressResponseKey  = @"RESPONSE_KEY";
NSString * const BugBattleHTTPTrafficRecordingProgressBodyDataKey  = @"BODY_DATA_KEY";
NSString * const BugBattleHTTPTrafficRecordingProgressStartDateKey  = @"REQUEST_START_DATE_KEY";
NSString * const BugBattleHTTPTrafficRecordingProgressErrorKey     = @"ERROR_KEY";

@interface BugBattleHttpTrafficRecorder()
@property(nonatomic, assign, readwrite) BOOL isRecording;
@property(nonatomic, strong) NSString *recordingPath;
@property(nonatomic, strong) NSURLSessionConfiguration *sessionConfig;
@property(nonatomic, strong) NSMutableArray *requests;
@property(nonatomic, assign) int maxRequestsInQueue;
@end

@interface BugBattleRecordingProtocol : NSURLProtocol @end

@implementation BugBattleHttpTrafficRecorder

+ (instancetype)sharedRecorder
{
    static BugBattleHttpTrafficRecorder *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = self.new;
        shared.isRecording = NO;
        shared.maxRequestsInQueue = 10;
        shared.requests = [[NSMutableArray alloc] init];
    });
    return shared;
}

- (void)setMaxRequests:(int)maxRequests {
    self.maxRequestsInQueue = maxRequests;
}

- (void)clearLogs {
    [self.requests removeAllObjects];
}

- (NSArray *)networkLogs {
    return [self.requests copy];
}

- (BOOL)startRecording{
    return [self startRecordingForSessionConfiguration: nil];
}

- (BOOL)startRecordingForSessionConfiguration:(NSURLSessionConfiguration *)sessionConfig {
    if (sessionConfig) {
        self.sessionConfig = sessionConfig;
        NSMutableOrderedSet *mutableProtocols = [[NSMutableOrderedSet alloc] initWithArray:sessionConfig.protocolClasses];
        [mutableProtocols insertObject:[BugBattleRecordingProtocol class] atIndex:0];
        sessionConfig.protocolClasses = [mutableProtocols array];
    } else {
        [NSURLProtocol registerClass: [BugBattleRecordingProtocol class]];
    }
    
    self.isRecording = YES;
    
    return YES;
}

- (void)stopRecording{
    if (self.isRecording){
        if (self.sessionConfig) {
            NSMutableArray *mutableProtocols = [[NSMutableArray alloc] initWithArray:self.sessionConfig.protocolClasses];
            [mutableProtocols removeObject:[BugBattleRecordingProtocol class]];
            self.sessionConfig.protocolClasses = mutableProtocols;
            self.sessionConfig = nil;
        } else {
            [NSURLProtocol unregisterClass:[BugBattleRecordingProtocol class]];
        }
    }
    
    self.isRecording = NO;
}

+ (NSString *)stringFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: dictionary
                        options:NSJSONWritingPrettyPrinted
                        error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    } else {
        return @"";
    }
}

+ (NSString *)stringFrom:(NSData *)data {
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

+ (BOOL)isTextBasedContentType:(NSString *)contentType {
    if ([contentType containsString: @"text/"]) {
        return true;
    }
    if ([contentType containsString: @"application/javascript"]) {
        return true;
    }
    if ([contentType containsString: @"application/xhtml+xml"]) {
        return true;
    }
    if ([contentType containsString: @"application/json"]) {
        return true;
    }
    if ([contentType containsString: @"application/xml"]) {
        return true;
    }
    if ([contentType containsString: @"application/x-www-form-urlencoded"]) {
        return true;
    }
    if ([contentType containsString: @"multipart/"]) {
        return true;
    }
    return false;
}

@end

#pragma mark - Private Protocol Class

static NSString * const BugBattleRecordingProtocolHandledKey = @"BugBattleRecordingProtocolHandledKey";

@interface BugBattleRecordingProtocol () <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *mutableData;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSDate *startDate;

@end


@implementation BugBattleRecordingProtocol

#pragma mark - NSURLProtocol overrides

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"http"];
    if ([NSURLProtocol propertyForKey:BugBattleRecordingProtocolHandledKey inRequest:request] || !isHTTP) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void) startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty: @YES forKey: BugBattleRecordingProtocolHandledKey inRequest: newRequest];
    
    self.startDate = [NSDate date];
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void) stopLoading {
    
    [self.connection cancel];
    self.mutableData = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol: self didReceiveResponse:response cacheStoragePolicy: NSURLCacheStorageNotAllowed];
    
    self.response = response;
    self.mutableData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    
    [self.mutableData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    [self.class updateRecorderProgressDelegate: true
                                      userInfo:@{BugBattleHTTPTrafficRecordingProgressRequestKey: self.request,
                                                 BugBattleHTTPTrafficRecordingProgressResponseKey: self.response,
                                                 BugBattleHTTPTrafficRecordingProgressBodyDataKey: self.mutableData,
                                                 BugBattleHTTPTrafficRecordingProgressStartDateKey: self.startDate
                                                 }];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    
    [self.class updateRecorderProgressDelegate: false
                                      userInfo:@{BugBattleHTTPTrafficRecordingProgressRequestKey: self.request,
                                                 BugBattleHTTPTrafficRecordingProgressErrorKey: error,
                                                 BugBattleHTTPTrafficRecordingProgressStartDateKey: self.startDate
                                                 }];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self.client URLProtocol:self didCancelAuthenticationChallenge:challenge];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response != nil) {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

#pragma mark - Recording Progress

+ (void)updateRecorderProgressDelegate:(bool)success userInfo:(NSDictionary *)info {
    NSMutableURLRequest *urlRequest = [info objectForKey: BugBattleHTTPTrafficRecordingProgressRequestKey];
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    
    [request setValue: [urlRequest HTTPMethod] forKey: @"type"];
    [request setValue: [[urlRequest URL] absoluteString] forKey: @"url"];
    [request setValue: [BugBattle.sharedInstance getJSStringForNSDate: [[NSDate alloc] init]] forKey: @"date"];
    
    NSDate *startLoadingDate = [info objectForKey: BugBattleHTTPTrafficRecordingProgressStartDateKey];
    if (startLoadingDate != NULL) {
        int duration = (int)([startLoadingDate timeIntervalSinceNow] * 1000 * -1);
        [request setValue: [NSNumber numberWithDouble: duration] forKey: @"duration"];
    }
    
    if (success) {
        NSHTTPURLResponse *response = [info objectForKey: BugBattleHTTPTrafficRecordingProgressResponseKey];
        NSData *data = [info objectForKey: BugBattleHTTPTrafficRecordingProgressBodyDataKey];
        NSString *contentType = [[response allHeaderFields] objectForKey: @"Content-Type"];
        
        [request setValue: @YES forKey: @"success"];
        
        NSMutableDictionary *requestObj = [[NSMutableDictionary alloc] init];
        [requestObj setValue: [BugBattleHttpTrafficRecorder stringFrom: [urlRequest HTTPBody]] forKey: @"payload"];
        [requestObj setValue: [BugBattleHttpTrafficRecorder stringFromDictionary: [urlRequest allHTTPHeaderFields]] forKey: @"headers"];
        [request setValue: requestObj forKey: @"request"];
        
        NSMutableDictionary *responseObj = [[NSMutableDictionary alloc] init];
        [responseObj setValue: [NSNumber numberWithInteger: [response statusCode]] forKey: @"status"];
        [responseObj setValue: [BugBattleHttpTrafficRecorder stringFromDictionary: [response allHeaderFields]] forKey: @"headers"];
        [responseObj setValue: contentType forKey: @"contentType"];
        
        // Add the response body only if smaller than 1MB and Content-Type is valid.
        int maxBodySize = 1000 * 1000;
        if ([BugBattleHttpTrafficRecorder isTextBasedContentType: contentType] && data.length < maxBodySize) {
            [responseObj setValue: [BugBattleHttpTrafficRecorder stringFrom: data] forKey: @"responseText"];
        } else {
            [responseObj setValue: @"Content too large." forKey: @"responseText"];
        }
        
        [request setValue: responseObj forKey: @"response"];
    } else {
        [request setValue: @NO forKey: @"success"];
        
        NSError *error = [info objectForKey: BugBattleHTTPTrafficRecordingProgressErrorKey];
        
        NSMutableDictionary *responseObj = [[NSMutableDictionary alloc] init];
        [responseObj setValue: [error localizedDescription] forKey: @"errorText"];
        [request setValue: responseObj forKey: @"response"];
    }
    
    BugBattleHttpTrafficRecorder *recorder = [BugBattleHttpTrafficRecorder sharedRecorder];
    if (recorder.requests.count >= recorder.maxRequestsInQueue) {
        [[recorder requests] removeObjectAtIndex: 0];
    }
    [[recorder requests] addObject: [request copy]];
}

@end
