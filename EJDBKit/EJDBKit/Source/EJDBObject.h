/*
 This is, as of now, not throughly tested and therefore volatile class!!!! Need to get back to this, probably for 0.2.0!!!
 DO NOT USE YET!!!!!
*/

#import <Foundation/Foundation.h>
#import "BSONArchiving.h"

@interface EJDBObject : NSObject<BSONArchiving>

@property (copy,nonatomic) NSString *oid;

@end
