//
//  SignUpViewController.swift
//  ParseStarterProject
//
//  Created by Scott Yoshimura on 8/11/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse


class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var imageUser: UIImageView!
    
    //the switch will default to true for Women
    @IBOutlet weak var switchInterestedInWomen: UISwitch!
    
    @IBAction func btnSignUp(sender: AnyObject) {
        //by the time this page is loaded, we already have the users facebook info, and we need to get to see what interest they are in. men or women.
        PFUser.currentUser()?["interestedInWomen"] = switchInterestedInWomen.on
        PFUser.currentUser()?.save()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //below is code to auto generate some users
/*
        //lets go ahead and set up some generic users for our testing. we will start by creating an array of urls to images
        let urlImageArray = ["http://s2.favim.com/610/34/Favim.com-art-dewdrop-drawing-fashion-fashion-illustration-273750.jpg","http://us.cdn3.123rf.com/168nwm/lucky2084/lucky20841507/lucky2084150700004/43152441-pop-art-illustration-of-woman-with-the-speech-bubble-pop-art-girl-party-invitation-birthday-greeting.jpg","http://png.clipart.me/graphics/thumbs/833/illustration-of-a-woman-looking-over-her-shoulder_83328190.jpg","http://uploads.jovo.to/idea_attachments/595218/screen-shot-2014-01-13-at-5-17-55-pm_bigger.png?1389626345"]
        
        //lets set up a counter variable for later use 
        var counter = 1
        //now lets loop through them
        for urlImage in urlImageArray {
            //for each urlImage in urlImage array, create a nsURL from the string urlImage
            let nsURL = NSURL(string: urlImage)!
            
            if let data = NSData(contentsOfURL: nsURL) {
                //and lets set the image to result created from data, the data of course is data
                self.imageUser.image = UIImage(data: data)
                
                //and lets save the image to parse from data
                let imageFile:PFFile = PFFile(data: data)
                
                //now instead of working with the currentUser, we are creating a new user. now we set userImage to be the image file and sign up the user so we use user.signup
                var user:PFUser = PFUser()
                
                var userName = "user \(counter)"
                
                user.username = userName
                user["image"] = imageFile
                user.password = "pass"
                user["interestedInWomen"] = false
                user["gender"] = "female"
                
                //and lets increaes the counter
                counter++
                user.signUp()
            }
        }
        
*/        
        
        //getting user about an information is called a graph request becuause a facebookk's user info is from their graph. And we use a graphPath to get specific info, and we want just general information, we just want "me". check the FBSDK to check extra parameters are available and more about graphPaths. lets also get more parameters. to specify want data i want about my user, let's create a dictionary, and specifiy the fields i want.
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender, email"])
        
        //lets kcick off the request.
        graphRequest.startWithCompletionHandler({
            //our completion handler will complete and we are not going to be returning anything (with a block) so we are using Void in
            (connection, result, error) -> Void in
            //lets start with an error check
            if error != nil {
                print(error)
            } else if let result = result {
                print(result)
                //lets start saving this result information to parse. we set gender at parse from result["gender"]
                PFUser.currentUser()?["gender"] = result["gender"]
                PFUser.currentUser()?["id"] = result["id"]
                PFUser.currentUser()?["name"] = result["name"]
                PFUser.currentUser()?["email"] = result["email"]
                
                //and lets save the data to where we want it in currentUser at parse
                PFUser.currentUser()?.save()
                
                
                //now lets get the user's picture from the id. the facebook profile picture is actually public. notice how we wont get a crash if something fails
                let userId = result["id"] as! String
                let facebookProfileImageUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
                //now lets get the contents of the url and put that into our app, and show the user taht we have their image and save it to parsse
                print(facebookProfileImageUrl)
                if let fbPicNSURL = NSURL(string: facebookProfileImageUrl) {
                    //if the above works lets get teh data and do something with it. we get it by getting the contents of the data from the contents of a NSURL
                    if let data = NSData(contentsOfURL: fbPicNSURL) {
                        //and lets set the image to result created from data, the data of course is data
                        self.imageUser.image = UIImage(data: data)
                        
                        //and lets save the image to parse from data
                        let imageFile:PFFile = PFFile(data: data)
                        PFUser.currentUser()?["image"] = imageFile
                        PFUser.currentUser()?.save()
                        
                    }
                    
                } else {
                    print("there was a problem loading fbPicNSURL")
                }
                
            }
            
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
