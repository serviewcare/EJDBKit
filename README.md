EJDBKit Framework
=================

The EJDBKit framework is an attempt at wrapping the [EJDB](https://github.com/Softmotions/ejdb) C library made by the folks over at [Softmotions](http://softmotions.com).
For more information on EJDB check out [ejdb.org](http://ejdb.org).

Current Status
=================
*THERE BE DRAGONS HERE!* The framework is *NOT* yet complete (alpha...very alpha)! *DO NOT* use it in a production environment or to make your next killer app! Not heeding this warning will probably cause you much pain, wailing
and gnashing of the teeth! You have been warned!!!

Ok,so if you're still here, it's not all doom and gloom as I intend to actively work on this project at least until I'm satisfied it is complete and more importantly, a correct Objective-C implementation of ejdb.

Building
=================
There are a few steps but it's not too bad! :)

1. Obviously...clone this project.
2. After it's cloned, the ejdb dependancy is included as a submodule so you'll have to get it via:

    git submodule init
    
    git submodule update
3. After the submodule is pulled down. You'll need to build the tcejdb libraries...fortunately
this should be as simple as running the shell script (under EJDBKit folder):

    ./ejdb-build.sh
    
4. After a bunch of compilation/building/etc you should be good to go!

Usage
==================

*EJDBDatabase* - This is the object you will likely use most often. It allows you to open/close a database and create/remove/query collections.

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

*EJDBCollection* - This is the object through which you can save objects to the database, i.e. the collection in the database.

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

| Supported Objective-C types |
|----------|
| NSString |
| NSNumber |
| NSDate   |
| NSDictionary|
| NSArray|
| NSData |
| NSNull |

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
LGPL (same as ejdb). Anything other source according to its corresponding license.