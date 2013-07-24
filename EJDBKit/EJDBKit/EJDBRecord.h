#import <Foundation/Foundation.h>
#include <tcejdb/ejdb.h>

typedef enum {
  EJDBFieldTypeInt,
  EJDBFieldTypeDouble,
  EJDBFieldTypeBool,
  EJDBFieldTypeDate,
  EJDBFieldTypeString,
  EJDBFieldTypeArray,
  EJDBFieldTypeObjectArray
} EJDBFieldType;

@class EJDBField;

@interface EJDBRecord : NSObject

@property (nonatomic,getter = bson,readonly) bson *bson;

@property (copy,nonatomic) NSString *key;

- (id)initWithFields:(NSArray *)fields;

- (void)addField:(EJDBField *)field;

- (NSArray *)fields;

- (void)close;

@end

@interface EJDBField : NSObject

@property (copy,nonatomic) NSString *key;

@property (assign,nonatomic) EJDBFieldType fieldType;

@property (strong,nonatomic) id value;

- (id)initWithKey:(NSString *)key fieldType:(EJDBFieldType)fieldType value:(id)value;

@end

