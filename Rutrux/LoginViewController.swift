//
//  LoginViewController.swift
//  Rutrux
//
//  Created by carlos pumayalla on 11/22/21.
//  Copyright © 2021 empresa. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var espacioStack: NSLayoutConstraint!
    @IBOutlet weak var numeroStack: UIStackView!
    @IBOutlet weak var codigoStack: UIStackView!
    @IBOutlet weak var numeroTxt: UITextField!
    @IBOutlet weak var codigoTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codigoStack.isHidden = true
    }
    
    var verification_id : String? = nil
    @IBAction func enviarTapped(_ sender: Any) {
        if numeroTxt.text!.isEmpty{
            let alertaVC = UIAlertController(title: "Error", message: "Ingresa tu número de teléfono" , preferredStyle: .alert)
            let btnOK = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertaVC.addAction(btnOK)
            self.present(alertaVC, animated: true, completion: nil)
        }else{
            PhoneAuthProvider.provider().verifyPhoneNumber(numeroTxt.text!, uiDelegate: nil, completion: { verificationID, error in
                if (error != nil){
                    return
                }else{
                    self.verification_id = verificationID
                    self.numeroStack.isHidden = true
                    self.espacioStack.constant = 15
                    self.codigoStack.isHidden = false
                }
            })
        }
    }
    @IBAction func verificarTapped(_ sender: Any) {
        if codigoTxt.text!.isEmpty {
            let alertaVC = UIAlertController(title: "Error", message: "Ingrese el código que se le envió" , preferredStyle: .alert)
            let btnOK = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertaVC.addAction(btnOK)
            self.present(alertaVC, animated: true, completion: nil)
        }else{
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verification_id!, verificationCode: codigoTxt.text!)
            Auth.auth().signIn(with: credential, completion: {authData, error in
                if (error != nil){
                    print(error.debugDescription)
                }else{
                    print("autenticación completa")
                    self.performSegue(withIdentifier: "iniciarSesionSegue", sender: nil)
                }
            })
        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        if user != nil {
            print(user?.phoneNumber as String? as Any)
            self.performSegue(withIdentifier: "iniciarSesionSegue", sender: nil)
        }else{
            print("No hay usuario logeado")
            return
        }
    }
}
