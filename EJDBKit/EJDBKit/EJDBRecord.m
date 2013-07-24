#import "EJDBRecord.h"


@interface EJDBRecord ()
{

}
@property (assign,nonatomic) bson bsonObj;
@property (strong,nonatomic) NSMutableArray *fields;
@end


@implementation EJDBRecord

- (id)init
{
    self = [super init];
    if (self) {
        bson_init(&_bsonObj);
        _fields = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithFields:(NSArray *)fields
{
    self = [self init];
    if (self)
    {
        for (EJDBField *field in fields)
        {
            [self addField:field];
        }
    }
    
    return self;
}

- (void)addField:(EJDBField *)field
{
    [self appendPrimitive:field toBSON:&_bsonObj];
    [_fields addObject:field];
}

- (void)appendPrimitive:(EJDBField *)field toBSON:(bson *)bsonObj
{
    const char *key = [field.key cStringUsingEncoding:NSUTF8StringEncoding];
    if (field.fieldType == EJDBFieldTypeInt)
    {
        bson_append_int(bsonObj, key,[field.value intValue]);
    }
    else if (field.fieldType == EJDBFieldTypeDouble)
    {
        bson_append_double(bsonObj, key, [field.value doubleValue]);
    }
    else if (field.fieldType == EJDBFieldTypeBool)
    {
        bson_append_bool(bsonObj, key, [field.value boolValue]);
    }
    else if (field.fieldType == EJDBFieldTypeDate)
    {
        bson_append_date(bsonObj, key, [field.value timeIntervalSince1970]);
    }
    else if (field.fieldType == EJDBFieldTypeString)
    {
        bson_append_string(bsonObj, key, [field.value cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (void)addRecord:(EJDBRecord *)record
{
    bson obj;
    bson_init(&obj);
    bson_append_start_object(&obj, "something");
    for (EJDBField *field in record.fields)
    {
        
    }
    bson_append_finish_object(&obj);
}



/*
- (void)addField:(EJDBField *)field
{
    const char *key = [field.key cStringUsingEncoding:NSUTF8StringEncoding];
    int i = 0;
    switch (field.fieldType) {
        case EJDBFieldTypeInt:
            bson_append_int(&_bsonObj, key,[field.value intValue]);
        break;
        case EJDBFieldTypeDouble:
            bson_append_double(&_bsonObj, key, [field.value doubleValue]);
        break;
        case EJDBFieldTypeBool:
            bson_append_bool(&_bsonObj, key, [field.value boolValue]);
        break;
        case EJDBFieldTypeDate:
            bson_append_date(&_bsonObj, key, [field.value timeIntervalSince1970]);
        break;
        case EJDBFieldTypeString:
            bson_append_string(&_bsonObj, key, [field.value cStringUsingEncoding:NSUTF8StringEncoding]);
        break;
        case EJDBFieldTypeArray:
            bson_append_start_array(&_bsonObj, key);
            for (EJDBField *aField in field.value)
            {
                [self addField:aField];
            }
            bson_append_finish_array(&_bsonObj);
        break;
        case EJDBFieldTypeObjectArray:
            bson_append_start_array(&_bsonObj, key);
            EJDBRecord *aRecord = (EJDBRecord *)field.value;
            bson_append_start_object(&tmpObj,key);
            for (EJDBField *aField in aRecord.fields)
            {
                [self addField:aField];
            }
            bson_append_finish_object(&tmpObj);
            bson_append_finish_array(&_bsonObj);
        break;
    }
    if (field.fieldType != EJDBFieldTypeObjectArray)
    {
        [_fields addObject:field];
    }
}
*/

- (NSArray *)fields
{
    return [NSArray arrayWithArray:_fields];
}

- (void)close
{
    bson_finish(&_bsonObj);
}

- (bson *)bson
{
    return &_bsonObj;
}

- (void)dealloc
{
    bson_destroy(&_bsonObj);
}

@end


@implementation EJDBField

- (id)initWithKey:(NSString *)key fieldType:(EJDBFieldType)fieldType value:(id)value
{
    self = [super init];
    if (self)
    {
        _key = [key copy];
        _fieldType = fieldType;
        _value = value;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"key %@ \n fieldType %d \n value %@ \n type of value %@",
            _key,
            _fieldType,
            _value,
            NSStringFromClass([_value class])];
}

@end
