//
//  HamburgerContainerViewController.swift
//  Speede
//
//  Created by Hrishikesh Devhare on 22/09/20.
//  Copyright © 2020 Hrishikesh Devhare. All rights reserved.
//

import UIKit

class HamburgerMenuViewController : UIViewController {
    weak var delegate : menuSelectionHandler?
}

protocol menuSelectionHandler : UIViewController {
   func selectMenuAt(index : Int)
}


class HamburgerContainerViewController: HamburgerMenuViewController {

    //MARK:- Outlets
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayLeadingConstraint: NSLayoutConstraint!
    
    //MARK:- Properties
    
    var menuExpanded : Bool = false {
        willSet (newValue) {
        
            UIView.animate(withDuration: 0.2, animations: {
            if newValue {
                self.leadingConstraint.constant = -(self.view.frame.width) * 0.2
                self.overlayLeadingConstraint.constant = 0.0
                self.overlayView.alpha = 0.35
            }
            else {
                self.leadingConstraint.constant = -(self.view.frame.width)
                self.overlayLeadingConstraint.constant = -(self.view.frame.width)
                self.overlayView.alpha = 0.0
            }
                self.view.layoutIfNeeded()
            })
        }
    }
    let menuVC : UIViewController
    let childenVC : [UIViewController]
    var currentActiveVc = UIViewController()
    
    //MARK:- Initialisers
    required init?(coder aDecoder: NSCoder) {
        self.menuVC = UIViewController()
        self.childenVC = [UIViewController()]
        super.init(coder: aDecoder)
    }
    
    init(menuVC: HamburgerMenuViewController, childenVC:[UIViewController])
    {
        self.menuVC = menuVC
        
        self.childenVC = childenVC
        self.currentActiveVc = childenVC.first ?? UIViewController()
        super.init(nibName: nil, bundle: nil)
        menuVC.delegate = self
    }
    
    //MARK:- View Controller Life Cycle Method

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetup()
        configureGestures()
    }
    
    //MARK:- UI Setup Methods
    fileprivate func initialUISetup() {
        self.add(viewController: menuVC, to: menuView)
        self.add(viewController: currentActiveVc, to: baseView)
        leadingConstraint.constant = -(self.view.frame.width)
        overlayLeadingConstraint.constant = -(self.view.frame.width)
        overlayView.alpha = 0.0
    }
    
    fileprivate func configureGestures() {
      let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
      swipeLeftGesture.direction = .left
      overlayView.addGestureRecognizer(swipeLeftGesture)
      
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOverlay))
      overlayView.addGestureRecognizer(tapGesture)
    }
    
    //MARK:-  Target Action Methods
    @objc fileprivate func didSwipeLeft() {
        menuExpanded.toggle()
    }
    
    @objc fileprivate func didTapOverlay() {
        menuExpanded.toggle()
    }
    
    @IBAction func MenuButtonTapped(_ sender: Any) {
        menuExpanded.toggle()
    }
    
    //MARK:- Methods to add/Remove Child VCs
    private func add(viewController: UIViewController , to childView: UIView){
        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        childView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = childView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }


    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }

}

extension HamburgerContainerViewController : menuSelectionHandler {
    func selectMenuAt(index: Int) {
        
        let newViewController = childenVC[index]
        let oldViewController = currentActiveVc
        self.add(viewController:newViewController , to: baseView)
        
        self.transition(from: currentActiveVc,
                        to: newViewController,
                        duration: 0.1,
                        options: [] ,
                        animations:nil,
                        completion: { (completed) in
                            self.currentActiveVc = newViewController
                            self.menuExpanded.toggle()
                            self.remove(asChildViewController: oldViewController)
                        })
    }
}



