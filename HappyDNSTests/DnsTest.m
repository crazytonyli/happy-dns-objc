//
//  DnsTest.m
//  HappyDNS
//
//  Created by bailong on 15/6/30.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QNResolver.h"
#import "QNDnsManager.h"
#import "QNNetworkInfo.h"
#import "QNDomain.h"
#import "QNHijackingDetectWrapper.h"

@interface DnsTest : XCTestCase

@end

@implementation DnsTest

- (void)setUp {
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
	// Put teardown code here. This method is called after the invocation of each test method in the class.
	[super tearDown];
}

- (void)testDns {
	NSMutableArray *array = [[NSMutableArray alloc]init];
	[array addObject:[QNResolver systemResolver]];
	[array addObject:[[QNResolver alloc] initWithAddres:@"114.114.115.115"]];
	QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
	NSArray *ips = [dns query:@"www.qiniu.com"];
	XCTAssertNotNil(ips, @"PASS");
	XCTAssertTrue(ips.count > 0, @"PASS");
}

- (void)testCnc {
	NSMutableArray *array = [[NSMutableArray alloc]init];
	[array addObject:[QNResolver systemResolver]];
	[array addObject:[[QNResolver alloc] initWithAddres:@"114.114.115.115"]];
	QNNetworkInfo *info = [[QNNetworkInfo alloc] init:kQNMOBILE provider:kQNISP_CNC];
	QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:info];
	[dns putHosts:@"hello.qiniu.com" ip:@"1.1.1.1"];
	[dns putHosts:@"hello.qiniu.com" ip:@"2.2.2.2"];
	[dns putHosts:@"qiniu.com" ip:@"3.3.3.3"];
	[dns putHosts:@"qiniu.com" ip:@"4.4.4.4" provider:kQNISP_CNC];
	QNDomain *domain = [[QNDomain alloc]init:@"qiniu.com" hostsFirst:YES hasCname:NO maxTtl:0];
	NSArray *r = [dns queryWithDomain:domain];
	XCTAssertEqual(r.count, 1, @"PASS");
	XCTAssertEqualObjects(@"4.4.4.4", r[0], @"PASS");
}

- (void) testTtl {
	NSMutableArray *array = [[NSMutableArray alloc]init];
	[array addObject:[[QNHijackingDetectWrapper alloc] initWithResolver:[QNResolver systemResolver]]];
	[array addObject:[[QNHijackingDetectWrapper alloc]initWithResolver:[[QNResolver alloc] initWithAddres:@"114.114.115.115"]]];
	QNNetworkInfo *info = [[QNNetworkInfo alloc] init:kQNMOBILE provider:kQNISP_CNC];
	QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:info];
	[dns putHosts:@"hello.qiniu.com" ip:@"1.1.1.1"];
	[dns putHosts:@"hello.qiniu.com" ip:@"2.2.2.2"];
	[dns putHosts:@"qiniu.com" ip:@"3.3.3.3"];
	[dns putHosts:@"qiniu.com" ip:@"4.4.4.4" provider:kQNISP_CNC];

	QNDomain *domain = [[QNDomain alloc]init:@"qiniu.com" hostsFirst:NO hasCname:NO maxTtl:10];
	NSArray *r = [dns queryWithDomain:domain];
	XCTAssertEqual(r.count, 1, @"PASS");
	XCTAssertEqualObjects(@"4.4.4.4", r[0], @"PASS");

	domain = [[QNDomain alloc]init:@"qiniu.com" hostsFirst:NO hasCname:NO maxTtl:1000];
	r = [dns queryWithDomain:domain];
	XCTAssertEqual(r.count, 1, @"PASS");
	XCTAssertFalse([@"4.4.4.4" isEqualToString:r[0]], @"PASS");
}

- (void) testCname {
	NSMutableArray *array = [[NSMutableArray alloc]init];
	[array addObject:[[QNHijackingDetectWrapper alloc] initWithResolver:[QNResolver systemResolver]]];
	[array addObject:[[QNHijackingDetectWrapper alloc]initWithResolver:[[QNResolver alloc] initWithAddres:@"114.114.115.115"]]];
	QNNetworkInfo *info = [QNNetworkInfo normal];
	QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:info];
	[dns putHosts:@"hello.qiniu.com" ip:@"1.1.1.1"];
	[dns putHosts:@"hello.qiniu.com" ip:@"2.2.2.2"];
	[dns putHosts:@"qiniu.com" ip:@"3.3.3.3"];
	[dns putHosts:@"qiniu.com" ip:@"4.4.4.4" provider:kQNISP_CNC];

	QNDomain *domain = [[QNDomain alloc]init:@"qiniu.com" hostsFirst:NO hasCname:YES maxTtl:0];
	NSArray *r = [dns queryWithDomain:domain];
	XCTAssertEqual(r.count, 1, @"PASS");
	XCTAssertEqualObjects(@"3.3.3.3", r[0], @"PASS");

	domain = [[QNDomain alloc]init:@"qiniu.com" hostsFirst:NO hasCname:NO maxTtl:0];
	r = [dns queryWithDomain:domain];
	XCTAssertEqual(r.count, 1, @"PASS");
	XCTAssertFalse([@"3.3.3.3" isEqualToString:r[0]], @"PASS");
}

@end
