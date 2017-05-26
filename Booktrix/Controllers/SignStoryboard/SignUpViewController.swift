//
//  SignUpViewController.swift
//  Booktrix
//
//  Created by Impresyjna on 14.05.2017.
//  Copyright © 2017 Impresyjna. All rights reserved.
//

import UIKit

final class SignUpViewController: UIViewController {
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        prepareFields()
    }
    
    func prepareFields() {
        loginTextField.prepareForView()
        passwordTextField.prepareForView()
        passwordConfirmationTextField.prepareForView()
        nameTextField.prepareForView()
        surnameTextField.prepareForView()
        emailTextField.prepareForView()
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        viewModel.form.login = loginTextField.text ?? ""
        viewModel.form.password = passwordTextField.text ?? ""
        viewModel.form.confirmation = passwordConfirmationTextField.text ?? ""
        viewModel.form.name = nameTextField.text ?? ""
        viewModel.form.surname = surnameTextField.text ?? ""
        viewModel.form.email = emailTextField.text ?? ""
    }
    
    @IBAction func openSignInView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        showHud()
        viewModel.register { [weak self] (result) in
            self?.hideHud()
            switch result {
            case .success:
                self?.setNewRoot(controller: Wireframe.RootView().root())
            case .failure(let error as FormError):
                self?.showError(title: nil, subtitle: error.message, dismissDelay: 3.0)
            case .failure(let error):
                self?.showWarning(title: nil, subtitle: error.errorMessage, dismissDelay: 3.0)
            }
        }
    }
    
    @IBAction func navigateThroughInputs(_ sender: UITextField) {
        let nextTag = sender.tag + 1;
        jump(toNextTextField: sender, withTag: nextTag)
    }
    
}
