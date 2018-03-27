//
//  Extensions.swift
//  DoItLive
//
//  Created by Douglas Hewitt on 3/2/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Photos
import MBProgressHUD
import Hue

extension UIBarButtonItem {
    func hide(_ sender: Bool) {
        self.isEnabled = !sender
        if sender == true {
            self.tintColor = UIColor.clear
        } else {
            self.tintColor = UIColor.white
        }
    }
}

extension UINavigationController {
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    //New implementation to prevent autorotate yet allow camera to rotate for proper pictures
    //works across the app because everything is embedded in the UINavigationController
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
}

//let dates = [Date(), Date()]
//let maxDate = dates.isEmpty ? nil : Optional(dates.max())


//extension DateFormatter {
//    
//    func dateFromStringOptional(_ string:String?) -> Date?
//    {
//        guard let value = string else
//        {
//            return nil
//        }
//        
//        return self.date(from: value)
//    }
//}

extension String {
    func trimWhiteSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    //This is necessary because the JSON object actually has timezone data '.SSSZ' which we dont want
    func trimDateTimeZone() -> String {
        return String(self.dropLast(5))
    }
    
    func getLongState() -> String? {
        switch self {
        case State.AL.rawValue:
            return "ALABAMA"
            
        case State.AK.rawValue:
            return "ALASKA"
            
        case State.AS.rawValue:
            return "AMERICAN SAMOA"
            
        case State.AZ.rawValue:
            return "ARIZONA"
            
        case State.AR.rawValue:
            return "ARKANSAS"
            
        case State.CA.rawValue:
            return "CALIFORNIA"
            
        case State.CO.rawValue:
            return "COLORADO"
            
        case State.CT.rawValue:
            return "CONNECTICUT"
            
        case State.DE.rawValue:
            return "DELAWARE"
            
        case State.DC.rawValue:
            return "DISTRICT OF COLUMBIA"
            
        case State.FM.rawValue:
            return "FEDERATED STATES OF MICRONESIA"
            
        case State.FL.rawValue:
            return "FLORIDA"
            
        case State.GA.rawValue:
            return "GEORGIA"
            
        case State.GU.rawValue:
            return "GUAM"
            
        case State.HI.rawValue:
            return "HAWAII"
            
        case State.ID.rawValue:
            return "IDAHO"
            
        case State.IL.rawValue:
            return "ILLINOIS"
            
        case State.IN.rawValue:
            return "INDIANA";
            
        case State.IA.rawValue:
            return "IOWA";
            
        case State.KS.rawValue:
            return "KANSAS";
            
        case State.KY.rawValue:
            return "KENTUCKY";
            
        case State.LA.rawValue:
            return "LOUISIANA";
            
        case State.ME.rawValue:
            return "MAINE";
            
        case State.MH.rawValue:
            return "MARSHALL ISLANDS";
            
        case State.MD.rawValue:
            return "MARYLAND";
            
        case State.MA.rawValue:
            return "MASSACHUSETTS";
            
        case State.MI.rawValue:
            return "MICHIGAN";
            
        case State.MN.rawValue:
            return "MINNESOTA";
            
        case State.MS.rawValue:
            return "MISSISSIPPI";
            
        case State.MO.rawValue:
            return "MISSOURI";
            
        case State.MT.rawValue:
            return "MONTANA";
            
        case State.NE.rawValue:
            return "NEBRASKA";
            
        case State.NV.rawValue:
            return "NEVADA";
            
        case State.NH.rawValue:
            return "NEW HAMPSHIRE";
            
        case State.NJ.rawValue:
            return "NEW JERSEY";
            
        case State.NM.rawValue:
            return "NEW MEXICO";
            
        case State.NY.rawValue:
            return "NEW YORK";
            
        case State.NC.rawValue:
            return "NORTH CAROLINA";
            
        case State.ND.rawValue:
            return "NORTH DAKOTA";
            
        case State.MP.rawValue:
            return "NORTHERN MARIANA ISLANDS";
            
        case State.OH.rawValue:
            return "OHIO";
            
        case State.OK.rawValue:
            return "OKLAHOMA";
            
        case State.OR.rawValue:
            return "OREGON";
            
        case State.PW.rawValue:
            return "PALAU";
            
        case State.PA.rawValue:
            return "PENNSYLVANIA";
            
        case State.PR.rawValue:
            return "PUERTO RICO";
            
        case State.RI.rawValue:
            return "RHODE ISLAND";
            
        case State.SC.rawValue:
            return "SOUTH CAROLINA";
            
        case State.SD.rawValue:
            return "SOUTH DAKOTA";
            
        case State.TN.rawValue:
            return "TENNESSEE";
            
        case State.TX.rawValue:
            return "TEXAS";
            
        case State.UT.rawValue:
            return "UTAH";
            
        case State.VT.rawValue:
            return "VERMONT";
            
        case State.VI.rawValue:
            return "VIRGIN ISLANDS";
            
        case State.VA.rawValue:
            return "VIRGINIA";
            
        case State.WA.rawValue:
            return "WASHINGTON";
            
        case State.WV.rawValue:
            return "WEST VIRGINIA";
            
        case State.WI.rawValue:
            return "WISCONSIN";
            
        case State.WY.rawValue:
            return "WYOMING";
        default:
            return nil
        }
    }
    
    
    func getShortState() -> State? {
        switch (self.uppercased()) {
        case "ALABAMA":
        return State.AL;
        
        case "ALASKA":
        return State.AK;
        
        case "AMERICAN SAMOA":
        return State.AS;
        
        case "ARIZONA":
        return State.AZ;
        
        case "ARKANSAS":
        return State.AR;
        
        case "CALIFORNIA":
        return State.CA;
        
        case "COLORADO":
        return State.CO;
        
        case "CONNECTICUT":
        return State.CT;
        
        case "DELAWARE":
        return State.DE;
        
        case "DISTRICT OF COLUMBIA":
        return State.DC;
        
        case "FEDERATED STATES OF MICRONESIA":
        return State.FM;
        
        case "FLORIDA":
        return State.FL;
        
        case "GEORGIA":
        return State.GA;
        
        case "GUAM":
        return State.GU;
        
        case "HAWAII":
        return State.HI;
        
        case "IDAHO":
        return State.ID;
        
        case "ILLINOIS":
        return State.IL;
        
        case "INDIANA":
        return State.IN;
        
        case "IOWA":
        return State.IA;
        
        case "KANSAS":
        return State.KS;
        
        case "KENTUCKY":
        return State.KY;
        
        case "LOUISIANA":
        return State.LA;
        
        case "MAINE":
        return State.ME;
        
        case "MARSHALL ISLANDS":
        return State.MH;
        
        case "MARYLAND":
        return State.MD;
        
        case "MASSACHUSETTS":
        return State.MA;
        
        case "MICHIGAN":
        return State.MI;
        
        case "MINNESOTA":
        return State.MN;
        
        case "MISSISSIPPI":
        return State.MS;
        
        case "MISSOURI":
        return State.MO;
        
        case "MONTANA":
        return State.MT;
        
        case "NEBRASKA":
        return State.NE;
        
        case "NEVADA":
        return State.NV;
        
        case "NEW HAMPSHIRE":
        return State.NH;
        
        case "NEW JERSEY":
        return State.NJ;
        
        case "NEW MEXICO":
        return State.NM;
        
        case "NEW YORK":
        return State.NY;
        
        case "NORTH CAROLINA":
        return State.NC;
        
        case "NORTH DAKOTA":
        return State.ND;
        
        case "NORTHERN MARIANA ISLANDS":
        return State.MP;
        
        case "OHIO":
        return State.OH;
        
        case "OKLAHOMA":
        return State.OK;
        
        case "OREGON":
        return State.OR;
        
        case "PALAU":
        return State.PW;
        
        case "PENNSYLVANIA":
        return State.PA;
        
        case "PUERTO RICO":
        return State.PR;
        
        case "RHODE ISLAND":
        return State.RI;
        
        case "SOUTH CAROLINA":
        return State.SC;
        
        case "SOUTH DAKOTA":
        return State.SD;
        
        case "TENNESSEE":
        return State.TN;
        
        case "TEXAS":
        return State.TX;
        
        case "UTAH":
        return State.UT;
        
        case "VERMONT":
        return State.VT;
        
        case "VIRGIN ISLANDS":
            return State.VI;
        
        case "VIRGINIA":
            return State.VA;
        
        case "WASHINGTON":
            return State.WA;
            
        case "WEST VIRGINIA":
            return State.WV;
        
        case "WISCONSIN":
            return State.WI;
        
        case "WYOMING":
            return State.WY;
        
        default:
            return nil
        }
    }
    
