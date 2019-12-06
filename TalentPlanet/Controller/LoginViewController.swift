//
//  LoginViewController.swift
//  TalentPlanet
//
//  Created by 민권홍 on 24/09/2019.
//  Copyright © 2019 민권홍. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    // MARK: - Variables
    let gradientLayer = CAGradientLayer()
    @IBOutlet var mainView: UIView!
    @IBOutlet var btnJoinUs: UIButton!
    @IBOutlet var btnLogin: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //mainView.backgroundColor = UIColor(red: 77.0/255.0, green: 88.0/255.0, blue: 104.0/255.0, alpha: 1)
        
        btnJoinUs.backgroundColor = UIColor.white
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    // MARK: - Init
    override func viewDidAppear(_ animated: Bool) {
        // 1
           btnLogin.backgroundColor = UIColor.green
        
           // 2
           gradientLayer.frame = btnLogin.bounds
        
           // 3
        let middleColor = UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        let startColor = UIColor(red: 255.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1.0).cgColor
        let endColor = UIColor(red: 255.0/255.0, green: 195.0/255.0, blue: 94.0/255.0, alpha: 1.0).cgColor
           gradientLayer.colors = [startColor, middleColor, endColor]
        
           // 4
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.cornerRadius = 5;

        btnLogin.layer.insertSublayer(gradientLayer, at: 0)
        //navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Functions
    @IBAction func btnLogin(_ sender: Any) {
       // self.performSegue(withIdentifier: "segueLogin", sender:self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
