# iOSsnapChatClone

an iOS app that mirrors the functionality of snapChat on startup

this app mirrors some of the functionality of snapchat. 

you will need your own application key and id from parse and add them to the AppDelegate.swift

note, this only recreates the functionality of snapchat on start up querying parse to see if the current user has an image from a sender in the database at parse.

there is also an issue with the  var senderUserName = image["senderUserName"]! as! String variable when we are trying to get the senderUserName from parse. It is not getting pulled into the alert correctly. If someone can fix this and repost to Git that would be great.