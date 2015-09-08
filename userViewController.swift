//
//  userViewController.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 9/4/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse
import ParseUI


//we have to add UINavigationControllerDelegate and UIImagePickerControllerDelegate
class userViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    //lets create an array to use later for our table. we will poplulate information into this array
    var userArray:[String] = []
    
    //lets create a variable to use later
    var activeRecipient = 0
    //lets set up a timer to use to check for new user images
    var timer = NSTimer()
    
    func pickImage(sender: AnyObject) {
        //this method creates a new viewController, which is a UIImagePickerContrller and displays it for the user to pick the image
        //lets create a variable called image
        let image = UIImagePickerController()
        
        //lets set the image delegate to self
        image.delegate = self
        
        //lets set source type to uiimagepickercontrollersourcetype.photolibrary to get the photolibrary
        //image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
 
    }
 
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
        println("image Selected")
        //when the user selects an image this code is run
        let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //upload to parse
        
        //var convertedImage =
        var imageToSend = PFObject(className:"image")
        imageToSend["image"] = PFFile(name: "image.jpeg", data: UIImageJPEGRepresentation(tempImage, 0.5))
        imageToSend["senderUserName"] = PFUser.currentUser()!.username
        imageToSend["recipientUserName"] = userArray[activeRecipient]
        imageToSend.save()
        
        //self.dismissViewControllerAnimated(true, completion: nil)
        picker.dismissViewControllerAnimated(true, completion:nil)
        

    }
   

    func hideMessage() {
        //lets set a tag for each of
        for subView in self.view.subviews {
            if subView.tag == 3{
                //anything with a tag of 3 will be removed
                subView.removeFromSuperview()
            }
        }
    }
 
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
 
        //here is where we will get our list of users. remember that in viewDidLoad we are loading components, not necessarily the view the user sees
  
        
        let query = PFUser.query()
        query!.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        let users = query!.findObjects()
        
        for user in users! {
            print(user.username)
            userArray.append(user.username as String!)
            tableView.reloadData()
        }

        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: false)

    }
   

    func checkForMessage() {
        println("checking for message")
        var query = PFQuery(className:"image")
        query.whereKey("recipientUserName", equalTo: PFUser.currentUser()!.username!)
        var images = query.findObjects()
        
        var done = false
        
        for image in images! {
            if done == false {
                //this creates an image file from the image file that we download
                var imageView:PFImageView = PFImageView()
                imageView.file = image["image"] as? PFFile
                imageView.loadInBackground({ (photo, error) -> Void in
                    println("we made it to this")
                    println(image)
                    
                    var senderUserName = ""
                    
                    if error == nil {
                        
                        if image["senderUserName"] != nil {
                            var senderUserName = image["senderUserName"]! as! String
                        } else {
                            var senderUserName = "Default Name"
                        }
                        
                        var alert = UIAlertController(title: "You have a message", message: "message from \(senderUserName)", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                            //lets create a view in the backfround so the user does not ineract with it it
                            var backGround = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            backGround.backgroundColor = UIColor.blackColor()
                            backGround.alpha = 0.8
                            backGround.tag = 3
                            self.view.addSubview(backGround)
                            
                            var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            displayedImage.image = photo
                            displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                            displayedImage.tag = 3
                            self.view.addSubview(displayedImage)
                            println("added subview")
                            
                            self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                            
                            image.delete()
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)

                    }

                })
                
                done = true
            }
            
        }

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return  userArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        //lets set the text to the current row in teh array. so we use indexPath.row
        cell.textLabel?!.text = userArray[indexPath.row]

        return cell as! UITableViewCell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        //below will tell us who we want to send
        activeRecipient = indexPath.row
        
        //and lets for now just call the pickImage method
        pickImage(self)
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueLogOut" {
            PFUser.logOut()
            println(PFUser.currentUser())
        } else {
            println("userisstill logged in")
        }
        
    }
    

    
    
    
}
