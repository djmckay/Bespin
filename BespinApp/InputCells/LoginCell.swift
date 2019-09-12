//
//  LoginCell.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit

protocol LoginControllerDelegate: class {
    func finishedLogIn(_ username: String?, _ password: String?)
    func createUser(_ username: String?, _ password: String?)
}

class LoginCell: UICollectionViewCell {
    
    let logoImageView: UIImageView = {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    let emailTextField: LeftPaddedTextField = {
        let textField = LeftPaddedTextField()
        textField.layer.cornerRadius = 4.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "email"
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let passwordTextField: LeftPaddedTextField = {
        let textField = LeftPaddedTextField()
        textField.layer.cornerRadius = 4.0
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "password"
        textField.isSecureTextEntry = true
        return textField
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4.0
        button.backgroundColor = UIColor.rgb(41, 128, 185)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    lazy var createButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 4.0
        button.backgroundColor = UIColor.rgb(41, 128, 185)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Create", for: .normal)
        button.addTarget(self, action: #selector(handleCreate), for: .touchUpInside)
        return button
    }()
    
    weak var delegate: LoginControllerDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logoImageView)
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(createButton)
        
        _ = logoImageView.anchor(top: centerYAnchor, left: nil, bottom: nil, right: nil, topConstant: -200, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 160, heightConstant: 160)
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let width = CGFloat(250)
        let offset = (bounds.width - width) / 2
        //offset < 30 ? 30 : offset
        _ = emailTextField.anchor(top: logoImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: offset, bottomConstant: 0, rightConstant: offset, widthConstant: width, heightConstant: 50)
        
        _ = passwordTextField.anchor(top: emailTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 15, leftConstant: offset, bottomConstant: 0, rightConstant: offset, widthConstant: width, heightConstant: 50)
        
        _ = loginButton.anchor(top: passwordTextField.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 15, leftConstant: offset, bottomConstant: 0, rightConstant: offset, widthConstant: width, heightConstant: 50)
        
        _ = createButton.anchor(top: loginButton.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 15, leftConstant: offset, bottomConstant: 0, rightConstant: offset, widthConstant: width, heightConstant: 50)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func handleLogin() {
        // Log in stuff
        // then call completion
        delegate?.finishedLogIn(emailTextField.text, passwordTextField.text)
    }
    
    @objc func handleCreate() {
        // Log in stuff
        // then call completion
        delegate?.createUser(emailTextField.text, passwordTextField.text)
    }
    
}


// Subclass UITextField to add some left padding
class LeftPaddedTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
}
