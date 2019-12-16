//
//  HomeViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 14/10/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import DropDown

// MARK: - Talent Object
class TalentObjectHome {
    var cateCode:String
    var title:String
    
    init() {
        cateCode = ""
        title = ""
    }
    
    init (cateCode:String, title:String){
        self.cateCode = cateCode
        self.title = title
    }
    
    public func setCateCode(_ cateCode:String){
        self.cateCode = cateCode
    }
    
    public func getCateCode() -> String{
        return self.cateCode
    }
    
    public func setTitle(_ title:String){
        self.title = title
    }
    
    public func getTitle() -> String{
        return self.title
    }
}

class HomeViewController: UIViewController {
    
    // MARK: - Variables
    // stack view 담을 배열
    var mainButtons:[UIStackView] = []
    var talentFlag = "Y"
    var dropDown: DropDown?
    var delegate: SendTalentFlagDelegate?
    
    // 메인 뷰 Stack View 정의
    @IBOutlet var svCareer: UIStackView!
    @IBOutlet var svMoney: UIStackView!
    @IBOutlet var svLiving: UIStackView!
    @IBOutlet var svTravel: UIStackView!
    @IBOutlet var svStudy: UIStackView!
    @IBOutlet var svVolunteer: UIStackView!
    @IBOutlet var svIt: UIStackView!
    @IBOutlet var svCulture: UIStackView!
    @IBOutlet var svSports: UIStackView!
    @IBOutlet var svMusic: UIStackView!
    @IBOutlet var svCamera: UIStackView!
    @IBOutlet var svBeauty: UIStackView!
    @IBOutlet var svDesign: UIStackView!
    @IBOutlet var svGame: UIStackView!
    @IBOutlet var svSearch: UIStackView!
    @IBOutlet var talentListView: UIView!
    @IBOutlet var ivSearch: UIImageView!
    @IBOutlet var ivAddCate: UIImageView!
    
    @IBOutlet var lbBannerTop: UILabel!
    @IBOutlet var lbBannerBottom: UILabel!
    @IBOutlet var btnBanner: UIButton!
    @IBOutlet var addCateView: UIView!
    
    @IBOutlet var naviItem: UINavigationItem!
    @IBOutlet var btnTitle: UIButton!
    // 카테고리 관련 객체를 담을 배열
    var talentObjectList:[TalentObjectHome] = []
    
    // 재능 리스트로 넘어갈 시 보낼 파라미터
    var selectedTitle = ""
    var selectedCateCode = ""
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // 유저 기본 정보 저장
        let defaults = UserDefaults.standard
        defaults.set("mkh9012@naver.co", forKey: "userID")
        
        dropDown = DropDown()
        
        self.navigationController?.navigationBar.topItem?.hidesBackButton = true
        initNavigationItemTitleView(title: "Teacher Planet")
        
        dropDown?.dataSource = ["Teacher Planet", "Student Planet"]
        dropDown?.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btnTitle.setTitle(item, for: .normal)
            self.initNavigationItemTitleView(title: item)
            let tabbar = self.tabBarController as! BaseTabBarController
            if index == 0 {
                self.talentListView.backgroundColor = UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0)
                self.talentFlag = "Y"
                tabbar.talentFlag = "Y"
                self.changeCateViewColor(color: .white)
                self.ivSearch.image = UIImage(named: "icon_search_teacher.png")
                self.ivAddCate.image = UIImage(named: "icon_addcate_teacher.png")
                
