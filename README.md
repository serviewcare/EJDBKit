EJDBKit Framework
=================

The EJDBKit framework is an attempt at wrapping the [EJDB](https://github.com/Softmotions/ejdb) C library made by the folks over at [Softmotions](http://softmotions.com) into a convenient and easy to use Objective-C framework. For more information on EJDB check out [ejdb.org](http://ejdb.org).

Current Status
=================

It is definitely in a useable state but I would wait a bit before using it
in a production environment. Having said that, I plan on actively working on
this project until, at the very least, I'm satisfied it is a complete and correct
implementation.

Usage
==================

**EJDBDatabase** - This is the object you will likely use most often. It allows you to open/close a database and create/remove/query collections.

Example:

Open a database:

```objc
 EJDBDatabase *db = [[EJDBDatabase alloc] initWithPath:@"some/path" 
                                          dbFileName:@"foo.db"];
 [db openWithError:NULL];
```

Create a collection:

```objc
 EJDBCollection *collection = [db ensureCollectionWithName:@"foo" error:NULL];

```

**EJDBCollection** - This is the object through which you can save objects to the database, i.e. the collection in the database.

Using your newly created collection you can now
insert an object into the collection via a standard NSDictionary instance:

```objc
NSDictionary *dict1 = @{@"first name" : @"foo",@"last name" : @"bar"};
[collection saveObject:dict];
```
Or...multiple objects at once:

```objc
[collection saveObjects:@[dict1,dict2,dict3]];
```

So at this point you're probably wondering what object types are supported for inserting/fetching, here they are:

| Supported Foundation types |
|----------|
| NSString |
| NSNumber |
| NSDate   |
| NSDictionary|
| NSArray|
| NSData |
| NSNull |

Custom classes:

You can have your own custom NSObject subclass supported for inserting/fetching by adopting the BSONArchiving protocol:

```objc

@protocol BSONArchiving <NSObject>

/** 
 This method will be called when the code wants to return an OID 
 (in other words the _id field). For obvious
 reasons having a property name called _id may not be such a good idea. 
 You must return the name
 of the property in the class that will represent the OID.
*/
- (NSString *)oidPropertyName;

/**
 This method will be called when the code wants to encode your object into BSON. 
 You must provide a dictionary with a key named "type", it's value being the name of the class. 
 You can optionally provide a key named "_id"
 if you'd like to pass your own OID but 
 you must make sure it is a valid OID otherwise the object will not be saved.
 If you don't follow the rules, an exception will be thrown!
*/
- (NSDictionary *)toDictionary;

/**
 This method will be called when the code wants to decode your object from BSON.
  If the query you specified contains the "_id" key 
  it will be returned as the name you specified in the oidPropertyName method. 
  This makes it convenient to use with key/value coding 
  (i.e. enumerate the keys and set the values without having to set each property manually).
 Please note: If the query does return an "_id" key/value 
 and you return a nil or some non-existent property name
 an exception will be thrown!
*/
- (void)fromDictionary:(NSDictionary *)dictionary;

```

For example this will work:

```objc

@interface CustomArchivableClass : NSObject <BSONArchiving>

@property (copy,nonatomic) NSString *oid;
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSNumber *age;

@end


@implementation CustomArchivableClass

- (NSString *)oidPropertyName
{
    return @"oid";
}

- (NSDictionary *)toDictionary
{
    return @{@"type": NSStringFromClass([self class]), @"name" : _name, @"age" : _age};
}

- (void)fromDictionary:(NSDictionary *)dictionary
{
    for (id key in [dictionary keyEnumerator])
    {
        [self setValue:[dictionary objectForKey:key] forKey:key];
    }
}
@end

```

This won't!:

```objc

@interface BogusOIDClass : CustomArchivableClass

@end

@implementation BogusOIDClass

- (NSDictionary *)toDictionary
{
    return @{@"type" : NSStringFromClass([self class]), @"_id" : @"123", @"name" : self.name, @"age" : self.age };
}

@end
```



Querying a collection:

```objc
//Find all objects whose first name starts with 'f'
NSDictionary *theQuery = @{@"first name":@{@"$begin":@"f"}};

NSArray *results = [_db findObjectsWithQuery:theQuery 
						inCollection:collection error:NULL];
//results will contain dict1 as created in the preceeding section.
```

Querying with hints (order by,etc)

```objc
NSDictionary *theQuery = @{@"first name":@{@"$begin":@"f"}};

//Only return the 'first name' column, analagous to select `first name` from foo
NSDictionary *hints = @{@"$fields":@{@"first name": @1};

NSArray *results = [_db findObjectsWithQuery:theQuery
						hints:hints
						inCollection:collection error:NULL];
```

Don't need your collection anymore? Just remove it like so:

```objc
[db removeCollectionWithName:@"foo"];
```

That's about it for now. Do watch this space as it will be updated
shortly with even more information about how to use the framework. Pretty easy so far, right? :)


Building
===========================
If you'd like to participate in working on the framework itself, there are a few steps involved but it's not too bad! :)

1)	 Obviously...clone this project.

2) 	After it's cloned, the ejdb dependancy is included as a submodule so you'll have to get it via:

```
git submodule init
git submodule update

```

3) 	After the submodule is pulled down. You'll need to build the tcejdb libraries...fortunately this should be as simple as running the shell script (under EJDBKit folder):

```
    ./ejdb-build.sh
``` 

4)	After a bunch of compilation/building/etc you should be good to go!

If you just want to just use the framework, after completing the above steps
you need to do a few more things:

5) Drag the contents of the Source folder over into your project and make sure to check the **Copy items into destination groups' folder** when presented with the Add Files dialog.

6) Drag the **libtcejdb.a** file located under **EJDBKit/ejdb/lib** into your project and make sure to check the **Copy items into destination groups' folder** when presented with the Add Files dialog.

7) Link the **libz.dylib** library in **"Link Binary With Libraries"** by pressing the + button and selecting it from the provided list.

8) Add the following import statement where you'd like to use the framework:

```objc
#import "EJDBKit.h"

```

And you're all set.

It would be great to have this code as a static library and I have attempted it. Unfortunately, I
haven't been successful in making it easy to use,straightforward or work completely for that matter :(. Static lib build masters
are welcome to assist!! :)

iOS versions supported
=======================

The tcejdb library is built with a base of iOS 5.0 and deployment target of iOS 6.1.
I can't vouch for earlier versions and I'm not really concerned either (come on folks we'll have 7.0 soon)!

Collaboration
==============
As always, the more folks working on this, the better,stronger and (hopefully)faster the framework
will become. So contact me at darkstar.jd AT gmail if you're interested!

License
==============
LGPL (same as ejdb). Any other source according to its corresponding license.