//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        
        TMDBClient.getRequestToken(completion: handleResponseToken(success:error:))
        
    }
    
    @IBAction func loginViaWebsiteTapped() {
        
        
        TMDBClient.getRequestToken { (sucess, error) in
            
            
            if sucess {
                
                DispatchQueue.main.async {
                 UIApplication.shared.open(TMDBClient.Endpoints.webAuth.url, options: [:], completionHandler: nil)
                }
                
            }
            
        }
        
       
    }
    
    
    func handleSessionResponse(success : Bool , error : Error?) {
     
        print(error)
        if success {
            
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
           
            
        }
        
    }
    
    
    
    
    func handleResponseToken(success : Bool , error : Error? ) {
        
        if success {
            
                
                TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completion: self.handleLoginResponse(success:error:))
                
            
        }
    }
    
    
    
    func handleLoginResponse(success : Bool , error : Error?) {
        
        if success  {
            
            TMDBClient.createSessionId(completion: self.handleSessionResponse(success:error:))
            
        }
        
    }
    
    
    
    
}