    func getShortStateCanada() -> StateCanada? {
        switch self.uppercased() {
        case "ALBERTA":
            return StateCanada.AB
        case "BRITISH COLUMBIA":
            return StateCanada.BC
        case "MANITOBA":
            return StateCanada.MB
            case "NEW BRUNSWICK":
            return StateCanada.NB
            case "NEWFOUNDLAND AND LABRADOR":
            return StateCanada.NL
            case "NORTHWEST TERRITORIES":
            return StateCanada.NT
            case "NOVA SCOTIA":
            return StateCanada.NS
            case "NUNAVUT":
            return StateCanada.NU
            case "ONTARIO":
            return StateCanada.ON
            case "PRINCE EDWARD ISLAND":
            return StateCanada.PE
            case "QUEBEC":
            return StateCanada.QC
            case "SASKATCHEWAN":
            return StateCanada.SK
            case "YUKON":
            return StateCanada.YT
        default:
            return nil
        }
    }
    
    func getShortStateAustralia() -> StateAustralia? {
        switch self.uppercased() {
        case "AUSTRALIAN CAPITAL TERRITORY":
            return StateAustralia.ACT
            case "NEW SOUTH WALES":
            return StateAustralia.NSW
            case "VICTORIA":
            return StateAustralia.VIC
            case "QUEENSLAND":
            return StateAustralia.QLD
            case "SOUTH AUSTRALIA":
            return StateAustralia.SA
            case "WESTERN AUSTRALIA":
            return StateAustralia.WA
            case "TASMANIA":
            return StateAustralia.TAS
            case "NORTHERN TERRITORY":
            return StateAustralia.NT
            case "AUSTRALIAN ANTARTIC TERRITORY":
            return StateAustralia.AAT
        default:
            return nil
        }
    }
    
