//
//  HomeMenuTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class DiscoverTableViewController: UITableViewController {
    
    enum DiscoverTitles: String {
        case TypeCollections = "What's Your Type?"
        case PlangoCollections = "Plango Favorites"
        case PopularPlans = "Popular Destinations"
//        case Favorite = "Favorite Destinations"
        
        var section: Int {
            switch self {
            case .TypeCollections: return 0
            case .PlangoCollections: return 1
            case .PopularPlans: return 2
//            case .Favorite: return 3
            }
        }
        
        static var count: Int {
            return DiscoverTitles.PopularPlans.hashValue + 1
        }
    }
    
    lazy var tagsArray = [Tag]()
    
    lazy var usersDictionary = [NSIndexPath:User]()
    lazy var popularDestinationsPlansArray = [Plan]?()
    lazy var plangoFavoriteCollectionsArray = [PlangoCollection]?()
    var plangoFavoritesDictionary: [String:[Plan]]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.plangoCream()
                
        let plansNib = UINib(nibName: "PlansCell", bundle: nil)
        self.tableView.registerNib(plansNib, forCellReuseIdentifier: CellID.Plans.rawValue)
        
        let topCollectionsNib = UINib(nibName: "TopCollectionsCell", bundle: nil)
        self.tableView.registerNib(topCollectionsNib, forCellReuseIdentifier: CellID.TopCollections.rawValue)
        
        self.tableView.registerClass(PlanTypesTableViewCell.self, forCellReuseIdentifier: CellID.PlanTypes.rawValue)
        
        fetchTags(Plango.EndPoint.AllTags.rawValue)

        fetchPopularDestinations()
        
        fetchPlangoFavMeta()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section:
            return Helper.CellHeight.superWide.value
        case DiscoverTitles.PlangoCollections.section:
            return Helper.CellHeight.superWide.value
        default:
            return Helper.CellHeight.plans.value
        }
    }
    
    func fetchPopularDestinations() {
        Plango.sharedInstance.findPlans(Plango.EndPoint.PopularDestination.rawValue, minDuration: nil, maxDuration: nil, tags: nil, selectedDestinations: nil, user: nil, isJapanSearch: nil) { (plans, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let plans = plans {
                self.popularDestinationsPlansArray = plans
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPlangoFavMeta() {
        Plango.sharedInstance.fetchPlangoFavoritesMeta(Plango.EndPoint.PlangoFavsMeta.rawValue) { (plangoCollections, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let collections = plangoCollections {
                
                //meta data set
                self.plangoFavoriteCollectionsArray = collections

                //now get plans and then reload tableView
                self.fetchPlangoFavorites()
            }
        }
    }
    
    func fetchPlangoFavorites() {
        Plango.sharedInstance.findPlans(Plango.EndPoint.PlangoFavorites.rawValue, minDuration: nil, maxDuration: nil, tags: nil, selectedDestinations: nil, user: nil, isJapanSearch: nil) { (plans, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let plans = plans {
                self.plangoFavoritesDictionary = [String:[Plan]]()

                for collection in self.plangoFavoriteCollectionsArray! {
                    var plansArray = [Plan]()
                    
                    for plan in plans {
                        if plan.plangoFavorite == collection.name {
                            plansArray.append(plan)
                        }
                    }
                    
                    self.plangoFavoritesDictionary![collection.name!] = plansArray
                }
//                self.plangoFavoritesDictionary = tempDictionary
                //reload table after all favorites data is set
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section: break
            
        case DiscoverTitles.PlangoCollections.section:
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TopCollectionsTableViewCell
            if let plans = cell.plans {
                let plansVC = PlansTableViewController()
                plansVC.plansArray = plans
                self.showViewController(plansVC, sender: nil)
            }

        default:
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlansTableViewCell
            let planSummary = PlanSummaryViewController()
            planSummary.plan = cell.plan
            self.showViewController(planSummary, sender: nil)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        switch indexPath.section {
            
        case DiscoverTitles.PopularPlans.section:
            
            let report = UITableViewRowAction(style: .Destructive, title: "Report") { action, index in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    tableView.setEditing(false, animated: true)
                    
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! PlansTableViewCell
                    cell.contentView.showSimpleLoading()
                    if let plan = cell.plan {
                        Plango.sharedInstance.reportSpam(Plango.EndPoint.Report.rawValue, planID: plan.id, onCompletion: { (error) in
                            cell.contentView.hideSimpleLoading()
                            if let error = error {
                                self.printPlangoError(error)
                                guard let message = error.message else {return}
                                cell.contentView.quickToast(message)
                            } else {
                                cell.contentView.imageToast("Successfully Sent", image: UIImage(named: "whiteCheck")!, notify: true)
                            }
                        })
                    }
                    
                    //NOTE: - hide this for now, but would let user type in message saying why they object
                    //                let reportVC = UIStoryboard(name: StoryboardID.Main.rawValue, bundle: nil).instantiateViewControllerWithIdentifier(ViewControllerID.Report.rawValue) as! ReportViewController
                    //                reportVC.plan = cell.plan
                    //                self.showViewController(reportVC, sender: nil)
                })
            }
            return [report]
            
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        switch indexPath.section {
        case DiscoverTitles.PopularPlans.section:
            return .Delete
        default:
            return .None
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DiscoverTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case DiscoverTitles.TypeCollections.section:
            return 1
        case DiscoverTitles.PlangoCollections.section:
            if let count = plangoFavoriteCollectionsArray?.count {
                return count
            } else {
                return 0
            }
        default:
            if let count = popularDestinationsPlansArray?.count {
                return count
            } else {
               return 0
            }
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.PlanTypes.rawValue, forIndexPath: indexPath) as! PlanTypesTableViewCell
            cell.configureWithDataSourceDelegate(dataSourceDelegate: self)
            return cell

        case DiscoverTitles.PlangoCollections.section:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.TopCollections.rawValue, forIndexPath: indexPath) as! TopCollectionsTableViewCell
            if let collections = self.plangoFavoriteCollectionsArray {
                let collection = collections[indexPath.row]
                cell.plangoCollection = collection
                
                guard let favorites = self.plangoFavoritesDictionary else { return cell }
                guard let plans = favorites[collection.name!] else { return cell }
                cell.plans = plans
                cell.configure()
            }
            
            return cell

        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Plans.rawValue, forIndexPath: indexPath) as! PlansTableViewCell
            if indexPath.section == DiscoverTitles.PopularPlans.section {
                if let plans = self.popularDestinationsPlansArray {
                    cell.plan = plans[indexPath.row]
                }
            }
            //TODO: - fetchUserForPlan copy method or refactor
            cell.configure()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case DiscoverTitles.TypeCollections.section:
            return DiscoverTitles.TypeCollections.rawValue
            
        case DiscoverTitles.PlangoCollections.section:
            return DiscoverTitles.PlangoCollections.rawValue
            
        case DiscoverTitles.PopularPlans.section:
            return DiscoverTitles.PopularPlans.rawValue
            
//        case DiscoverTitles.Favorite.section:
//            return DiscoverTitles.Favorite.rawValue
        
        default:
            return nil
        }
    }

}

extension DiscoverTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func fetchTags(endPoint: String) {
        Plango.sharedInstance.fetchTags(endPoint) { (receivedTags, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let tags = receivedTags {
                self.tagsArray = tags
                print(self.tagsArray.count.description)
                self.tableView.reloadData()
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellID.SpecificType.rawValue, forIndexPath: indexPath) as! TypeCollectionViewCell
        
        // Configure the cell
        cell.plangoTag = tagsArray[indexPath.row]
        cell.configure()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TypeCollectionViewCell
        guard let tag = cell.plangoTag else {return}
        self.tableView.showSimpleLoading()
        Plango.sharedInstance.findPlans(Plango.EndPoint.FindPlans.rawValue, minDuration: nil, maxDuration: nil, tags: [tag], selectedDestinations: nil, user: nil, isJapanSearch: nil) { (receivedPlans, errorString) in
            self.tableView.hideSimpleLoading()
            if let error = errorString {
                print(error)
            } else if let plans = receivedPlans {
                let plansVC = PlansTableViewController()
                plansVC.plansArray = plans
                self.showViewController(plansVC, sender: nil)
            }
        }
    }

}
