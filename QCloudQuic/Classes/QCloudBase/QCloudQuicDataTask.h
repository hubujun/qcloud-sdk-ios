//
//  QCloudQuicDataTask.h
//  QCloudCore
//
//  Created by karisli(李雪) on 2019/3/22.
//

#import <Foundation/Foundation.h>
@class QCloudQuicSession;

NS_ASSUME_NONNULL_BEGIN

@interface QCloudQuicDataTask<BodyType> : NSURLSessionDataTask
@property (nonatomic,weak)id<NSURLSessionDataDelegate>delegate;
@property (nullable,readwrite,copy)NSHTTPURLResponse *response;
@property (nullable, readwrite, copy) NSURLRequest  *originalRequest;

@property (nonatomic,strong)id manager;
-(instancetype)initWithHTTPRequest:(NSMutableURLRequest *)httpRequest quicHost:(NSString *)quicHost quicIp:(NSString *)quicIp body:(BodyType)body quicSession:(QCloudQuicSession *)quicSession;
-(void)start;
@end

NS_ASSUME_NONNULL_END

