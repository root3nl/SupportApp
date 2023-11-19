//
//  AuditTokenHack.h
//  nl.root3.support.helper
//
//  Created by Jordy Witteman on 18/11/2023.
//

#ifndef AuditTokenHack_h
#define AuditTokenHack_h


#endif /* AuditTokenHack_h */

#import <Foundation/Foundation.h>

// Hack to get the private auditToken property
@interface NSXPCConnection(PrivateAuditToken)

@property (nonatomic, readonly) audit_token_t auditToken;

@end

// Interface for AuditTokenHack
@interface AuditTokenHack : NSObject

+(NSData *)getAuditTokenDataFromNSXPCConnection:(NSXPCConnection *)connection;

@end
