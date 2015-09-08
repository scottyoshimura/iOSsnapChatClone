//
//  swipingViewController.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 8/14/15.
//  Copyright © 2015 Parse. All rights reserved.
//

//  we will allso load the location functions necessary to have the users see which other users are nearby. parse has geolocation as part of its feature set.

import UIKit
import Parse

class swipingViewController: UIViewController {

    //lets create a global variable called displayedId to hold who has been displayed
    var displayedUserId = ""
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var lblSwipeReject: UILabel!
    
    //the wasDragged method is going to receive a gestureRecognizer, called gesture, with a type UIPanGestrureREcognizer. we can then use a closure for some code.
    func wasDragged(gesture: UIPanGestureRecognizer) {
        //this function will give us alot of information that will be helpful.
        print("wasDragged")
        
        //we want to know the "translation" of the gesture. the translation from one point to another is a description of how to get from one point to another. we want to know where it started, and where it ended up.
        //lets create a variable to get that. we will take our gesture that was passed from the UIPanGestureRecognizer and we can take from that the translation in the view; the view is just self.
        let translation = gesture.translationInView(self.view)
        
        //now we want to move the label too, the translation coordinate.
        //notice we can't use label here, but the gesture variable gives us the object that has been dragged, so we can get that to represent our label. we have to force unwrap gesture.view, cause we know it will be there.
        print(translation)
        let label = gesture.view!
        
        //then we will set the label.center to the new coordinate. we get that from cgpoint. cg point creates a coordinate pair relative to the bottom left of the screen. and remember translation gives us a coordinate relative to the center of the screen, which is where we started off. too work out hte new coordinate is as a cgpoint to start off in the center of the screen, and then add the amount that has been translated in the x direction.
        
        label.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
        //we can set the label so that it returns to the center whenever the user lets their finger off the screen by checking another aspect of our gesture variable which is gesture.state
        
        //the more this label moves to left or right, we want it to get smaller lets set up a variable that tracks how far from the center the label is
        let xFromCenter = label.center.x - self.view.bounds.width / 2
        
        //lets set up a scale which is going to determine the size based on how far it is from the center. so we know we need xFromCenter, we don't care about scaling to the left or the right, so we use abs, which is short for absolute, which just gives you the value of xFromCenter regardless if it is positive or negative. we want the scale to be one in the center, and we want it to get smaller and smaller as the xFromCenter gets bigger and bigger. if you want something to get smaller, while something gets bigger, generally it is a good idea to divide by the thing that is getting bigger. so something like below, the scale will get smaller, as xFromCenter gets bigger. however, we want to be careful, cause when xFromCenter is small, then the scale could be flipped. so we don't ever want to make this thing bigger, only smaller. the way we can deal with that is to set the scale to a minimum of either the calculation below, or 1. so essentially, it can never be greater than 1.
        let scale = min(100 / abs(xFromCenter), 1)
        
        //below, makes a rotation based from an angle. the angle is in radians. a radian is like a degree, a deggree is split from a circle 360 degrees, with a tranform, the circle is split into two pi radians, which makes certain mathmatical tasks much easier, but make it more complicated to think about. for now, lets say about two pi is 6. so we want one radian.
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200)
        //we want the rotation to be roughly in proportion to the distance from the center. the positive and negative thing works in our favor
        
        //lets set up our. a scale is made from a previous transform, rotation in this case, and a scale in x and a scale in y
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        
        //below applies to both the rotation and stretch
        label.transform = stretch
        
        if gesture.state == UIGestureRecognizerState.Ended {
            
            //lets set up a varialbe to log acceptedorrejected
            var acceptedOrRejected = ""
            
            //lets first check to what degree the user has swiped to the left or right
            if label.center.x < 100 {
                print("not chosen" + displayedUserId)
                acceptedOrRejected = "rejected"
                //lets experiment with trying to get the image to disappear once it has been swiped
                self.userImage.image = nil
                
            } else if label.center.x > self.view.bounds.width - 100 {
                print("chosen")
                acceptedOrRejected = "accepted"
                self.userImage.image = nil
            }
            
            //now lets check to see if accepted or rejected is filled before continuing 
            if acceptedOrRejected != "" {
                //now here is where we want to take the current user and add the currentDisplayedUser's id that has been accepted to the accepted column. notice how we are using the variable that is a string that is populated with teh string "accepted" or "rejected"
                PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: acceptedOrRejected)
                
                //and then lets save the changes to parse
                PFUser.currentUser()?.save()
            }
            
            //when the gesture is designated as chosen or not chosen, we want the current users accepted and rejected arrays columns updated with who they have chosen or rejected respectively
            
