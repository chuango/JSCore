//
//  JSOCInterface.h
//  JSCore
//
//  Created by 刘亮 on 15/10/10.
//  Copyright (c) 2015年 刘亮. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <JavaScriptCore/JavaScriptCore.h>

//首先创建一个实现了JSExport协议的协议
@protocol TestJSObjectProtocol <JSExport>

//此处我们测试几种参数的情况，以下方法就是js中调用的方法，调用的时候，就会进入该方法
/*说白了，就是js调用TestNOParameter方法，那么会进入OC中的TestNOParameter方法，其他带参数的雷同*/
-(void)TestNOParameter;
-(void)TestOneParameter:(NSString *)message;
-(void)TestTowParameter:(NSString *)message1 SecondParameter:(NSString *)message2;

@end

@interface JSOCInterface : NSObject<TestJSObjectProtocol>

@end
