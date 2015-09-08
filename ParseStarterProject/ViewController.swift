//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    
    @IBOutlet weak var txtUserName: UITextField!
    
    
    @IBAction func signIn(sender: AnyObject) {
        
        //now when the user tries to sign in, we want to immediately try and log them in, and if we fail then sign them up. we got this code straight from the Parse documenation. note we are using the text that they entered
        PFUser.logInWithUsernameInBackground(self.txtUserName.text!, password:"mypass") {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                print("user logged in")
                print(user)
                //when the user is logged in we can perform the segue
                self.performSegueWithIdentifier("segueShowUsers", sender: nil)

            
            } else {
                
                //here we want to sign them up cause they are not there
                print("the error from the user not having an account is \(error): ")
                var user = PFUser()
                user.username = self.txtUserName.text
                user.password = "mypass"
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool, error: NSError?) -> Void in
                    if let error = error {
                        print("the error from a problem logging in is: \(error)")
                        
                    } else {
                        
                        // Hooray! Let them use the app now.
                        print("user account created")
                        //when the user is logged in we can perform the segue
                        self.performSegueWithIdentifier("segueShowUsers", sender: nil)

                    }
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //note, with viewDidLoad, we use it to load core elements, it actually doesn't mean the view has displayed, it just means the core elements are loaded

        
    }
    

    //remember segues have to be managed in the viewDidAppear method. below we are looking to see if the current PFUser username matches from facebook,

    override func viewDidAppear(animated: Bool) {
        //we can use viewDidAppear 
        if PFUser.currentUser()?.username != nil {
            self.performSegueWithIdentifier("segueShowUsers", sender: nil)
            print("we automatically segued becuase the current user is logged in and has an account")
            println("there is a userrrrrrrrrr")
            println(PFUser.currentUser())
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

