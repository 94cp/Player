//
//  Net.h
//  Player
//
//  Created by chenp on 2018/9/17.
//  Copyright © 2018年 chenp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NetFlow;

@interface Net : NSObject

+ (NetFlow *)flow;

@end

@interface NetFlow : NSObject

@property (nonatomic, assign) u_int32_t send;
@property (nonatomic, assign) u_int32_t received;

@property (nonatomic, assign) u_int32_t wifiSend;
@property (nonatomic, assign) u_int32_t wifiReceived;

@property (nonatomic, assign) u_int32_t wwanSend;
@property (nonatomic, assign) u_int32_t wwanReceived;

@end

NS_ASSUME_NONNULL_END