    enum StateCanada: String {
        case AB = "AB"
        case BC = "BC"
        case MB = "MB"
        case NB = "NB"
        case NL = "NL"
        case NT = "NT"
        case NS = "NS"
        case NU = "NU"
        case ON = "ON"
        case PE = "PE"
        case QC = "QC"
        case SK = "SK"
        case YT = "YT"
    }
    
    enum StateAustralia: String {
        case ACT = "ACT"
        case NSW = "NSW"
        case VIC = "VIC"
        case QLD = "QLD"
        case SA = "SA"
        case WA = "WA"
        case TAS = "TAS"
        case NT = "NT"
        case AAT = "AAT"
    }
    
    enum State: String {
        case AL = "AL"
        case AK = "AK"
        case AS = "AS"
        case AZ = "AZ"
        case AR = "AR"
        case CA = "CA"
        case CO = "CO"
        case CT = "CT"
        case DE = "DE"
        case DC = "DC"
        case FM = "FM"
        case FL = "FL"
        case GA = "GA"
        case GU = "GU"
        case HI = "HI"
        case ID = "ID"
        case IL = "IL"
        case IN = "IN"
        case IA = "IA"
        case KS = "KS"
        case KY = "KY"
        case LA = "LA"
        case ME = "ME"
        case MH = "MH"
        case MD = "MD"
        case MA = "MA"
        case MI = "MI"
        case MN = "MN"
        case MS = "MS"
        case MO = "MO"
        case MT = "MT"
        case NE = "NE"
        case NV = "NV"
        case NH = "NH"
        case NJ = "NJ"
        case NM = "NM"
        case NY = "NY"
        case NC = "NC"
        case ND = "ND"
        case MP = "MP"
        case OH = "OH"
        case OK = "OK"
        case OR = "OR"
        case PW = "PW"
        case PA = "PA"
        case PR = "PR"
        case RI = "RI"
        case SC = "SC"
        case SD = "SD"
        case TN = "TN"
        case TX = "TX"
        case UT = "UT"
        case VT = "VT"
        case VI = "VI"
        case VA = "VA"
        case WA = "WA"
        case WV = "WV"
        case WI = "WI"
        case WY = "WY"
    }
}

