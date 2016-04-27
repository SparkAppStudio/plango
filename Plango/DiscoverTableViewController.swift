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
        case TypeCollections = "Popular Plans by Type"
        case TopCollections = "Top Collections"
        case Popular = "Popular Plans"
        case Favorite = "Favorite Destinations"
        
        var section: Int {
            switch self {
            case .TypeCollections: return 0
            case .TopCollections: return 1
            case .Popular: return 2
            case .Favorite: return 3
            }
        }
        
        static var count: Int {
            return DiscoverTitles.Favorite.hashValue + 1
        }
    }
    
    lazy var tagsArray = [Tag]()
    
    lazy var logoutBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "LOGOUT", style: .Plain, target: self, action: #selector(DiscoverTableViewController.logout))
        return button
    }()
    
    func logout() {
        self.showViewController(LoginTableViewController(), sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchTags(Plango.EndPoint.AllTags.rawValue)
        
        self.tableView.backgroundColor = UIColor.plangoCream()
        
        self.navigationItem.rightBarButtonItem = logoutBarButton
        
        let plansNib = UINib(nibName: "PlansCell", bundle: nil)
        self.tableView.registerNib(plansNib, forCellReuseIdentifier: CellID.Plans.rawValue)
        
        let topCollectionsNib = UINib(nibName: "TopCollectionsCell", bundle: nil)
        self.tableView.registerNib(topCollectionsNib, forCellReuseIdentifier: CellID.TopCollections.rawValue)
        
        self.tableView.registerClass(PlanTypesTableViewCell.self, forCellReuseIdentifier: CellID.PlanTypes.rawValue)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section:
            return Helper.CellHeight.superWide.value
        case DiscoverTitles.TopCollections.section:
            return Helper.CellHeight.superWide.value
        default:
            return Helper.CellHeight.plans.value
        }
    }
    
    
    // MARK: - Table view Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.showViewController(PlansTableViewController(), sender: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return DiscoverTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case DiscoverTitles.TypeCollections.section:
            return 1
        default:
            return 3
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case DiscoverTitles.TypeCollections.section:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.PlanTypes.rawValue, forIndexPath: indexPath) as! PlanTypesTableViewCell
            cell.configureWithDataSourceDelegate(dataSourceDelegate: self)
            return cell

        case DiscoverTitles.TopCollections.section:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.TopCollections.rawValue, forIndexPath: indexPath) as! TopCollectionsTableViewCell
            return cell

        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(CellID.Plans.rawValue, forIndexPath: indexPath) as! PlansTableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case DiscoverTitles.TypeCollections.section:
            return DiscoverTitles.TypeCollections.rawValue
            
        case DiscoverTitles.TopCollections.section:
            return DiscoverTitles.TopCollections.rawValue
            
        case DiscoverTitles.Popular.section:
            return DiscoverTitles.Popular.rawValue
            
        case DiscoverTitles.Favorite.section:
            return DiscoverTitles.Favorite.rawValue
        
        default:
            return nil
        }
    }

}

extension DiscoverTableViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func fetchTags(endPoint: String) {
        Plango.sharedInstance.fetchTags(endPoint) { (receivedTags, error) in
            if let error = error {
                print(error.description)
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

}