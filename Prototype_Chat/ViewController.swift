//
//  ViewController.swift
//  Prototype_Chat
//
//  Created by David Gourde on 2015-09-03.
//  Copyright (c) 2015 David Gourde. All rights reserved.
//

import UIKit

//this view controller represents the chat main view controller
class ViewController: UIViewController, NSStreamDelegate  {
    
    //UI elements
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var monTexte: UITextField!
    @IBOutlet weak var messages: UITextView!
    
    
    //imported elements
    var host = ""
    var port = 0
    var userName = ""
    


    /*
        this is the first function to be called when the view loads
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //connectToTCPServer(self.host, port:self.port,userName: self.userName)
        
        initNetworkCommunication(self.host as CFString, connectionPort:UInt32(self.port))
        
        joinChat(self.userName)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //-------Networking------//

    //Client Socket
    var inputStream: NSInputStream!
    var outputStream: NSOutputStream!
    
    func initNetworkCommunication(connectionHost: CFString, connectionPort: UInt32) {
        var readstream : Unmanaged<CFReadStream>?
        var writestream : Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, connectionHost, connectionPort, &readstream, &writestream)
        inputStream = readstream!.takeRetainedValue()
        outputStream = writestream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
    }
    
    /**
    @input: userName
    @output:
    */
    func joinChat(user: String) {
        let response: String = "\(user)"
        let data: NSData = response.dataUsingEncoding(NSASCIIStringEncoding)!
        outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    func quitChat(){
        
        inputStream.close()
        outputStream.close()
    }
    
    
    @IBAction func envoyer(sender: AnyObject) {
        //send the message to the server
        
        //TODO: verifier que la connection a ete etablie avant d'envoyer le message
        let response: String = "!!20!1 \(monTexte.text)"
        monTexte.text = ""
        
        let data: NSData = response.dataUsingEncoding(NSASCIIStringEncoding)!
        
        self.outputStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        
        /*
        if success{
            println("message sent successfully")
        }
        else {
            println("message not sent (connexion error)")
            println(errorMsg)
        }
        */
        
        monTexte.text = "";
    }
    
  
    
    /**stream()
    handle the NSStream events.
    It's here where the incomming TCP messages are handled
    */
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch (eventCode){
        case NSStreamEvent.ErrorOccurred:
            NSLog("ErrorOccurred")
            break
        case NSStreamEvent.EndEncountered:
            NSLog("EndEncountered")
            break
        case NSStreamEvent.None:
            NSLog("None")
            break
        case NSStreamEvent.HasBytesAvailable:
            NSLog("HasBytesAvaible")
            var buffer = [UInt8](count: 4096, repeatedValue: 0)
            if ( aStream == inputStream){
                
                while (inputStream.hasBytesAvailable){
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if(len > 0){
                        let output = NSString(bytes: &buffer, length: buffer.count, encoding: NSUTF8StringEncoding)
                        if (output != ""){
                            print(output!)
                            let stringOutput = output as! String
                            updateChatView(stringOutput)
                            NSLog("server said: %@", output!)
                            
                        }
                    }
                }
            }
            break
        case NSStreamEvent():
            NSLog("allZeros")
            break
        case NSStreamEvent.OpenCompleted:
            NSLog("OpenCompleted")
            break
        case NSStreamEvent.HasSpaceAvailable:
            NSLog("HasSpaceAvailable")
            break
        default:
            NSLog("unknown.")
        }
        
    }
    /*updateChatView()
    
    @input: newMessage -> message to be added on the chat view
    @output: messages -> updates the message text view
    */
    func updateChatView(message:String){
        
        //we need to get rid of the begining of the message that contains the size of the package
        // Exemple: !!12!salut  -> salut
       
        let splittedMessage = message.characters.split {$0 == " "}
        
        print(splittedMessage[1])
        print(splittedMessage[2])
        print(splittedMessage[3])
        print(splittedMessage[4])
        print(splittedMessage[5])
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.stringFromDate(date)
        messages.text! = formatter.stringFromDate(date) + "\t" + message + "\n" + messages.text!
        
    }

    
    
    
    
    
    //---------Segue manengement(Transitions)-------------
    
    /*
        IBAction from
    */
    @IBAction func backToLoginView(sender: UIButton) {
       
        inputStream.close()
        outputStream.close()
        showFirstViewController()
    }
    
    /*
    * show the login screen
    */
    func showFirstViewController() {
        self.performSegueWithIdentifier("idFirstSegueUnwind", sender: self)
    }
    
    }

