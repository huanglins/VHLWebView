//
//  VHLWebViewNSURLProtocol.m
//  VHLWebView
//
//  Created by vincent on 2017/6/28.
//  Copyright © 2017年 Darnel Studio. All rights reserved.
//

#import "VHLWebViewNSURLProtocol.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
// Category
#import "NSData+VHLWebDataType.h"

static NSString* const kVHLWebViewNSURLProtocolKey = @"kVHLWebViewNSURLProtocolKey";
static NSUInteger const KCacheTime = 360;   //缓存的时间  默认设置为360秒 可以任意的更改

static NSObject *VHLURLSessionFilterURLPreObject;
static NSSet *VHLURLSessionFilterURLPre;

// -----------------------------------------------------------------------------
// - 缓存数据 -
@interface VHLWebViewProtocolCacheData: NSObject<NSCoding>

@property (nonatomic, strong) NSDate *addDate;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURLRequest *redirectRequest;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSString *filePath;

@end

@implementation VHLWebViewProtocolCacheData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count;
    Ivar *ivar = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar iv = ivar[i];
        const char *name = ivar_getName(iv);
        NSString *strName = [NSString stringWithUTF8String:name];
        // 利用 KVC 取值
        id value = [self valueForKey:strName];
        [aCoder encodeObject:value forKey:strName];
    }
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivar = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar var = ivar[i];
            const char *keyName = ivar_getName(var);
            NSString *key = [NSString stringWithUTF8String:keyName];
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivar);
    }
    return self;
}

@end
// -----------------------------------------------------------------------------
// - NSURLRequest -
@interface NSURLRequest(MutableCopyWorkaround)
- (id)mutableCopyWorkaround;
@end
@implementation NSURLRequest (MutableCopyWorkaround)

-(id)mutableCopyWorkaround {
    
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                          cachePolicy:[self cachePolicy]
                                                                      timeoutInterval:[self timeoutInterval]];
    [mutableURLRequest setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    if ([self HTTPBodyStream]) {
        [mutableURLRequest setHTTPBodyStream:[self HTTPBodyStream]];
    } else {
        [mutableURLRequest setHTTPBody:[self HTTPBody]];
    }
    [mutableURLRequest setHTTPMethod:[self HTTPMethod]];
    
    return mutableURLRequest;
}

@end
// -----------------------------------------------------------------------------
// - NSURLProtocol -
@interface VHLWebViewNSURLProtocol()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSMutableData *cacheData;

@end

@implementation VHLWebViewNSURLProtocol

