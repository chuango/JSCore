//
//  ViewController.m
//  JSCore
//
//  Created by 刘亮 on 15/10/10.
//  Copyright (c) 2015年 刘亮. All rights reserved.
//

#import "ViewController.h"
#import "JSOCInterface.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <objc/runtime.h>

//扩展已有类
@protocol JSUITextFieldExport <JSExport>

@property(nonatomic,copy) NSString *value;

@end


@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadUI];
    
    
    
    /*OC 调用js*/
    JSContext *context = [[JSContext alloc] init];
    JSValue *result = [context evaluateScript:@"var a = 2;a += 5;"];
    NSLog(@"2 + 2 = %d", [result toInt32]);
    
    
    
    /*相互之间转换*/
    //covert Objective-C Object to JavaScript Object
    NSString *objcObjectx = @"6";
    JSValue *jsObject = [JSValue valueWithObject:objcObjectx inContext:context];
    //Covert JavaScript Object to Objective-C Object
    id objcObject = [jsObject toObject];
    NSLog(@"%@",objcObject);
    
    //以下不用管，乱写的
    
    /*js调用OC*/
    /*有两种方式Block和JSExport协议*/
    context[@"makeUIColor"] = ^(NSDictionary *rgbColor){
        float red = [rgbColor[@"red"] floatValue];
        float green = [rgbColor[@"green"] floatValue];
        float blue = [rgbColor[@"blue"] floatValue];
        return [UIColor colorWithRed:(red / 255.0)
                               green:(green / 255.0)
                                blue:(blue / 255.0)
                               alpha:1];
    };
    JSValue *color = [context evaluateScript:@"makeUIColor({red: 50, green: 150, blue: 250})"];
    NSLog(@"color:%@",[color toObject]);
    

//    /*扩展已有类*/
//    UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, 100, 50)];
//    text.backgroundColor = [UIColor greenColor];
//    text.value = @"10";
//    [self.view addSubview:text];
//    
//    context[@"textFeild"] = text;//OC对象传入JS
//    class_addProtocol([UITextField class], @protocol(JSUITextFieldExport)); //必须添加runtime
    
    NSString *script = @"var num = parseInt(textField.text, 10);"
    "++num;"
    "textField.text = num;";
    [context evaluateScript:script];
    

    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Hello Objective-C" forState:UIControlStateNormal];
    button.frame = CGRectMake(20, 40, 280, 40);
    [self.view addSubview:button];
    context[@"button"] = button;
    [context evaluateScript:@"button.setTitleForState('Hello JavaScript', 0)"];
}


/*该方法重点看，主要讲到两种最主要的JS调用OC的方法*/
- (void)loadUI
{
    //加载本地离线html
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pinggu" ofType:@"html"];
    NSString*htmlstring=[[NSString alloc] initWithContentsOfFile:filePath  encoding:NSUTF8StringEncoding error:nil];
    [_webview loadHTMLString:htmlstring baseURL:nil];
    
    //获取js环境对象
     JSContext *context=[_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //第一种方式协议
    /*
     步骤1.新建一个继承NSbject的对象，一定要实现JSExport协议
        2.然后在里面实现js需要调用的方法A或者B(xxx)
        3.实例化该对象，把context[该对象的key]=该对象
        4.在js文件中，加入以下东西
        该对象的key.A
        该对象的key.B(参数)
        5.在第2步的实现接口中就能调用
        注意context对象必须通过
     JSContext *context=[_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
     获得
     */
    JSOCInterface *testJO=[JSOCInterface new];
    context[@"testobject"]=testJO;
    
//    //同样我们也用刚才的方式模拟一下js调用方法
//    NSString *jsStr1=@"testobject.TestNOParameter()";
//    [context evaluateScript:jsStr1];
//    NSString *jsStr2=@"testobject.TestOneParameter('参数1')";
//    [context evaluateScript:jsStr2];
//    NSString *jsStr3=@"testobject.TestTowParameterSecondParameter('参数A','参数B')";
//    [context evaluateScript:jsStr3];
    
    //第二种方式Block
    /*
     步骤：
     1.直接在js中，调用方法activityList({'tytyty':'hehe'})
     本质就是方法js方法，传入一个字典
     2.然后在OC中的
         context[@"activityList"] = ^(NSDictionary *param) {
         NSLog(@"%@", param);
         };
     直接就能在OC中获取到，js传出来的参数，本质是通过Block传递出来的
     通过同一个Key来传递数据的
     */
    context[@"activityList"] = ^(NSDictionary *param) {
        NSLog(@"%@", param);
    };
    
    // 2. 关联打印异常
    context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
    id userAgent = [_webview stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"%@", userAgent);
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