            //lets reset the label to its origins
            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1, 1)
            label.transform = stretch
            
            //if the gesture state has ended, lets move the label to the center
            label.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
            
            //we want to call the updateImage function here
            updateImage()
        }
        
        //what we want is to have our label move around where ever the user wants to
    }
    
    func updateImage() {
        
        //lets go ahead and start loading some images one at a time. lets start with a query.
        let userQuery = PFUser.query()!
 /*
        
        //lets set up a where key to set up a geoBox to narrow down where the other users are. we will set a box, and look for users in that box. we set the soutwest of the box with the southwest geopoint, and the northeast at 0, 0 initially. we then set the latitude and longitude to whatever we want since we have a latitude point from the end user's device. we then subtract 1 for the withinGeoBoxFromSouthWest point and the toNorthEast point. this is very large, and is used for testing.
        //lets first see if we have a user location. we can do that my checking to see if
           if let latitude = PFUser.currentUser()!["location"]!.latitude {
            //and then lets check to see that we have a longitude
            if let longitude = PFUser.currentUser()?["location"]!.longitude {
                userQuery.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: latitude - 1 ,longitude: longitude - 1), toNortheast: PFGeoPoint(latitude: latitude + 1 ,longitude: longitude + 1))
                    print("The app is currently searching users from \(latitude) latitude to \(longitude) longitude")
            }

       }
*/
        //the below checks to see what the current user is into
        //lets set a check flag to see what the user is into. by default we will set it to male.
        var interestedIn = "male"
        //and below we will check what the current user is interested
        if PFUser.currentUser()!["interestedInWomen"]! as! Bool == true{
            interestedIn = "female"
        }
        
        //the below checks to see what other users are interested in. other user's need to be interested in the current user's gender
        //the gender of the other user, must be from what we got from above.
        //lets set a check flag to see what gender the other user is. by default we will set it to female.
        var isFemale = true
        //and below we will check what hte current user gender is
        //print(PFUser.currentUser()!["gender"])
        if PFUser.currentUser()!["gender"]! as! String == "male" {
            isFemale = false
        }
        
        
    //below is actually where we use the above qualifiying info to make the query to get users that the current user is interested in
        //now the other users interestedIn also needs to be the gender of the current user
        //below is gender is equal to interested in
        userQuery.whereKey("gender", equalTo:interestedIn)
        //the other user has to be interested in the opposite of what the current user is
        userQuery.whereKey("interestedInWomen", equalTo:isFemale)
        
        
        //lets set up some variables to help us in the next step. we want to filter out from all the users in the database, all the people that have been rejected, and all the people that have been accepted. both of those are people that we want to ignore on this viewController, because this is where the user is swiping through existing users.
        var ignoredUsers = [""]
        if let acceptedUsers = PFUser.currentUser()?["accepted"] {
            ignoredUsers += acceptedUsers as! Array
        }
        //and then the same with rejected users.
        if let rejectedUsers = PFUser.currentUser()?["rejected"] {
            ignoredUsers += rejectedUsers as! Array
        }
        
        //and then we search ignoredUsers for any user with an objectId not containedIn
        userQuery.whereKey("objectId", notContainedIn: ignoredUsers)
        //then lets set the limit to 1, we only want to see one result at a time
        userQuery.limit = 1
        userQuery.findObjectsInBackgroundWithBlock {
            //and we will have ojbects which is an array of anyobjects, and is an optional, and error is an NSError optional. returning nothing in void
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let objects = objects as?[PFObject] {
                //lets attempt to cast it to an array of PFObjects
                for object in objects{
                    
                    self.displayedUserId = object.objectId!
                    
                    //lets create an image file variable to represent the other uses image
                    let otherUserImage = object["image"] as! PFFile
                    //then lets download the actual image
                    otherUserImage.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        
                        //lets do our usual error check
                        if error != nil {
                            print(error)
                        } else {
                            if let data = imageData {
                                self.userImage.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //lets get the users location and save it on the parse side. a parse geopoint is just a lat and longitude. so we can use a Parse method here. dont forget to get the location permissions for the user
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            
            if let geoPoint = geoPoint{
                //lets go ahead and create a column called location that we will set to geoPoint
                PFUser.currentUser()?["location"] = geoPoint
                //and then save the current user location info
                PFUser.currentUser()?.save()
                
            }
        }
        
        
        //lets create a gesture to get let the user make a drag. //target is self, action is the method that we want called when a drag is recognized
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        //remember, if we want some information about the pan to be passed on to our selector we ahve to put the colon. if we didn't do that, we would still call wasDragged, but the info wouldn't be passed from the gestureRecognizer to the Selector. and we aer going to want to know when and where the user dragged the label
        //then lets add the gesture to the label
        userImage.addGestureRecognizer(gesture)
        //and we want to allow user interaction with the label
        userImage.userInteractionEnabled = true
        

        //lets call the updateImage method here
        updateImage()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logOut" {
            PFUser.logOut()
        }
    }
    

}