#pragma mark - getter
- (NSURLSession *)session {
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    }
    return _session;
}
#pragma mark - NSURLProtocol - 重写 NSURLProtocol 相关方法 -----------------------
/*
    是否打算处理对应的Request 
    - 打算处理返回 YES
    - 如果不打算处理返回 No
 
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    if ([request.HTTPMethod isEqualToString:@"POST"]) {
        return NO;
    }
    if ([self p_isFilterWithUrlString:request.URL.absoluteString])
    {
        // 看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:kVHLWebViewNSURLProtocolKey inRequest:request])
        {
            return NO;
        }
        return YES;
    }
    return NO;
}
/*
    可以在这里修改Request请求
 */
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    // **** request 截取重定向，替换请求 ****
    
    return mutableRequest;
}
/*
    判断两个请求是否相同，如果相同则使用缓存
 */
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}
// -----------------------------------------------------------------------------
// 开始请求
- (void)startLoading {
    NSString *url = self.request.URL.absoluteString;
    // 加载本地缓存
    VHLWebViewProtocolCacheData *cacheData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self p_filePathWithUrlString:url]];
    if ([self p_isUseCahceWithCacheData:cacheData]) {
        // 有缓存，且缓存没有过期
        if (cacheData.redirectRequest) {
            // 重定向
            [self.client URLProtocol:self wasRedirectedToRequest:cacheData.redirectRequest redirectResponse:cacheData.response];
        } else {
            // 直接返回缓存数据
            [self.client URLProtocol:self didReceiveResponse:cacheData.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:cacheData.data];
            [self.client URLProtocolDidFinishLoading:self];
        }
    } else {
        //
        NSMutableURLRequest *mutableReqeust = [self.request mutableCopyWorkaround];
        [mutableReqeust setValue:nil forHTTPHeaderField:kVHLWebViewNSURLProtocolKey];
        
        //给我们处理过的请求设置一个标识符, 防止无限循环,
        [NSURLProtocol setProperty:@YES forKey:kVHLWebViewNSURLProtocolKey inRequest:mutableReqeust];
        
        self.downloadTask = [self.session dataTaskWithRequest:self.request];
        [self.downloadTask resume];
    }
}
// 停止请求
- (void)stopLoading {
    [self.downloadTask cancel];
    self.cacheData = nil;
    self.downloadTask = nil;
    self.response = nil;
}
#pragma mark - Delegate - NSURLSessionDelegate
// Session - 重定向
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    // 处理重定向问题
    if (response) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopyWorkaround];
        [redirectableRequest setValue:@"vincent" forHTTPHeaderField:kVHLWebViewNSURLProtocolKey];
        VHLWebViewProtocolCacheData *cacheData = [[VHLWebViewProtocolCacheData alloc] init];
        cacheData.data = self.cacheData;
        cacheData.response = response;
        cacheData.redirectRequest = redirectableRequest;
        cacheData.filePath = [self p_filePathWithUrlString:request.URL.absoluteString];
        [NSKeyedArchiver archiveRootObject:cacheData toFile:cacheData.filePath];
        
        [self.client URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        completionHandler(request);
    } else {
        completionHandler(request);
    }
}
// Session - 开始下载
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    // 允许处理服务器的响应，才会继续接收服务器
    completionHandler(NSURLSessionResponseAllow);
    self.cacheData = [NSMutableData data];
    self.response = response;
}
// Session - 下载过程
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
    [self.cacheData appendData:data];
}
// Session - 下载完成之后的处理 - 缓存文件
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
    } else {
        // 如果是图片数据，就缓存
        if ([self.cacheData vhlweb_isImageData]) {
            // 将数据的缓存轨道存入到本地文件中
            VHLWebViewProtocolCacheData *cacheData = [[VHLWebViewProtocolCacheData alloc] init];
            cacheData.data = [self.cacheData copy];
            cacheData.addDate = [NSDate date];
            cacheData.response = self.response;
            cacheData.filePath = [self p_filePathWithUrlString:self.request.URL.absoluteString];
            [NSKeyedArchiver archiveRootObject:cacheData toFile:cacheData.filePath];
        }
        [self.client URLProtocolDidFinishLoading:self];
    }
}
#pragma mark - private method
// url 存储的地址
- (NSString *)p_filePathWithUrlString:(NSString *)urlString {
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheDicPath = [cachesPath stringByAppendingPathComponent:@"cn.vincents.VHLWebView.cache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDicPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDicPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *fileName = [self cachedFileNameForKey:urlString];
    return [cacheDicPath stringByAppendingPathComponent:fileName];
}
// 缓存文件是否过期
- (BOOL)p_isUseCahceWithCacheData:(VHLWebViewProtocolCacheData *)cacheData {
    if (cacheData == nil) {
        return NO;
    }
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:cacheData.addDate];
    if (timeInterval < KCacheTime) {
        return YES;
    } else {
        // 删除已经过期的缓存文件
        [[NSFileManager defaultManager] removeItemAtPath:cacheData.filePath error:nil];
        return NO;
    }
}
+ (BOOL)p_isFilterWithUrlString:(NSString *)urlString {
    
    BOOL state = NO;
    for (NSString *str in VHLURLSessionFilterURLPre) {
        
        if ([urlString hasPrefix:str]) {
            state = YES;
            break;
        }
    }
    return state;
}
// 将需要存储的 url地址序列化为文件名
- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[key pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [key pathExtension]]];
    
    return filename;
}
#pragma mark - public method
+ (NSSet *)filterURLPres {
    NSSet *set;
    @synchronized (VHLURLSessionFilterURLPreObject) {
        set = VHLURLSessionFilterURLPre;
    }
    return set;
}
+ (void)setFilterURLPres:(NSSet *)filterURLPres {
    @synchronized (VHLURLSessionFilterURLPreObject) {
        VHLURLSessionFilterURLPre = filterURLPres;
    }
}
/** 清除Cache*/
+ (void)clearCache
{
    // 清除所有的Cache
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *cacheDicPath = [cachesPath stringByAppendingPathComponent:@"cn.vincents.VHLWebView.cache"];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:cacheDicPath error:&error];
}

@end

