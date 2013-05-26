//
//  TouchDBTest.m
//  TouchDBTest
//
//  Created by Sander Dijkhuis on 5/26/13.
//  Copyright (c) 2013 Sander Dijkhuis. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/CouchDesignDocument_Embedded.h>
#import <TouchDB/TouchDB.h>

#import "TouchDBTest.h"

@implementation TouchDBTest

- (void)test {
    CouchTouchDBServer *server = [CouchTouchDBServer sharedInstance];
    CouchDatabase *db = [server databaseNamed:@"testdb"];
    CouchDesignDocument *design;
    CouchQuery *query;
    CouchQueryRow *row;
    NSURLRequest *request;
    NSData *data;
    NSString *body;
    
    [[db DELETE] wait];
    [db create];
    
    design = [db designDocumentWithName:@"testdesign"];
    [design defineViewNamed:@"testview" mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
        emit(doc[@"name"], nil);
    } version:@"1"];
    
    [[db.untitledDocument putProperties:@{@"name": @"foo"}] wait];
    [[db.untitledDocument putProperties:@{@"name": @"bar"}] wait];
    
    query = [design queryViewNamed:@"testview"];
    query.keys = @[@"foo"];
    for (row in query.rows) {
        NSLog(@"got row: %@", row.key);
    }
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"touchdb:///testdb/_design/testdesign/_view/testview?keys=%5B%22foo%22%5D"]];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"json result using keys: %@", body);
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"touchdb:///testdb/_design/testdesign/_view/testview?key=%22foo%22"]];
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"json result using key: %@", body);
}

@end
