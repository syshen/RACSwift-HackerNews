//
//  ViewController.swift
//  RACSwift
//
//  Created by syshen on 5/6/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var indicator:UIActivityIndicatorView?
    @IBOutlet weak var tableView:UITableView?
    
    var action:Action<(), [NSNumber], NSError>?
    var cocoaAction:CocoaAction?
    
    let client = HNClient()
    var items:[NSNumber] = []
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")

        self.action = Action { self.client.topStories() }
        self.action!.executing.producer
            |> start(next:{ x in
                let executing = x as Bool
                if executing  {
                    self.indicator?.startAnimating()
                } else {
                    self.indicator?.stopAnimating()
                }
            })
        self.action!.values.observe(error: {error->() in
            let alert = UIAlertView()
            alert.title = "Error"
            alert.message = "Failed due to \(error)"
            alert.show()
            },
            next: { [unowned self] nums -> () in
                self.items = nums
                refreshControl.endRefreshing() // End refreshing when done
                self.tableView?.reloadData()
            })
        self.action!.apply().start()
  
        self.cocoaAction = CocoaAction(self.action!, {$0 as AnyObject?})
        refreshControl.addTarget(self.cocoaAction!, action: CocoaAction.selector, forControlEvents: .ValueChanged)
        self.tableView!.addSubview(refreshControl)
        
//        client.topStories()
//            |> on(started: { [unowned self] in
//                self.indicator!.startAnimating()
//                }, error:  { [unowned self] error in
//                    self.indicator!.stopAnimating()
//                }, completed:  { [unowned self] in
//                    self.indicator!.stopAnimating()
//                }
//            )
//            |> start(next: { [unowned self] nums -> Void in
//            self.items = nums
//            self.tableView?.reloadData()
//        })
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("tableViewCell", forIndexPath: indexPath) as! UITableViewCell

        let identity:NSNumber = self.items[indexPath.row]
                
//        self.client.item(identity) |> start(next: { dict->() in
//            if let story = dict as NSDictionary! {
//                if let text = story["title"] as? String {
//                    cell.textLabel!.text = text
//                }
//            }
//        })

        cell.textLabel!.text = ""
        
        let prepareReuseProducer = cell.rac_prepareForReuseSignal.toSignalProducer()
            |> map { _ in () }
            |> catch { _ in SignalProducer<(), NoError>.empty }
        
        let storyTitleProducer = self.client.item(identity)
            |> map { dict in dict["title"] as! String }
            |> catch { _ in SignalProducer<String, NoError>(value: "") }
            |> takeUntil(prepareReuseProducer)
            |> observeOn(UIScheduler())

    
        DynamicProperty(object: cell.textLabel!, keyPath: "text") <~ storyTitleProducer |> map { $0 as AnyObject? }
        
        
        return cell
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

