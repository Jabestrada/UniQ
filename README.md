# UniQ
Proof-of-concept mini-project for a generic data access layer using Swift

## UniQ and why you should consider it

UniQ (Universal Query) is a simple proof-of-concept project that I built to demonstrate how a common data adapter in iOS using Swift is feasible. A common data adapter forms an abstraction layer between View and Controller code and the Model's data store, and offers the following benefits:
+ Consistent CRUD API regardless of the data store. Different data stores have their own data access APIs and developers have to know each one that they are going to use. With the proposed data adapter, there is only a single API to deal with regardless of the specific data store implementation.
+ Data store can change without affecting View and Controller code. This minimizes the impact of API-specific dependencies on the data store should there be any significant changes (such as a third-party service shutting down * *cough* * Parse * *cough* *).

## Scope
The POC in its current form covers Core Data, Parse and Firebase data stores. Demonstrated data access methods are:
+ Create
+ Read One / Read All
+ Update
+ Delete

## Limitations
+ Any generic adapter framework would have to trade off specialized features of various adaptees in favor of loose coupling, and this POC is no exception. For instance, the event-listening capabilities of Firebase are not included in this POC; neither are the authentication and social API integration features found in Parse and Firebase.

+ You'll find that not all filtering predicates are implemented for the covered data sources. I only covered those that I specifically needed in my iOS apps and expanded coverage as I went. Implementation-wise, you'll be looking to expand the buildPredicate methods of the data adapter implementations. The Firebase implementation for buildPredicate is empty as I've only picked up on it just a few days ago as of writing (specifically, a day after Parse announced it was shutting down).

+ Pointer-type fields (such as Parse's PFFile) are not covered. Creating another abstraction layer on top of these field types is highly feasible and certainly doable; may be considered in future updates.

## Running the project
1. Download this repo.
2. Open up a Terminal session on the root of the application (where file named "podfile" also resides).
3. Run pod install; this may take a while.  I deleted the binaries for Firebase from this repo because they were quite large (around 70 MB). Pulling them via CocoaPods may be faster.
4. Open UniQ.xcworkspace in XCode. At this point, you'll get compiler errors if you try to build the project. That's because the project contains redundant definitions of the Person class for each data source type. Follow the instructions that follow on how to run the project for each data source type.
 
## General build guidelines

The procedures below assume a fresh copy of this repo. After each set of instructions, you would have to revert code to its pristine state. One of the easiest ways to cope with this is to keep copies of the original project and use a fresh copy when you try out each data adapter.

Note that while you're swapping the concrete DataAdapters and implementation-specific model classes, you are not changing any of the View or Controller code. Neither are you changing the Models/Common/PersonCommonExtension.swift file which contains the business logic layer of the app. The swap for the Person class definintion is necessary because each provider may have their own sub-classing rules (and limitations) when working with application models.


## Run with CoreDataAdapter
1. In XCode, exclude the following groups and files:
  * UniQ/UniQ/Models/Firebase
  * UniQ/UniQ/Models/Parse
  * UniQ/UniQ/DataAdapter/FirebaseDataAdapter.swift
2. Edit UniQ/UniQ/Utils/Factory.swift. Make sure the instantiation call to CoreDataAdapter is uncommented while those for ParseDataAdapter and FirebaseDataAdapter are commented.
3. Build, run and test the app.

## Run with ParseDataAdapter
1. In XCode, exclude the following groups and files:
  * UniQ/UniQ/Models/CoreData
  * UniQ/UniQ/Models/Firebase
  * UniQ/UniQ/DataAdapter/FirebaseDataAdapter.swift
2. Edit UniQ/UniQ/Utils/Factory.swift. Make sure the instantiation call to ParseDataAdapter is uncommented while those for FirebaseDataAdapter and CoreDataAdapter are commented.
3. Modify file UniQ/UniQ/Initialization/AppDelegate.swift. In application:didFinishLaunchingWithOptions, modify the client key and secret values in the call to Parse.setApplicationId. If you don't have an existing Parse account, you can use the current values in the source file but you won't be able to access the data via Parse's web UI. As of this writing, Parse no longer accepts new signups to their service.
4. Build, run and test the app.


## Run with FirebaseDataAdapter
1. In XCode, exclude the following groups and files:
  * UniQ/UniQ/Models/CoreData
  * UniQ/UniQ/Models/Parse
2. Edit UniQ/UniQ/Utils/Factory.swift. Make sure the instantiation call to FirebaseDataAdapter is uncommented while those for ParseDataAdapter and CoreDataAdapter are commented.
3. Modify file UniQ/UniQ/DataAdapter/FirebaseDataAdapter.swift and change the value of rootUrl to point to your Firebase database. For more info on setting up your Firebase database, visit http://www.firebase.com.
``` Swift
// TODO: Replace URL below with yours.
static var rootUrl = "https://<YOUR_FIREBASE_URL>"
```
Build, run and test the app.

 

