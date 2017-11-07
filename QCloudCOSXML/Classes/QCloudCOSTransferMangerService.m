//
//  COSTransferManger.m
//  COSTransferManger
//
//  Created by tencent
//  Copyright (c) 2015年 tencent. All rights reserved.
//
//   ██████╗  ██████╗██╗      ██████╗ ██╗   ██╗██████╗     ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗         ██╗      █████╗ ██████╗
//  ██╔═══██╗██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║         ██║     ██╔══██╗██╔══██╗
//  ██║   ██║██║     ██║     ██║   ██║██║   ██║██║  ██║       ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║         ██║     ███████║██████╔╝
//  ██║▄▄ ██║██║     ██║     ██║   ██║██║   ██║██║  ██║       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║         ██║     ██╔══██║██╔══██╗
//  ╚██████╔╝╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗    ███████╗██║  ██║██████╔╝
//   ╚══▀▀═╝  ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚═════╝
//
//
//                                                                              _             __                 _                _
//                                                                             (_)           / _|               | |              | |
//                                                          ___  ___ _ ____   ___  ___ ___  | |_ ___  _ __    __| | _____   _____| | ___  _ __   ___ _ __ ___
//                                                         / __|/ _ \ '__\ \ / / |/ __/ _ \ |  _/ _ \| '__|  / _` |/ _ \ \ / / _ \ |/ _ \| '_ \ / _ \ '__/ __|
//                                                         \__ \  __/ |   \ V /| | (_|  __/ | || (_) | |    | (_| |  __/\ V /  __/ | (_) | |_) |  __/ |  \__
//                                                         |___/\___|_|    \_/ |_|\___\___| |_| \___/|_|     \__,_|\___| \_/ \___|_|\___/| .__/ \___|_|  |___/
//    ______ ______ ______ ______ ______ ______ ______ ______                                                                            | |
//   |______|______|______|______|______|______|______|______|                                                                           |_|
//


#import "QCloudCOSTransferMangerService.h"
#import "QCloudThreadSafeMutableDictionary.h"
#import "QCLoudError.h"

#import "QCloudGetObjectACLRequest.h"
#import "QCloudPutObjectRequest.h"
#import "QCloudPutObjectACLRequest.h"
#import "QCloudDeleteObjectRequest.h"
#import "QCloudDeleteMultipleObjectRequest.h"
#import "QCloudInitiateMultipartUploadRequest.h"
#import "QCloudUploadPartRequest.h"
#import "QCloudCompleteMultipartUploadRequest.h"
#import "QCloudCOSXMLService.h"
#import "QCloudCOSXMLUploadObjectRequest.h"
#import "QCloudCOSXMLUploadObjectRequest_Private.h"

QCloudThreadSafeMutableDictionary* QCloudCOSTransferMangerServiceCache()
{
    static QCloudThreadSafeMutableDictionary* CloudcostransfermangerService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CloudcostransfermangerService = [QCloudThreadSafeMutableDictionary new];
    });
    return CloudcostransfermangerService;
}

@interface QCloudCOSTransferMangerService ()
@property (nonatomic, strong, readonly) QCloudOperationQueue* uploadFileQueue;
@end

@implementation QCloudCOSTransferMangerService
static QCloudCOSTransferMangerService* COSTransferMangerService = nil;


+ (QCloudCOSTransferMangerService*) defaultCOSTransferManager
{
    @synchronized (self) {
        if (!COSTransferMangerService) {
            @throw [NSException exceptionWithName:QCloudErrorDomain reason:@"您没有配置默认的OCR服务配置，请配置之后再调用该方法" userInfo:nil];
        }
        return COSTransferMangerService;
    }
}

+ (QCloudCOSTransferMangerService*) registerdefaultCOSTransferManagerWithConfiguration:(QCloudServiceConfiguration*)configuration
{
    @synchronized (self) {
        COSTransferMangerService = [[QCloudCOSTransferMangerService alloc] initWithConfiguration:configuration];
    }
    return COSTransferMangerService;
}

+ (QCloudCOSTransferMangerService*) costransfermangerServiceForKey:(NSString*)key
{
    QCloudCOSTransferMangerService* costransfermangerService = [QCloudCOSTransferMangerServiceCache() objectForKey:key];
    if (!costransfermangerService) {
        @throw [NSException exceptionWithName:QCloudErrorDomain reason:[NSString stringWithFormat:@"您没有配置Key为%@的OCR服务配置，请配置之后再调用该方法", key] userInfo:nil];
    }
    return costransfermangerService;
}

+ (QCloudCOSTransferMangerService*) registerCOSTransferMangerWithConfiguration:(QCloudServiceConfiguration*)configuration withKey:(NSString*)key;
{
    QCloudCOSTransferMangerService* costransfermangerService =[[QCloudCOSTransferMangerService alloc] initWithConfiguration:configuration];
    [QCloudCOSTransferMangerServiceCache() setObject:costransfermangerService  forKey:key];
    return costransfermangerService;
}

- (instancetype) initWithConfiguration:(QCloudServiceConfiguration *)configuration
{
    self = [super initWithConfiguration:configuration];
    if (!self) {
        return self;
    }
    _cosService = [[QCloudCOSXMLService alloc] initWithConfiguration:configuration];
    _uploadFileQueue = [QCloudOperationQueue new];
    return self;
}

- (void) UploadObject:(QCloudCOSXMLUploadObjectRequest *)request
{
    request.transferManager = self;
    QCloudFakeRequestOperation* operation = [[QCloudFakeRequestOperation alloc] initWithRequest:request];
    [self.uploadFileQueue addOpreation:operation];
}

@end
