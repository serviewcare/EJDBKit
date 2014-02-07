#import "EJDBFIQueryBuilder.h"
#import "EJDBQueryOrderByHint.h"

@implementation EJDBFIQueryBuilder


- (id)initWithDictionary:(NSDictionary *)dict hints:(NSDictionary *)hints joins:(NSDictionary *)joins
{
    self = [super init];
    if (self)
    {
        _query = dict;
        _hints = hints;
        _joins = joins;
    }
    return self;
}

+ (EJDBFIQueryBuilder *)build
{
   return [[EJDBFIQueryBuilder alloc]initWithDictionary:[NSDictionary dictionary] hints:[NSDictionary dictionary] joins:[NSDictionary dictionary]];
}

- (PathValueBlock)match
{
    return ^(NSString *path,id obj) {
       NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [result setObject:obj forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:result hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)notMatch
{
    return ^(NSString *path, id obj) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$not" toObject:obj] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (StringsBlock)matchIgnoreCase
{
    return ^(NSString *path, NSString *substring) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$icase" toObject:substring] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (StringsBlock)beginsWith
{
    return ^(NSString *path, NSString *substring) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$begin" toObject:substring] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (StringsBlock)notBeginsWith
{
    return ^(NSString *path, NSString *substring) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        NSDictionary *begin = [self applyOperator:@"$begin" toObject:substring];
        [results setObject:[self applyOperator:@"$not" toObject:begin] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathNumberBlock)greaterThan
{
    return ^(NSString *path, NSNumber *number) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$gt" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathNumberBlock)greaterThanOrEqualTo
{
    return ^(NSString *path, NSNumber *number) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$gte" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathNumberBlock)lessThan
{
    return ^(NSString *path, NSNumber *number) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$lt" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathNumberBlock)lessThanOrEqualTo
{
    return ^(NSString *path, NSNumber *number) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$lte" toObject:number] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)between
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$bt" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)in
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$in" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)inIgnoreCase
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSDictionary *in = [self applyOperator:@"$in" toObject:obj];
      [results setObject:[self applyOperator:@"$icase" toObject:in] forKey:path];
      return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)notIn
{
     return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$nin" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };   
}

- (PathValueBlock)notInIgnoreCase
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSDictionary *inQuery = [self applyOperator:@"$nin" toObject:obj];
      [results setObject:[self applyOperator:@"$icase" toObject:inQuery] forKey:path];
      return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathBlock)exists
{
    return ^(NSString *path) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSNumber *yes = [NSNumber numberWithBool:YES];
       [results setObject:[self applyOperator:@"$exists" toObject:yes] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathBlock)notExists
{
    return ^(NSString *path) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
      NSNumber *no = [NSNumber numberWithBool:NO];
       [results setObject:[self applyOperator:@"$exists" toObject:no] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)stringAllIn
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$strand" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)stringAnyIn
{
    return ^(NSString *path, id obj) {
      NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       [results setObject:[self applyOperator:@"$stror" toObject:obj] forKey:path];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathValueBlock)elemsMatch
{
    return ^(NSString *path, EJDBFIQueryBuilder *builder) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$elemMatch" toObject:builder.query] forKey:path];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

/* TODO: REMOVE ME IN 0.7.0!!! */
- (PathBlock)joinCollection
{
    return ^(NSString *collectionName)
    {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:[self applyOperator:@"$join" toObject:collectionName] forKey:@"$do"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (StringsBlock)addJoinToCollection
{
    return ^(NSString *path, NSString *collectionName)
    {
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:self.query];
        NSMutableDictionary *joins;
        if (self.joins)
        {
            joins = [NSMutableDictionary dictionaryWithDictionary:self.joins];
        }
        else
        {
            joins = [NSMutableDictionary dictionary];
        }
        joins[path] = [self applyOperator:@"$join" toObject:collectionName];
        _joins = [NSDictionary dictionaryWithDictionary:joins];
        query[@"$do"] = _joins;
        _query = [NSDictionary dictionaryWithDictionary:query];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:self.hints joins:self.joins];
    };
}

- (AndOrJoinBlock)andJoin
{
    return ^(NSArray *subqueries) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       NSMutableArray *subqueriesArray = [NSMutableArray array];
       for (EJDBFIQueryBuilder *builder in subqueries)
       {
           [subqueriesArray addObject:builder.query];
       }
      [results setObject:[NSArray arrayWithArray:subqueriesArray] forKey:@"$and"];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (AndOrJoinBlock)orJoin
{
     return ^(NSArray *subqueries) {
       NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
       NSMutableArray *subqueriesArray = [NSMutableArray array];
       for (EJDBFIQueryBuilder *builder in subqueries)
       {
           [subqueriesArray addObject:builder.query];
       }
      [results setObject:[NSArray arrayWithArray:subqueriesArray] forKey:@"$or"];
       return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (PathBlock)projection
{
    return ^(NSString *path) {
        NSString *projectionPath = [path stringByAppendingString:@".$"];
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:@1 forKey:projectionPath];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (DictionaryBlock)set
{
    return ^(NSDictionary *dictionary) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:dictionary forKey:@"$set"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (ArrayBlock)unset
{
    return ^(NSArray *keys) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:keys forKey:@"$unset"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (DictionaryBlock)upsert
{
    return ^(NSDictionary *dictionary) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:dictionary forKey:@"$upsert"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (DictionaryBlock)increment
{
    return ^(NSDictionary *dictionary) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:dictionary forKey:@"$inc"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (EmptyBlock)dropAll
{
    return ^{
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:@YES forKey:@"$dropall"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (DictionaryBlock)addToSet
{
    return ^(NSDictionary *dictionary) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:dictionary forKey:@"$addToSet"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (DictionaryBlock)addToSetAll
{
    return ^(NSDictionary *dictionary) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:dictionary forKey:@"$addToSetAll"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (DictionaryBlock)pull
{
    return ^(NSDictionary *dictionary) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:dictionary forKey:@"$pull"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (DictionaryBlock)pullAll
{
    return ^(NSDictionary *dictionary) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:dictionary forKey:@"$pullAll"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

- (StringsBlock)collectionJoin
{
    return ^(NSString *path, NSString *collectionName) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.query];
        [results setObject:@{path : @{@"$join": collectionName}} forKey:@"$do"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:results hints:self.hints joins:self.joins];
    };
}

#pragma mark - Hints

- (NumberBlock)maxRecords
{
    return ^(NSNumber *number) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        [results setObject:number forKey:@"$max"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results] joins:self.joins];
    };
}

- (NumberBlock)skipRecords
{
    return ^(NSNumber *number) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        [results setObject:number forKey:@"$skip"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results] joins:self.joins];
    };
}

- (ArrayBlock)onlyFields
{
    return ^(NSArray *fields) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionary];
        for (NSString *field in fields)
        {
            [fieldsDictionary setObject:@1 forKey:field];
        }
        [results setObject:[NSDictionary dictionaryWithDictionary:fieldsDictionary] forKey:@"$fields"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results] joins:self.joins];
    };
}

- (ArrayBlock)orderBy
{
    return ^(NSArray *fields) {
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:self.hints];
        NSMutableDictionary *orderByDictionary = [NSMutableDictionary dictionary];
        for (EJDBQueryOrderByHint *orderByHint in fields)
        {
            [orderByDictionary setObject:[NSNumber numberWithInt:orderByHint.sortOrder]
                                  forKey:orderByHint.path];
        }
        [results setObject:[NSDictionary dictionaryWithDictionary:orderByDictionary] forKey:@"$orderby"];
        return [[EJDBFIQueryBuilder alloc]initWithDictionary:self.query hints:[NSDictionary dictionaryWithDictionary:results] joins:self.joins];
    };
}

- (NSDictionary *)applyOperator:(NSString *)operator toObject:(id)object
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    [results setObject:object forKey:operator];
    return [NSDictionary dictionaryWithDictionary:results];
}

@end