//
//  AuditTokenHack.m
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

#import <Foundation/Foundation.h>
#import "AuditTokenHack.h"

@implementation AuditTokenHack

+ (NSData *)getAuditTokenDataFromNSXPCConnection:(NSXPCConnection *)connection {
    audit_token_t auditToken = connection.auditToken;
    return [NSData dataWithBytes:&auditToken length:sizeof(audit_token_t)];
}

@end