extension PHAsset {
    
    func getAdjustedSize(_ maxDimension: CGFloat)-> CGSize {
        let width = CGFloat(pixelWidth)
        let height = CGFloat(pixelHeight)
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        
        if height > width {
            newHeight = maxDimension
            newWidth = maxDimension * (width / height )
        } else {
            newWidth = maxDimension
            newHeight = maxDimension * ( height / width )
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}

extension UIImage {
    func getAdjustedSize(_ maxDimension: CGFloat)-> CGSize {
        let height = size.height
        let width = size.width
        var newHeight: CGFloat = 0
        var newWidth: CGFloat = 0
        if height > width {
            newHeight = maxDimension
            newWidth = maxDimension * (width / height )
        } else {
            newWidth = maxDimension
            newHeight = maxDimension * ( height / width )
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}

extension UIImageView {
    fileprivate func setNetworkImage(_ endPoint: String, onCompletion: @escaping (Data?) -> Void) {
        if let cleanURL = URL(string: Plango.sharedInstance.cleanEndPoint(endPoint)) {
            self.af_setImage(withURL: cleanURL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: { (response) in
                if response.result.isSuccess {
                    if let image = response.result.value {
                        let imageData = UIImageJPEGRepresentation(image, 1.0)
                        onCompletion(imageData)
                    }
                }
            })
        }
        
    }
    
    fileprivate func setLocalImage(_ localAvatar: Data?) {
        guard let avatar = localAvatar else {return}
        self.image = UIImage(data: avatar)
        if let compound = self as? CompoundImageView {
            compound.gradientDarkToClear() //set gradient after image is present
        }
    }
    
    func plangoImage(_ object: PlangoObject) {
        if Helper.isConnectedToNetwork() == false {
            self.setLocalImage(object.localAvatar as Data?)
        } else {
            guard let endPoint = object.avatar else {self.backgroundColor = UIColor.plangoBackgroundGray(); return}
            
            self.setNetworkImage(endPoint, onCompletion: { (avatar) in
                if let compound = self as? CompoundImageView {
                    compound.gradientDarkToClear() //set gradient after image is present
                }
                
                object.localAvatar = avatar //save image data to RAM as soon as network request finishes so it will be ready to save to Realm when user taps download plan
            })
        }
    }
}

extension UILabel {
    func dropShadow() {
        self.layer.shadowColor = UIColor.plangoBlack().cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
    }
}

extension UIFont {
    static func plangoHeader() -> UIFont {
        return UIFont(name: "Raleway-Regular", size: 16)!
    }
    static func plangoSearchHeader() -> UIFont {
        return UIFont(name: "Raleway-Light", size: 24)!
    }
    static func plangoSectionHeader() -> UIFont {
        return UIFont(name: "Lato-Bold", size: 16)!
    }
    static func plangoNav() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 18)!
    }
    static func plangoTabBar() -> UIFont {
        return UIFont(name: "Raleway-Light", size: 10)!
    }
    static func plangoBodyBig() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 14)!
    }
    static func plangoBody() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 12)!
    }
    static func plangoButton() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 18)!
    }
    static func plangoPlaceholder() -> UIFont {
        return UIFont(name: "Lato-Regular", size: 10)!
    }
    static func plangoSmallButton() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 14)!
    }
    static func plangoWelcomeTitle() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 30)!
    }
}

