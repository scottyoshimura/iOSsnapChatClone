//
//  matchesTableViewController.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 8/22/15.
//  Copyright © 2015 Parse. All rights reserved.
//

// this cocoa touch class file is a viewController for the matches page of the app. this is where the user is viewing matches of people that accpet each other as matches. we will need to
import UIKit
import Parse


class matchesTableViewController: UITableViewController {

    //lets create an array of emails that we will need for later
    var emails = [String]()
    
    //lets create an array of images that we will use later
    var images = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        //now lets get the data that we want to show in this viewController
        let queryMatchedUsers = PFUser.query()!
        //lets start the query for users that have the currentUsers ojbectId in their accepted columgs
        //we want the currentUsers's object ID to include or contains the object ID in the accepted array. when you are searching through an array, you use equalTo to handle all the info
        queryMatchedUsers.whereKey("accepted", equalTo: (PFUser.currentUser()!.objectId)!)
        //then we want to see that we have accepted the other user's objectId
        queryMatchedUsers.whereKey("objectId", containedIn: PFUser.currentUser()?["accepted"] as! [String])
//appears the is not working
        queryMatchedUsers.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            
            if let results = results {
                print(results)
                //not that we cast result as an array of PFUser objects
                for result in results as! [PFUser] {
                    self.emails.append(result["email"]! as! String)
                    
                    //lets also download the users image
                    //lets create an image file variable to represent the other uses image
                    let otherUserImage = result["image"] as! PFFile
                    //then lets download the actual image
                    otherUserImage.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        //lets do our usual error check
                        if error != nil {
                            print(error)
                        } else {
                            if let data = imageData {
                                self.images.append(UIImage(data: data)!)
                                
                                //and note, we need to reload the data everytime we get an image
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                    
                }
            } else {
                print("there was an error")
            } // and then let's reload the data, becuase it only gets loaded once.
            self.tableView.reloadData()
            
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
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
        return emails.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell0", forIndexPath: indexPath)

        //lets set the text
        cell.textLabel?.text = emails[indexPath.row]
        
        //cell.textLabel?.text = "test"
       
        //and lets display the other user's images.
        if images.count > indexPath.row {
            cell.imageView?.image = images[indexPath.row]
        }
        
        return cell 
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //the easiest way to load an external application (in this case the email application) is to create a certain type of url that the phone knows to open with said application
        
        let phoneUrl = NSURL(string: "mailto:" + emails[indexPath.row])
        
        //to launch a shared application of UIApplication we send phoneUrl to the openUrl
        
        UIApplication.sharedApplication().openURL(phoneUrl!)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
