//
//  SGXMLDataParser.m
//  SGFeeder
//
//  Created by Guy Lachish on 10/21/13.
//  Using Tom Bradley's TBXML package.
//  Using Ben Copsey's ASIHTTPRequest package.
// ================================================================================
//  Any use of the software portions that use the TBXML and/or ASIHTTPRequest packages
//  must abide the terms of use as described by the TBXML and/or ASIHTTPRequest
//  authors.
//  SGFeedrView and its developer are not accountable for any use in this software
//  that do not fully follow the TBXML and/or ASIHTTPRequest terms of use.
// ===============================================================================
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//

#import "SGXMLDataParser.h"
#import "ASIHTTPRequest.h"
#import "TBXML.h"
#import "TBXML+HTTP.h"
#import "TBXML+Compression.h"

@interface SGXMLDataParser ()

@property (nonatomic, strong)NSArray * messages;

@end

@implementation SGXMLDataParser {
    
    NSArray * _rootElements;
    NSString * _dateElementName;
    NSString * _textElementName;
    NSURL * _url;
}

static int failCounter = 0;

-(instancetype)initWithRootElements:(NSArray *)rootElements
                        textElement:(NSString *)textElement
                        dateElement:(NSString *)dateElement {
    
    if (self = [super init]) {
        
        _textElementName = (nil != textElement) ? textElement : @"title";
        _dateElementName = (nil != dateElement) ? dateElement : @"pubDate";
        _rootElements = (nil != rootElements) ? rootElements : @[ @"channel", @"item" ];
    }
    
    return self;
}

#pragma mark ASIHTTPRequest

- (void)request:(NSString *)urlString {
    
    if (nil != urlString) {
        
        _url = [NSURL URLWithString:urlString];
    }
    
    if (nil != _url) {
        
        __block ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:_url];
        request.delegate = self;
        [request startAsynchronous];
    }
}

#pragma mark ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    if (0 != failCounter) failCounter = 0;
    
    NSMutableArray * rawMessages;
    NSString * responseString;
    int i = 0;
    while (nil == responseString && i < 5) {
        
     responseString = [[NSString alloc] initWithData:request.responseData
                                            encoding:[self _tryEncodingOption:i++]];
    }

    responseString = [self _replaceSpecialCharchters:responseString];
    
    NSError * error = nil;
    
    TBXML * xml = [[TBXML alloc] initWithXMLString:responseString error:&error];
    TBXMLElement * root = [self rootElementForXML:(TBXML *)xml];
    if (nil != root) {
        
        TBXMLElement * enumirateElement = [TBXML childElementNamed:[_rootElements lastObject] parentElement:root];
            rawMessages = [[NSMutableArray alloc] init];
        
        do {
            if ([[NSString stringWithCString:enumirateElement->name encoding:NSUTF8StringEncoding] isEqualToString:[_rootElements lastObject]]) {
                
                NSDictionary * messageDictionary = @{ @"message": [TBXML textForElement:[TBXML childElementNamed:_textElementName parentElement:enumirateElement]],
                                                      @"date": [self _formatDateStringFromString:[TBXML textForElement:[TBXML childElementNamed:_dateElementName parentElement:enumirateElement]]]
                                                    };
                if (nil != messageDictionary) {
                    
                    [rawMessages addObject:messageDictionary];
                }
            }
            enumirateElement = enumirateElement->nextSibling;
            
        } while (nil != enumirateElement);
        
        _messages = [self _buildMessages:rawMessages];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MESSAGES_LOADED"
                                                            object:self
                                                          userInfo:@{ @"messages": _messages }];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSLog(@"REQUEST FAILED:%@", request.error.localizedDescription);
    
    if (2 > failCounter++) {
        
        NSRunLoop * runloop = [NSRunLoop mainRunLoop];
        
        NSDate * date = [[NSDate alloc] initWithTimeInterval:5.0f sinceDate:[NSDate date]];
        
        
        NSTimer * timer = [[NSTimer alloc] initWithFireDate:date interval:0.0f target:self selector:@selector(_reloadRequestInvalidateTimer:) userInfo:nil repeats:NO];
        
        [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
    }
    else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"REQUEST_FAILED" object:nil];
        failCounter = 0;
    }
}