extension UIColor {
    static func plangoTeal() -> UIColor {
        return UIColor(hex: "#36C1CD")
    }
    static func plangoOrange() -> UIColor {
//        return UIColor.hex("#FF7916") old orange
        return UIColor(hex: "#FF6A3D")
    }
    static func plangoBackgroundGray() -> UIColor {
        return UIColor(hex: "#f2f2f2")
    }
    static func plangoSectionHeaderGray() -> UIColor {
        return UIColor(hex: "#f9f9f9")
    }
    static func plangoTypeSectionHeaderGray() -> UIColor {
        return UIColor(hex: "#666666")
    }
    static func plangoBlack() -> UIColor {
        return UIColor(hex: "#333333")
    }
    static func plangoText() -> UIColor {
        return UIColor(hex: "#4A4A4A")
    }
    static func plangoTextLight() -> UIColor {
        return UIColor(hex: "#9B9B9B")
    }
    static func plangoCream() -> UIColor {
        return UIColor(hex: "#FDF6EA")
    }
    static func plangoCreamLight() -> UIColor {
        return UIColor(hex: "#EFE5D4")
    }
    static func transparentGray() -> UIColor {
        let color = UIColor.plangoBlack().withAlphaComponent(0.1)
//        let color = UIColor.hex("#000000")
//        color.alpha(0.1)
        return color
    }
}

extension IndexSet {
    
    func aapl_indexPathsFromIndexesWithSection(_ section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(self.count)
        (self as NSIndexSet).enumerate({idx, stop in
            indexPaths.append(IndexPath(item: idx, section: section))
        })
        return indexPaths
    }
    
}

extension UIViewController {
    
    func displayMapForExperiences(_ experiences: [Experience], title: String?, download: Bool) {
        let mapVC = MapViewController()
        mapVC.experiences = experiences
        mapVC.shouldDownload = download
        if let title = title {
            mapVC.navigationItem.title = title.uppercased()
        } else {
            mapVC.navigationItem.title = "Map".uppercased()
        }
        show(mapVC, sender: nil)
    }
    
    func displayMapForPlan(_ plan: Plan, download: Bool) {
        let mapVC = MapViewController()
        mapVC.plan = plan
        mapVC.experiences = plan.experiences
        mapVC.shouldDownload = download
        if let title = plan.name {
            mapVC.navigationItem.title = title.uppercased()
        } else {
            mapVC.navigationItem.title = "MAP"
        }
        show(mapVC, sender: nil)
    }
}

extension UITableView {
    // breaks tableview ability to recognize select
//    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.endEditing(true)
//    }
}

extension UICollectionView {
//    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.endEditing(true)
//    }
    
    //### returns empty Array, rather than nil, when no elements in rect.
    func aapl_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        guard let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElements(in: rect)
            else {return []}
        let indexPaths = allLayoutAttributes.map{$0.indexPath}
        return indexPaths
    }
    
}

extension UICollectionViewFlowLayout {
    func cellsFitAcrossScreen(_ numberOfCells: Int, labelHeight: CGFloat, cellShapeRatio: CGFloat) -> CGSize {
        //using information from flowLayout get proper spacing for cells across entire screen
        let insideMargin = self.minimumInteritemSpacing
        let outsideMargins = self.sectionInset.left + self.sectionInset.right
        let numberOfDivisions: Int = numberOfCells - 1
        let subtractionForMargins: CGFloat = insideMargin * CGFloat(numberOfDivisions) + outsideMargins
        
        let fittedWidth = (UIScreen.main.bounds.width - subtractionForMargins) / CGFloat(numberOfCells)
        let ratioHeight = fittedWidth * cellShapeRatio
        
        return CGSize(width: fittedWidth, height: ratioHeight + labelHeight)
    }
    
