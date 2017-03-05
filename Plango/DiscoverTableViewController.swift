//
//  HomeMenuTableViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 4/5/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit

class DiscoverSectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
}

class DiscoverTableViewController: UITableViewController {
    
    fileprivate enum DiscoverTitles: String {
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
            //whatever the last case in the enum is, then plus 1 gives you the count
            return DiscoverTitles.PopularPlans.hashValue + 1
        }
    }
    
    lazy var tagsArray = [Tag]()
    
    lazy var usersDictionary = [IndexPath:User]()
    lazy var popularDestinationsPlansArray = [Plan]?()
    lazy var plangoFavoriteCollectionsArray = [PlangoCollection]?()
    var plangoFavoritesDictionary: [String:[Plan]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        self.tableView.backgroundColor = UIColor.plangoBackgroundGray()
        self.navigationItem.title = "DISCOVER"
        
        // MARK: - Cell Types ------------------------------------------------------------------------
        let plansNib = UINib(nibName: "PlansCell", bundle: nil)
        self.tableView.register(plansNib, forCellReuseIdentifier: CellID.Plans.rawValue)
        
        let topCollectionsNib = UINib(nibName: "TopCollectionsCell", bundle: nil)
        self.tableView.register(topCollectionsNib, forCellReuseIdentifier: CellID.TopCollections.rawValue)
        
        let topCollectionsMiddleNib = UINib(nibName: "TopCollectionsMiddleCell", bundle: nil)
        self.tableView.register(topCollectionsMiddleNib, forCellReuseIdentifier: CellID.TopCollectionsMiddle.rawValue)
        
        self.tableView.register(PlanTypesTableViewCell.self, forCellReuseIdentifier: CellID.PlanTypes.rawValue)
        
        // headerfooter view is like a cell
        let sectionNib = UINib(nibName: "DiscoverHeader", bundle: nil)
        self.tableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: CellID.Header.rawValue)
        
        //------------------------------------------------------------------------
        
        fetchTags(Plango.EndPoint.AllTags.value)

        fetchPopularDestinations()
        
        fetchPlangoFavMeta()
    }
    
    func didPullRefresh() {
        if Helper.isConnectedToNetwork() {
            fetchTags(Plango.EndPoint.AllTags.value)
            
            fetchPopularDestinations()
            
            fetchPlangoFavMeta()
        } else {
            refreshControl?.endRefreshing()
            view.quickToast("No Internet")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPopularDestinations() {
        Plango.sharedInstance.fetchPlans(Plango.EndPoint.PopularDestination.value) { (plans, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let plans = plans {
                self.popularDestinationsPlansArray = plans
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPlangoFavMeta() {
        Plango.sharedInstance.fetchPlangoFavoritesMeta(Plango.EndPoint.PlangoFavsMeta.value) { (plangoCollections, error) in
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
        Plango.sharedInstance.fetchPlans(Plango.EndPoint.PlangoFavorites.value) { (plans, error) in
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
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view Delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section:
            return Helper.CellHeight.superWide.value
        case DiscoverTitles.PlangoCollections.section:
            guard let count = plangoFavoriteCollectionsArray?.count else {return 0.1}
            if indexPath.row != count - 1 {
                return Helper.CellHeight.superWide.value + 4
            } else { //last cell in list doesnt need bottom spacing
                return Helper.CellHeight.superWide.value
            }
        default:
            return Helper.CellHeight.plans.value
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section: break
            
        case DiscoverTitles.PlangoCollections.section:
            let cell = tableView.cellForRow(at: indexPath) as! TopCollectionsTableViewCell
            if let plans = cell.plans {
                let plansVC = PlansTableViewController()
                plansVC.plansArray = plans
                plansVC.navigationItem.title = cell.plangoCollection?.name?.uppercased()
                plansVC.hidesBottomBarWhenPushed = true
                self.show(plansVC, sender: nil)
            }

        default:
            let cell = tableView.cellForRow(at: indexPath) as! PlansTableViewCell
            let planSummary = PlanSummaryViewController()
            planSummary.plan = cell.plan
            planSummary.hidesBottomBarWhenPushed = true
            self.show(planSummary, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        switch indexPath.section {
            
        case DiscoverTitles.PopularPlans.section:
            
            let report = UITableViewRowAction(style: UITableViewRowActionStyle(), title: "Report") { action, index in
                DispatchQueue.main.async(execute: { () -> Void in
                    tableView.setEditing(false, animated: true)
                    
                    let cell = tableView.cellForRow(at: indexPath) as! PlansTableViewCell
                    cell.contentView.showSimpleLoading()
                    if let plan = cell.plan {
                        Plango.sharedInstance.reportSpam(Plango.EndPoint.Report.value, planID: plan.id, onCompletion: { (error) in
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
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
        switch indexPath.section {
        case DiscoverTitles.PopularPlans.section:
            return .delete
        default:
            return .none
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DiscoverTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.PlanTypes.rawValue, for: indexPath) as! PlanTypesTableViewCell
            cell.configureWithDataSourceDelegate(dataSourceDelegate: self)
            return cell

        case DiscoverTitles.PlangoCollections.section:
            
            guard let count = plangoFavoriteCollectionsArray?.count else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.TopCollections.rawValue, for: indexPath) as! TopCollectionsTableViewCell
                return cell
            }
            if indexPath.row != count - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: CellID.TopCollectionsMiddle.rawValue, for: indexPath) as! TopCollectionsMiddleTableViewCell
                
                if let collections = self.plangoFavoriteCollectionsArray {
                    let collection = collections[indexPath.row]
                    cell.plangoCollection = collection
                    
                    guard let favorites = self.plangoFavoritesDictionary else { return cell }
                    guard let plans = favorites[collection.name!] else { return cell }
                    cell.plans = plans
                    cell.configure()
                }
                
                return cell
            } else { //last cell in list doesnt need bottom spacing
                let cell = tableView.dequeueReusableCell(withIdentifier: CellID.TopCollections.rawValue, for: indexPath) as! TopCollectionsTableViewCell
                
                if let collections = self.plangoFavoriteCollectionsArray {
                    let collection = collections[indexPath.row]
                    cell.plangoCollection = collection
                    
                    guard let favorites = self.plangoFavoritesDictionary else { return cell }
                    guard let plans = favorites[collection.name!] else { return cell }
                    cell.plans = plans
                    cell.configure()
                }
                
                return cell
            }

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellID.Plans.rawValue, for: indexPath) as! PlansTableViewCell
            if indexPath.section == DiscoverTitles.PopularPlans.section {
                if let plans = self.popularDestinationsPlansArray {
                    cell.plan = plans[indexPath.row]
                }
            }
            cell.configure()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Helper.HeaderHeight.section.value + 4 //slightly taller section header than rest of app
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellID.Header.rawValue) as! DiscoverSectionHeaderView
        
        switch section {
        case DiscoverTitles.TypeCollections.section:
            headerView.headerLabel.text = DiscoverTitles.TypeCollections.rawValue
            
        case DiscoverTitles.PlangoCollections.section:
            headerView.headerLabel.text = DiscoverTitles.PlangoCollections.rawValue
            
        case DiscoverTitles.PopularPlans.section:
            headerView.headerLabel.text = DiscoverTitles.PopularPlans.rawValue
            
            
        default:
            headerView.headerLabel.text = nil
        }

        return headerView
    }
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case DiscoverTitles.TypeCollections.section:
//            return DiscoverTitles.TypeCollections.rawValue
//            
//        case DiscoverTitles.PlangoCollections.section:
//            return DiscoverTitles.PlangoCollections.rawValue
//            
//        case DiscoverTitles.PopularPlans.section:
//            return DiscoverTitles.PopularPlans.rawValue
//            
////        case DiscoverTitles.Favorite.section:
////            return DiscoverTitles.Favorite.rawValue
//        
//        default:
//            return nil
//        }
//    }

}

extension DiscoverTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func fetchTags(_ endPoint: String) {
        Plango.sharedInstance.fetchTags(endPoint) { (receivedTags, error) in
            if let error = error {
                self.printPlangoError(error)
            } else if let tags = receivedTags {
                self.tagsArray = tags
                self.tableView.reloadData()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellID.SpecificType.rawValue, for: indexPath) as! TypeCollectionViewCell
        
        // Configure the cell
        cell.plangoTag = tagsArray[indexPath.row]
        cell.configure()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! TypeCollectionViewCell
        guard let tag = cell.plangoTag else {return}
        
        let parameters = Plango.sharedInstance.buildParameters(nil, maxDuration: nil, tags: [tag], selectedDestinations: nil, user: nil, isJapanSearch: nil)
        
        let plansVC = PlansTableViewController()
        plansVC.plansEndPoint = Plango.EndPoint.FindPlans.rawValue
        plansVC.findPlansParameters = parameters
        plansVC.navigationItem.title = tag.name?.uppercased()
        plansVC.hidesBottomBarWhenPushed = true
        self.show(plansVC, sender: nil)

    }

}
