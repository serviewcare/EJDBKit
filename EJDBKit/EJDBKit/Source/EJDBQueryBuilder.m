#import "EJDBQueryBuilder.h"
#import "EJDBQueryOrderByHint.h"

@interface EJDBQueryBuilder ()
@property (strong,nonatomic) NSMutableDictionary *query;
@property (strong,nonatomic) NSMutableDictionary *hints;
@property (strong,nonatomic) NSMutableDictionary *joinDictionary;
@end

@implementation EJDBQueryBuilder

- (id)init
{
    self = [super init];
    if (self)
    {
        _query = [NSMutableDictionary dictionary];
        _hints = [NSMutableDictionary dictionary];
        _joinDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSDictionary *)query
{
    return [NSDictionary dictionaryWithDictionary:_query];
}

- (NSDictionary *)hints
{
    return [NSDictionary dictionaryWithDictionary:_hints];
}

- (NSDictionary *)joinDictionary
{
    return [NSDictionary dictionaryWithDictionary:_joinDictionary];
}

- (void)path:(NSString *)path matches:(id)value
{
    [_query setObject:value forKey:path];
}

- (void)path:(NSString *)path notMatches:(id)value
{
    [_query setObject:@{@"$not": value} forKey:path];
}

- (void)path:(NSString *)path matchesIgnoreCase:(NSString *)value
{
    [_query setObject:@{@"$icase": value} forKey:path];
}

- (void)path:(NSString *)path beginsWith:(NSString *)value
{
    [_query setObject:@{@"$begin": value} forKey:path];
}

- (void)path:(NSString *)path notBeginsWith:(NSString *)value
{
    [_query setObject:@{@"$not": @{@"$begin": value}} forKey:path];
}

- (void)path:(NSString *)path greaterThan:(NSNumber *)number
{
    [_query setObject:@{@"$gt": number} forKey:path];
}

- (void)path:(NSString *)path greaterThanOrEqualTo:(NSNumber *)number
{
    [_query setObject:@{@"$gte": number} forKey:path];
}

- (void)path:(NSString *)path lessThan:(NSNumber *)number
{
    [_query setObject:@{@"$lt": number} forKey:path];
}

- (void)path:(NSString *)path lessThanOrEqualTo:(NSNumber *)number
{
    [_query setObject:@{@"$lte": number} forKey:path];
}

- (void)path:(NSString *)path between:(NSArray *)values
{
    [_query setObject:@{@"$bt": values} forKey:path];
}

- (void)path:(NSString *)path in:(NSArray *)inValues
{
    [_query setObject:@{@"$in": inValues} forKey:path];
}

- (void)path:(NSString *)path inIgnoreCase:(NSArray *)inValues
{
    [_query setObject:@{@"$icase" : @{@"$in" : inValues}} forKey:path];
}

- (void)path:(NSString *)path notIn:(NSArray *)inValues
{
    [_query setObject:@{@"$nin": inValues} forKey:path];
}

- (void)path:(NSString *)path notInIgnoreCase:(NSArray *)inValues
{
    [_query setObject:@{@"$icase" : @{@"$nin" : inValues}} forKey:path];
}

- (void)path:(NSString *)path exists:(BOOL)exists
{
    [_query setObject:@{@"$exists" : [NSNumber numberWithBool:exists]} forKey:path];
}

- (void)path:(NSString *)path stringAllIn:(NSArray *)values
{
    [_query setObject:@{@"$strand": values} forKey:path];
}

- (void)path:(NSString *)path stringAnyIn:(NSArray *)values
{
    [_query setObject:@{@"$stror": values} forKey:path];
}

- (void)path:(NSString *)path elementsMatch:(EJDBQueryBuilder *)builder
{
    [_query setObject:@{@"$elemMatch" : builder.query} forKey:path];
}

/* TODO: REMOVE ME IN 0.7.0!!! */
- (void)path:(NSString *)path joinCollectionNamed:(NSString *)collectionName
{
    [self path:path addCollectionToJoin:collectionName];
}

- (void)path:(NSString *)path addCollectionToJoin:(NSString *)collectionName
{
    _joinDictionary[path] = @{@"$join": collectionName};
    _query[@"$do"] = _joinDictionary;
}

- (void)andJoin:(NSArray *)subqueries
{
    NSMutableArray *subqueriesArray = [NSMutableArray array];
    for (EJDBQueryBuilder *builder in subqueries)
    {
        [subqueriesArray addObject:builder.query];
    }
    [_query setObject:[NSArray arrayWithArray:subqueriesArray] forKey:@"$and"];
}

- (void)orJoin:(NSArray *)subqueries
{
    NSMutableArray *subqueriesArray = [NSMutableArray array];
    for (EJDBQueryBuilder *builder in subqueries)
    {
        [subqueriesArray addObject:builder.query];
    }
    [_query setObject:[NSArray arrayWithArray:subqueriesArray] forKey:@"$or"];
}

- (void)projectionForPath:(NSString *)path
{
    NSString *projectionPath = [path stringByAppendingString:@".$"];
    [_query setObject:@1 forKey:projectionPath];
}

- (void)set:(NSDictionary *)keysAndValues
{
    [_query setObject:keysAndValues forKey:@"$set"];
}

- (void)unset:(NSArray *)keys
{
    [_query setObject:keys forKey:@"$unset"];
}

- (void)upsert:(NSDictionary *)keysAndValues
{
    [_query setObject:keysAndValues forKey:@"$upsert"];
}

- (void)increment:(NSDictionary *)keysAndValues
{
    [_query setObject:keysAndValues forKey:@"$inc"];
}

- (void)dropAll
{
    [_query setObject:@YES forKey:@"$dropall"];
}

- (void)addToSet:(NSDictionary *)keysAndValues
{
    [_query setObject:keysAndValues forKey:@"$addToSet"];
}

- (void)addToSetAll:(NSDictionary *)keysAndValues
{
    [_query setObject:keysAndValues forKey:@"$addToSetAll"];
}

- (void)pull:(NSDictionary *)keysAndValues
{
    [_query setObject:keysAndValues forKey:@"$pull"];
}

- (void)pullAll:(NSDictionary *)keysAndValues
{
    [_query setObject:keysAndValues forKey:@"$pullAll"];
}

- (void)maxRecords:(NSNumber *)number
{
    [_hints setObject:number forKey:@"$max"];
}

- (void)skipRecords:(NSNumber *)number
{
    [_hints setObject:number forKey:@"$skip"];
}

- (void)onlyFields:(NSArray *)fields
{
    NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionary];
    for (NSString *field in fields)
    {
        [fieldsDictionary setObject:@1 forKey:field];
    }
    [_hints setObject:[NSDictionary dictionaryWithDictionary:fieldsDictionary] forKey:@"$fields"];
}

- (void)orderBy:(NSArray *)fields
{
    NSMutableDictionary *orderByDictionary = [NSMutableDictionary dictionary];
    for (EJDBQueryOrderByHint *orderByHint in fields)
    {
        [orderByDictionary setObject:[NSNumber numberWithInt:orderByHint.sortOrder] forKey:orderByHint.path];
    }
    [_hints setObject:[NSDictionary dictionaryWithDictionary:orderByDictionary] forKey:@"$orderby"];
}

@end