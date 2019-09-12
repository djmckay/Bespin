//
//  LoginViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit

class LoginViewController: UIViewController, LoginControllerDelegate {

    let cellId = "cellId"
    let loginCellId = "loginCellId"
    
    // constraint variables used for animation
    var pageControlBottomAnchor: NSLayoutConstraint?
    var skipButtonBottomAnchor: NSLayoutConstraint?
    var nextButtonBottomAnchor: NSLayoutConstraint?
    
    let pages: [Page] = {
        let firstPage = Page(title: "Bespin Email Templates for Devs", message: "Engage with your clients in a new way.", imageName: "Page1")
        let secondPage = Page(title: "Email with Your Clients", message: "Stay in touch with your clients on the go!", imageName: "Page2")
        
        return [firstPage, secondPage]
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        return cv
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.numberOfPages = self.pages.count + 1
        pc.currentPageIndicatorTintColor = UIColor.rgb(41, 128, 185)
        return pc
    }()
    
    lazy var skipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Skip", for: .normal)
        btn.setTitleColor(UIColor.rgb(41, 128, 185), for: .normal)
        btn.addTarget(self, action: #selector(skipPages), for: .touchUpInside)
        return btn
    }()
    
    lazy var nextButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Next", for: .normal)
        btn.setTitleColor(UIColor.rgb(41, 128, 185), for: .normal)
        btn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeKeyboardNotifications()
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        skipButtonBottomAnchor = skipButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 16, rightConstant: 0, widthConstant: 60, heightConstant: 50)[2]
        
        nextButtonBottomAnchor = nextButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 16, rightConstant: 10, widthConstant: 60, heightConstant: 50)[2]
        
        collectionView.anchorToTop(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        registerCells()
        
        pageControlBottomAnchor = pageControl.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)[1]
        
        if UserDefaultsManager.session != nil {
            LoginManager.sharedInstance.checkSession(complete: { (status, error) in
                if status {
                    UserDefaultsManager.isLoggedIn = true
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @objc func skipPages() {
        let indexPath = IndexPath(item: pages.count, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage = pages.count
        animatePage()
    }
    
    
    @objc func nextPage() {
        if pageControl.currentPage == pages.count { return }
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
        
        // take care of the last page animation
        animatePage()
    }
    
    
    func animatePage() {
        if pageControl.currentPage == pages.count {
            moveConstraintsOffScreen()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    
    fileprivate func moveConstraintsOffScreen() {
        pageControlBottomAnchor?.constant = 50
        skipButtonBottomAnchor?.constant = 0
        nextButtonBottomAnchor?.constant = 0
    }
    
    
    fileprivate func moveConstraintsOnScreen() {
        pageControlBottomAnchor?.constant = 0
        skipButtonBottomAnchor?.constant = 50
        nextButtonBottomAnchor?.constant = 50
    }
    
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    
    @objc func keyboardShow() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let y: CGFloat = UIDevice.current.orientation.isLandscape ? -110 : -70
            self.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    
    @objc func keyboardHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        pageControl.currentPage = pageNumber
        
        // if we are on the last page of the Onboarding
        if pageNumber == pages.count {
            moveConstraintsOffScreen()
        } else {
            moveConstraintsOnScreen()
        }
        
        // animate layout if needed
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(LoginCell.self, forCellWithReuseIdentifier: loginCellId)
    }
    
    
    func finishedLogIn(_ username: String?, _ password: String?) {
        
        if let username = username, let password = password, username.count > 0, password.count > 0 {
            let pattern = "[^@]+@[a-zA-Z0-9-.]+\\.[a-zA-Z]{2,}"
            
            var regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: pattern, options: [])
            } catch let error {
                print("regex failed for \(pattern), error \(error)")
            }
            
            let matches = regex!.matches(in: username, options: .withTransparentBounds, range: NSMakeRange(0, username.count))
            
            if true || matches.count != 0 {
                attemptLogin(username, password)
            } else {
                
                BespinSimpleAlert.show("Please enter a valid email.", disableUI: false)
            }
            
            
        } else {
           
            BespinSimpleAlert.show("Please enter an email and password.", disableUI: false)
        }
        
    }
    
    func attemptLogin(_ username: String, _ password: String) {
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        guard let mainNavigationController = rootViewController as? MainNavigationControllerViewController else { return }
        
        mainNavigationController.viewControllers = [ViewController()]
        BepsinActivityIndicator.show("Logging In...", disableUI: false)
        LoginManager.sharedInstance.login(username: username, password: password) { (result) in
            switch result {
                
            case .success(_):
                UserDefaultsManager.isLoggedIn = true
                BepsinActivityIndicator.hide(true, animated: true)
                self.dismiss(animated: true, completion: nil)
            case .failure(let error):
                DispatchQueue.main.async {
                    BepsinActivityIndicator.hide(false, animated: true)
                    BespinSimpleAlert.show("Invalid Login", disableUI: false)
                }
                
            }
            

        }
        
    }
    
    
    
    func createUser(_ username: String?, _ password: String?) {
        if let username = username, let password = password, username.count > 0, password.count > 0 {
            
            let pattern = "[^@]+@[a-zA-Z0-9-.]+\\.[a-zA-Z]{2,}"
            
            var regex: NSRegularExpression?
            do {
                regex = try NSRegularExpression(pattern: pattern, options: [])
            } catch let error {
                print("regex failed for \(pattern), error \(error)")
            }
            
            let matches = regex!.matches(in: username, options: .withTransparentBounds, range: NSMakeRange(0, username.count))
            
            if matches.count != 0 {
                attemptCreateUser(username, password)
            } else {
                BespinSimpleAlert.show("Please enter a valid email.", disableUI: false)
            }
            
        } else {
            BespinSimpleAlert.show("Please enter an email and password.", disableUI: false)
        }
        
    }
    
    func attemptCreateUser(_ username: String, _ password: String) {
        
        self.performSegue(withIdentifier: "RegisterUser", sender: self)
        /*
         let alert = UIAlertController(title: "Apple Business Id Required", message: "explain here", preferredStyle: UIAlertControllerStyle.alert)
         alert.popoverPresentationController?.sourceView = self.view
         alert.addTextField { (textField) in
         textField.placeholder = "Apple Business Id"
         }
         
         alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
         alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
         if let businessId = alert.textFields?[0].text {
         print(businessId)
         UserDefaults.businessId = businessId
         LoginManager.sharedInstance.createUser(username: username, password: password) { (status, error) in
         if status {
         UserDefaults.isLoggedIn = true
         NotificationManager.notification().registerForPushNotifications()
         self.dismiss(animated: true, completion: nil)
         } else {
         let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
         alert.popoverPresentationController?.sourceView = self.view
         alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
         DispatchQueue.main.async {
         self.present(alert, animated: true, completion: nil)
         }
         }
         }
         }
         }))
         DispatchQueue.main.async {
         self.present(alert, animated: true, completion: nil)
         }
         */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "RegisterUser" {
                let navi = segue.destination as! UINavigationController
                let vc = navi.viewControllers[0] as! UserViewController
                if let loginCell = self.collectionView.cellForItem(at: IndexPath(row: self.pages.count, section: 0)) as? LoginCell {
                    vc.username = loginCell.emailTextField.text
                    vc.password = loginCell.passwordTextField.text
                }
            }
        }
    }
    
}

extension LoginViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // set-up the Login Cell
        if indexPath.item == pages.count {
            let loginCell = collectionView.dequeueReusableCell(withReuseIdentifier: loginCellId, for: indexPath) as! LoginCell
            loginCell.delegate = self
            return loginCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        
        cell.page = pages[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.collectionView.reloadData()
        }
        
    }

}
