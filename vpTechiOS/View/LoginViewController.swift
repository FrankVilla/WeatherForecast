//
//  LoginViewController.swift
//  vpTechiOS
//
//  Created by KOVIGROUP on 22/03/2023.
//


import UIKit

class LoginViewController: UIViewController, UINavigationBarDelegate {
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        navigationController?.navigationBar.delegate = self
        navigationController?.navigationBar.delegate = nil
    }
}