#pragma mark Private

/**
 *  Build the messages array
 *
 *  The messages are made of two elements: a date and a title, 
 *  these two element values are combined into a single string
 *
 *  @param messages An array of NSDictionary objects, each consists of the element values
 *  to be in the message string
 *
 *  @return An array(holding NSStrings) of all messages created
 */
- (NSArray *)_buildMessages:(NSMutableArray *)messages {
    
    NSMutableArray * res = [[NSMutableArray alloc] init];
    NSString * string;
    
    for (NSDictionary * message in messages) {
        
        string = [NSString stringWithFormat:@"%@  %@", [message objectForKey:@"date"]
                                                         , [message objectForKey:@"message"]];
        [res addObject:string];
    }
    
    return res;
}
/**
 *  Get the root XML element
 *
 *  @param xml The XML file wraped in a TBXML object.
 *  For further information about TBXMLvisit: http://www.tbxml.co.uk/TBXML/TBXML_Free.html
 *
 *  @return The root element holding the enumirator element as TBXMLElement
 */
- (TBXMLElement *)rootElementForXML:(TBXML *)xml {
    
    TBXMLElement * root = xml.rootXMLElement;
    
    if (nil != _rootElements && nil != root) {
        
        for (NSString * element in _rootElements) {
            
            if (element != [_rootElements lastObject]) {
                
                root = [TBXML childElementNamed:element parentElement:root];
            }
        }
    }
    
    return root;
}
/**
 *  Replace wrong encoded quotation marks
 *  (does not support the local Quotation marks)
 *
 *  @param originalString The encoded string
 *
 *  @return A string with the standard quotation marks
 */
- (NSString *)_replaceSpecialCharchters:(NSString *)originalString {
    NSMutableString * result = [NSMutableString stringWithString:originalString];
    NSRange range = NSMakeRange(0, (result.length));
    
    [result replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSCaseInsensitiveSearch range: range];
    range = NSMakeRange(0, (result.length));
    [result replaceOccurrencesOfString:@"&quot;" withString:@"''" options:NSCaseInsensitiveSearch range:range];
    NSLog(@"%@", result);
    
    return (NSString *) result;
    
}
/**
 *  Convert the standard xml date to the wished date format
 *
 *  @param originalDate The original date as a string
 *
 *  @return The converted date string
 */
- (NSString *)_formatDateStringFromString:(NSString *)originalDate {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
//  Important: No support yet for special date formats, unfortunately this needs to be changed manually.
//  =========
//  =========
//  This site was usefull for me:http://tahabebek.wordpress.com/2011/03/23/format-string-for-the-iphone-nsdateformatter/
    NSString * localDateComponents = [NSDateFormatter dateFormatFromTemplate:@"dd',' MMM yyyy h:mm:ss a" options:0 locale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"EEE',' dd MMM yyyy HH:mm:ss z"];
    NSDate * date = [formatter dateFromString:originalDate];
    
//    convert date to the local date
    NSString * localizedTime = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:localDateComponents];
    date = [formatter dateFromString:localizedTime];
    
//    apply a dateFormat that returns the time as 24h time
    [formatter setDateFormat:@"HH:mm"];
    localizedTime = [formatter stringFromDate:date];
    
    return localizedTime;
}
/**
 *  Set the string encoding.
 *  In many cases the default string encoding is NSUTF8String, but for some languages 
 *  this may differ, if a special string encoding is needed, you should add it to the switch condition
 *  inside this method body.
 *
 *  @param index An index that determines which string encoding should be returned
 *
 *  @return The current string encoding
 */
- (NSStringEncoding)_tryEncodingOption:(int)index {
    
    NSStringEncoding encoding = NSUTF8StringEncoding;
    
    switch (index) {
        case 0:
            encoding = NSUTF8StringEncoding;
            break;
        case 1:
            encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingWindowsHebrew);
            break;
        default:
            encoding = NSUTF8StringEncoding;
            break;
    }
    
    return encoding;
}

/**
 *  Reload the last request in case of failure
 *
 *  @param timer The timer that fired the request
 */
- (void) _reloadRequestInvalidateTimer:(NSTimer *)timer {
    
    [timer invalidate];
    [self request:nil];
}

@end
