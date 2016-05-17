//
//  DataManager.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/12/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class DataManager{
    
    var user : User? //stores the user
    let baseURL = "https://localendar.firebaseio.com"
    var connectionCount:Int = 0
    let showDebug = false
    
    init(){}
    
    func updateUserLocation() {
        
    }
    
    func pushOnline(){
        Firebase.goOnline()
        self.connectionCount += 1
        
        if(showDebug){
            print("online called: \(connectionCount)")
        }
    }
    
    func pushOffline(){
        if(self.connectionCount > 0){
            self.connectionCount -= 1
        }
        
        if(connectionCount == 0){
            Firebase.goOffline()
        }
        
        if(showDebug){
            print("offline called: \(connectionCount)")
        }
    }
    
    
    func createUser(email:String,password:String) {
        self.pushOnline()
        let ref = Firebase(url: baseURL)
        ref.createUser(email, password: password, withValueCompletionBlock: { error, result in
            if error != nil {
                // There was an error creating the account
                print("error in creating account")
                print("Error logging in")
            } else {
                let uid = result["uid"] as? String
                print("Successfully created user account with uid: \(uid)")
                self.loginUser(email, password: password)
                self.user = User(username: email, password: password, userID: uid!) //store the user information
                
                //save the user data to a table
                ref.childByAppendingPath("users").childByAppendingPath(uid).setValue(self.user!.toDictionary())
            }
            self.pushOffline()
        })
    }
    
    
    func loginUser(email:String,password:String){
        self.pushOnline()
        let ref = Firebase(url: baseURL)
        ref.authUser(email, password: password, withCompletionBlock: { error, authData in
                
                if error != nil {
                    // There was an error logging in to this account
                    print("Error logging in")
                    self.checkError(error.code)
                } else {
                    // We are now logged in
                    print("Successful login")
                    print(authData.providerData["email"])
                    self.user = User(username: email, password: password, userID: ref.authData.uid)
                    
                    self.readData()
                    
//                    print("UID: \(self.user.authData.uid)")
//                    print("auth: \(self.user.authData.auth)")
//                    print("expires: \(self.user.authData.expires)")
//                    print("provider data: \(self.user.authData.providerData)")
//                    print("token: \(self.user.authData.token)")
                }
                self.pushOffline()
        })
    }
    
    func logoutUser(){
        self.pushOnline()
        let ref = Firebase(url: baseURL)
        ref.unauth()
        self.pushOffline()
    }
    
    func changeUserPassword(oldEmail:String, password:String, newEmail:String){
        self.pushOnline()
        let ref = Firebase(url: "https://localendar.firebaseio.com")
        ref.changeEmailForUser(oldEmail, password: password, toNewEmail: newEmail, withCompletionBlock: { error in
            if error != nil {
                // There was an error processing the request
                print("Error changing password")
            } else {
                // Email changed successfully
                print("Successfully changed password")
            }
            self.pushOffline()
        })
    }
    
    func sendPasswordResetEmail(email:String){
        self.pushOnline()
        let ref = Firebase(url: baseURL)
        ref.resetPasswordForUser(email, withCompletionBlock: { error in
            if error != nil {
                // There was an error processing the request
                print("Error sending email")
            } else {
                // Password reset sent successfully
                print("Successfully sent email")
            }
            self.pushOffline()
        })
    }
    
    func deleteUser(email:String, password:String){
        self.pushOnline()
        let ref = Firebase(url: baseURL)
        ref.removeUser(email, password: password, withCompletionBlock: { error in
            if error != nil {
                // There was an error processing the request
                print("Error deleting account")
            } else {
                // Password changed successfully
                print("Successfully deleted account")
            }
            self.pushOffline()
        })
    }
    
    func checkError(error: Int){
        switch(error){
            //        case "INVALID_EMAIL":
            //            print("invalid email")
        //            break
        case -6:
            print("invalid password")
            break
//        case "INVALID_USER":
//            print("invalid user")
//            break
//        case "INVALID_CREDENTIALS":
//            print("invalid credentials")
//            break
//        case "EMAIL_TAKEN":
//            print("email taken")
//            break
//        case "NETWORK_ERROR":
//            print("network error")
        //            break
        default:
            print("unknown error occurred")
            break
        }
    }
    
    func readData(){
        self.pushOnline()
        let ref = Firebase(url: self.baseURL)
        if (self.user) != nil{
            print(self.user?.userID)
            ref.childByAppendingPath("users").childByAppendingPath(self.user?.userID).observeEventType(.Value, withBlock: { snapshot in
                if let email = snapshot.value.objectForKey("username"){
                    print("email is: \(email)")
                }
                self.pushOffline()
                }, withCancelBlock: { error in
                    print(error.description)
                    self.pushOffline()
            })
            
        }
    }
}