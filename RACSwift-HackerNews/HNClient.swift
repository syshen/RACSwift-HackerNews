//
//  RHCClient.swift
//  RACSwift
//
//  Created by syshen on 5/6/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Alamofire

class HNClient: NSObject {
    var test = "Hello World"
   
    func maxItemIdentity() -> SignalProducer<NSNumber, NSError> {

        return SignalProducer{ observer, _ in

            self.requestManager.request(
                .GET,
                "https://hacker-news.firebaseio.com/v0/maxitem.json"
            ).responseJSON(options: .AllowFragments, completionHandler: { (_, _, JSON, error) -> Void in
                if let error = error {
                    sendError(observer, error)
                } else {
                    if let maxitem = JSON as? NSNumber {
                        sendNext(observer, maxitem)
                    }
                    sendCompleted(observer)
                }
            })
            
            return
            
        }
        
    }
    
    func topStories() -> SignalProducer<[NSNumber], NSError> {
        
        return SignalProducer{ observer, _ in
            
            self.requestManager.request(
                .GET,
                "https://hacker-news.firebaseio.com/v0/topstories.json"
            ).responseJSON(options: .AllowFragments, completionHandler: {
                (_, _, JSON, error) -> Void in
                
                if let error = error {
                    sendError(observer, error)
                } else {
                    if let nums = JSON as? [NSNumber] {
                        sendNext(observer, nums)
                    }
                    sendCompleted(observer)
                }
            })
            
            return
        }
        
    }
    
    func item(identity:NSNumber) -> SignalProducer<NSDictionary, NSError> {
        
        return SignalProducer { observer, _ in
            
            self.requestManager.request(
                .GET,
                "https://hacker-news.firebaseio.com/v0/item/\(identity).json"
            ).responseJSON(options: .AllowFragments,
                completionHandler: { (_, _, JSON, error) -> Void in
                    
                    if let error = error {
                        sendError(observer, error)
                    } else {
                        if let dict = JSON as? NSDictionary {
                            sendNext(observer, dict)
                        }
                        sendCompleted(observer)
                    }
            })
            
            return
        }
    }
    
    
    private let requestManager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
}