    func widescreenCards() -> CGSize {
        let cellWidth = UIScreen.main.bounds.size.width * 0.6
        let cellHeight = cellWidth * (9/16)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension UIResponder {
    func printPlangoError(_ error: PlangoError) {
        if let status = error.statusCode, let message = error.message {
            print("In \(self) Status Code: \(status) Message: \(message)")
        }
    }
    
    func printError(_ error: Error) {
        print("In \(self) Failure Reason: \(error.localizedDescription)")
    }
}

extension UIView {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.endEditing(true)
    }
    
    func fitViewConstraintsTo(_ view: UIView) {
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
    func fitLoginButtons(_ controller: UIViewController) {
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.widthAnchor.constraint(equalToConstant: controller.view.frame.width - 16).isActive = true
    }
    
    func fitLoginLabels() {
        self.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    func makeCircle() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
    func copyView() -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as AnyObject
    }
    
    func makeRoundCorners(_ divider: Int) {
        self.layer.cornerRadius = self.frame.size.width / CGFloat(divider)
        self.clipsToBounds = true
    }
    
    func addSelectionLayer() {
        let select = SelectionLayer()
        select.frame = self.bounds
        select.addBadge()
        self.layer.addSublayer(select)
    }
    
    
    // MARK: Toast via MBProgressHUD
    func quickToast(_ title: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = title
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UIView.hudTimerDidFire(_:)), userInfo: hud, repeats: false)
        })
    }
    
    func detailToast(_ title: String, details: String) {
        DispatchQueue.main.async(execute: { () -> Void in
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = MBProgressHUDMode.text
            hud.label.text = title
            hud.detailsLabel.text = details
            Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(UIView.hudTimerDidFire(_:)), userInfo: hud, repeats: false)
        })
    }
    
    func imageToast(_ title: String?, image: UIImage, notify: Bool) {
        DispatchQueue.main.async(execute: { () -> Void in
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = MBProgressHUDMode.customView
            hud.label.text = title
            hud.customView = UIImageView(image: image)
            
            if notify == true {
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(UIView.hudTimerDidFireAndNotify(_:)), userInfo: hud, repeats: false)
            } else {
                Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(UIView.hudTimerDidFire(_:)), userInfo: hud, repeats: false)
            }
            
        })
    }
    
    func showSimpleLoading() {
        DispatchQueue.main.async(execute: { () -> Void in
            MBProgressHUD.showAdded(to: self, animated: true)
        })
    }
    
    func hideSimpleLoading() {
        DispatchQueue.main.async(execute: { () -> Void in
            MBProgressHUD.hide(for: self, animated: true)
        })
    }
    
    func showPieLoading() -> MBProgressHUD {
        let hud = MBProgressHUD(view: self)
        hud.mode = MBProgressHUDMode.determinate
        DispatchQueue.main.async(execute: { () -> Void in
            self.addSubview(hud)
            hud.show(animated: true)
        })
        return hud
    }
    
    func hidePieLoading(_ hud: MBProgressHUD, percent: Float) {
        DispatchQueue.main.async(execute: { () -> Void in
            hud.progress = percent
            if hud.progress == 1.0 {
                hud.hide(animated: true)
            }
        })
    }
    
    @objc func hudTimerDidFire(_ sender: Timer) {
        if let hud = sender.userInfo as? MBProgressHUD {
            DispatchQueue.main.async(execute: { () -> Void in
                hud.hide(animated: true)
            })
        }
        sender.invalidate()
    }
    
    @objc func hudTimerDidFireAndNotify(_ sender: Timer) {
        if let hud = sender.userInfo as? MBProgressHUD {
            DispatchQueue.main.async(execute: { () -> Void in
                hud.hide(animated: true)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Notify.Timer.rawValue), object: nil, userInfo: nil)
            })

        }
        sender.invalidate()
    }
}
