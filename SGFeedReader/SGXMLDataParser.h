//
//  SGXMLDataParser.h
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
// ================================================================================
//  Copyright (c) 2013 Supergegs7. All rights reserved.
//
#import "ASIHTTPRequestDelegate.h"
#import <Foundation/Foundation.h>

/**
 *  SGXMLDataParser inherits from NSObject. This class is responsible of sending data requests and parsing the response data.
 *  It is using third party libraries: ASIHTTPRequest, TBXML, and Apple's Reachbility calss.
 *
 */
@interface SGXMLDataParser : NSObject <ASIHTTPRequestDelegate>

/**
 *  C'tor
 *
 *  @param rootElements The elements tree to reech the root element holding the enumirate element,
 *  the last element of this tree should be the enumirate element, this element ofcourse wont be set as
 *  the root, rather it will be used for its enumeration purpose
 *  @param textElement  The text element name
 *  @param dateElement  The date elment name
 *
 *  @return a new instance of SGXMLDataParser
 */
- (instancetype)initWithRootElements:(NSArray *)rootElements
                         textElement:(NSString *)textElement
                         dateElement:(NSString *)dateElement;
/**
 *  Build an ASIHTTPRequest block from the given url string, and send the request asynchronous.
 *
 *  @param urlString A string holding the url for the request.
 *  When nil is passed as the argument, the last request will be performed again
 *
 */
- (void)request:(NSString *)urlString;

@end
