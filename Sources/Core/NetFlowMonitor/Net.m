//
//  Net.m
//  Player
//
//  Created by chenp on 2018/9/17.
//  Copyright © 2018年 chenp. All rights reserved.
//

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "Net.h"

@implementation Net

+ (NetFlow *)flow {
    NetFlow *flow = [[NetFlow alloc] init];
    
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1) {
        return flow;
    }
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next) {
        if (AF_LINK != ifa->ifa_addr->sa_family) continue;
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING)) continue;
        if (ifa->ifa_data == 0) continue;
        
        // network
        if (strncmp(ifa->ifa_name, "lo", 2)) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            flow.received += if_data->ifi_ibytes;
            flow.send += if_data->ifi_obytes;
        }
        
        // wifi
        if (!strcmp(ifa->ifa_name, "en0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            flow.wifiReceived += if_data->ifi_ibytes;
            flow.wifiSend += if_data->ifi_obytes;
        }
        
        // 流量
        if (!strcmp(ifa->ifa_name, "pdp_ip0")) {
            struct if_data* if_data = (struct if_data*)ifa->ifa_data;
            flow.wwanReceived += if_data->ifi_ibytes;
            flow.wwanSend += if_data->ifi_obytes;
        }
    }
    
    freeifaddrs(ifa_list);
    
    return flow;
}

@end

@implementation NetFlow

- (instancetype)init {
    self = [super init];
    if (self) {
        self.send = 0;
        self.received = 0;
        self.wifiSend = 0;
        self.wifiReceived = 0;
        self.wwanSend = 0;
        self.wwanReceived = 0;
    }
    return self;
}

@end