                self.lbBannerTop.text = "당산의 재능을 기다립니다."
                self.lbBannerBottom.text = "지금 바로 학생들을 찾아보세요!"
                self.btnBanner.setTitle("Teacher 재능 등록하기 >", for: .normal)
            } else {
                self.talentListView.backgroundColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0)
                self.talentFlag = "N"
                tabbar.talentFlag = "N"
                self.changeCateViewColor(color: .black)
                self.ivSearch.image = UIImage(named: "icon_search_student.png")
                self.ivAddCate.image = UIImage(named: "icon_addcate_student.png")
                
                self.lbBannerTop.text = "당신의 배움을 응원합니다."
                self.lbBannerBottom.text = "지금 바로 선생님을 찾아보세요!"
                self.btnBanner.setTitle("Student 재능 등록하기 >", for: .normal)
            }

        }
        mainButtons.append(svCareer)
        mainButtons.append(svMoney)
        mainButtons.append(svLiving)
        mainButtons.append(svTravel)
        mainButtons.append(svStudy)
        mainButtons.append(svVolunteer)
        mainButtons.append(svIt)
        mainButtons.append(svCulture)
        mainButtons.append(svSports)
        mainButtons.append(svMusic)
        mainButtons.append(svCamera)
        mainButtons.append(svBeauty)
        mainButtons.append(svDesign)
        mainButtons.append(svGame)
        mainButtons.append(svSearch)
        
        // 카테고리 정보 정의
        talentObjectList.append(TalentObjectHome(cateCode: "1", title: "취업"))
        talentObjectList.append(TalentObjectHome(cateCode: "3", title: "재테크"))
        talentObjectList.append(TalentObjectHome(cateCode: "9", title: "생활"))
        talentObjectList.append(TalentObjectHome(cateCode: "12", title: "여행"))
        talentObjectList.append(TalentObjectHome(cateCode: "2", title: "학습"))
        talentObjectList.append(TalentObjectHome(cateCode: "11", title: "봉사활동"))
        talentObjectList.append(TalentObjectHome(cateCode: "4", title: "IT"))
        talentObjectList.append(TalentObjectHome(cateCode: "13", title: "문화"))
        talentObjectList.append(TalentObjectHome(cateCode: "8", title: "운동"))
        talentObjectList.append(TalentObjectHome(cateCode: "6", title: "음악"))
        talentObjectList.append(TalentObjectHome(cateCode: "5", title: "사진"))
        talentObjectList.append(TalentObjectHome(cateCode: "10", title: "뷰티"))
        talentObjectList.append(TalentObjectHome(cateCode: "7", title: "미술"))
        talentObjectList.append(TalentObjectHome(cateCode: "14", title: "게임"))
        
        var index = 0
        for button:UIStackView in mainButtons {
            
            button.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(goCatePage(_:)))

            if(index < talentObjectList.count){

                button.tag = index
                button.addGestureRecognizer(gesture)
                index = index + 1
            }
        }
        delegate?.sendData(talentFlag: self.talentFlag)
    }
    
    
    // MARK: - Functions
    @objc func goCatePage(_ sender: UITapGestureRecognizer){
        if let index = sender.view?.tag as? Int {
            selectedTitle = talentObjectList[index].getTitle()
            selectedCateCode = talentObjectList[index].getCateCode()
            self.performSegue(withIdentifier: "segueTalentList", sender: nil)
        }
    }
    
    @objc func dropDownButton(){
        print("btn clicked")
        dropDown?.show()
    }
    
    func changeCateViewColor(color: UIColor){
        for button:UIStackView in mainButtons {
            let subView = button.arrangedSubviews[0]
            let subImgView = subView.allSubViewsOf(type: UIImageView.self)[0] as UIImageView
            
            let subLabel = button.arrangedSubviews[1] as! UILabel

            subLabel.textColor = color
            subImgView.image = subImgView.image?.maskWithColor(color: color)
        }
        
        let bottomLabels = addCateView.allSubViewsOf(type: UILabel.self)
        
        for label: UILabel in bottomLabels {
            label.textColor = color
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier! {
        case "segueTalentList":
            print("1q2w3e")
            let talentShareViewController = segue.destination as! TalentShareViewController
            talentShareViewController.cateCode = selectedCateCode
            talentShareViewController.titleName = selectedTitle
            talentShareViewController.talentFlag = self.talentFlag
            break
        case "segueTalentRegist":
            let talentRegistViewController = segue.destination as! TalentRegistViewController
            break
        case "segueMenu":
            let sideMenuViewController = segue.destination as! SideMenuViewController
            sideMenuViewController.talentFlag = self.talentFlag
            print("asdfasdf")
            break
        default:
            return
        }
        
    }
    
    private func initNavigationItemTitleView(title: String) {
        let titleView = UILabel()
        titleView.text = title
        titleView.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        
        dropDown?.anchorView = titleView // UIView or UIBarButtonItem
        //dropDown?.bottomOffset = CGPoint(x: 0, y:(dropDown?.anchorView?.plainView.bounds.height)!)
        // The list of items to display. Can be changed dynamically
        
        self.navigationController?.navigationBar.topItem?.titleView = titleView
        if title == "Teacher Planet" {
            titleView.textColor = UIColor(red: 40.0/255.0, green: 54.0/255.0, blue: 74.0/255.0, alpha: 1.0)
        } else {
            titleView.textColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0)
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dropDownButton))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(recognizer)
        
    }
    

}

extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }

}

extension UIView {

    /** This is the function to get subViews of a view of a particular type
*/
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }


/** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
        func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
            var all = [T]()
            func getSubview(view: UIView) {
                if let aView = view as? T{
                all.append(aView)
                }
                guard view.subviews.count>0 else { return }
                view.subviews.forEach{ getSubview(view: $0) }
            }
            getSubview(view: self)
            return all
        }
    }

protocol SendTalentFlagDelegate {
    func sendData(talentFlag: String)
}
