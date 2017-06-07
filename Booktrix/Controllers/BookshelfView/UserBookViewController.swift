//
//  BookViewController.swift
//  Booktrix
//
//  Created by Impresyjna on 04.06.2017.
//  Copyright © 2017 Impresyjna. All rights reserved.
//

import UIKit

protocol UserBookProtocol {
    func scanFinished(book: Book)
}

class UserBookViewController: UIViewController, UserBookProtocol {
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!

    var viewModel: UserBookViewModel!
    
    lazy var descriptionController : BookDescriptionViewController? = {
        return Wireframe.UserBookView().description()
    }()
    
    lazy var detailsController : BookDetailsViewController? = {
        return Wireframe.UserBookView().details()
    }()
    
    private var activeController : UIViewController? {
        willSet {
            self.activeController?.view.removeFromSuperview()
            self.activeController?.removeFromParentViewController()
        }
        didSet {
            guard let newActive = self.activeController else { return }
            
            self.contentContainer.addSubview(newActive.view)
            
            let views : [String : UIView] = ["view": newActive.view]
            
            newActive.view.translatesAutoresizingMaskIntoConstraints = false
            
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
            
            NSLayoutConstraint.activate(constraints)
            
            addChildViewController(newActive)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizedString.save, style: .plain, target: self, action: #selector(save))
        
        prepareFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switchToTabAtIndex(index: 0)
    }
    
    func prepareFields() {
        titleTextField.innerViewsLook()
        authorTextField.innerViewsLook()
        
        titleTextField.text = viewModel.form.title
        authorTextField.text = viewModel.form.author
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        viewModel.form.title = titleTextField.text ?? ""
        viewModel.form.author = authorTextField.text ?? ""
    }
    
    func save() {
        self.showHud()
        viewModel.save { [weak self] (result) in
            self?.hideHud()
            switch result {
            case .success:
                self?.dismissView()
            case .failure(let error as FormError):
                self?.showError(title: nil, subtitle: error.message, dismissDelay: 3.0)
            case .failure(let error):
                self?.showWarning(title: nil, subtitle: error.errorMessage, dismissDelay: 3.0)
            }
        }
    }
    
    @IBAction func scanOpenAction(_ sender: Any) {
        let vc = Wireframe.UserBookView().scanner()
        vc.viewModel = ScannerViewModel(self)
        pushViewFromStoryboard(controller: vc)
    }
    
    func scanFinished(book: Book) {
        viewModel.fillUserBookForm(book: book)
    }
    
    @IBAction func changeTab(_ sender: Any) {
        switchToTabAtIndex(index: segmentedControl.selectedSegmentIndex)
    }
    
    private func switchToTabAtIndex(index: Int) {
        self.activeController = index == 0 ? self.descriptionController : self.detailsController
        segmentedControl.selectedSegmentIndex = index
    }

    
    //TODO: 
    /* 
     * Zmniejszenie zdjęcia na mniejsze iPhony
     * Akcja create
     * Akcja update
     * Wypełnianie danymi
     * Odpalenie ekranu skanowania
     * Podłaczenie otrzymanych danych do forma
     * Przełączanie po textfieldach na guzik next
     */
    
}
