//
//  DetailViewController.swift
//  Code Test Carlos Estevez
//
//  Created by Carlos Estevez on 12/18/18.
//  Copyright © 2018 Carlos Estevez. All rights reserved.
//

import UIKit

class DetailViewController:UIViewController, UIScrollViewDelegate {//UITextViewDelegate
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var validationLabel: UILabel!
    
    
    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var addPhoneNumberButton: UIButton!
    @IBOutlet weak var addEmailButton: UIButton!
    
    @IBOutlet weak var addressesStackView: UIStackView!
    @IBOutlet weak var phoneNumbersStackView: UIStackView!
    @IBOutlet weak var emailsStackView: UIStackView!
    
    @IBOutlet weak var addressesParentStackView: UIStackView!
    @IBOutlet weak var phoneNumbersParentStackView: UIStackView!
    @IBOutlet weak var emailsParentStackView: UIStackView!
    
    @IBOutlet weak var addressesStackHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneNumbersStackHeight: NSLayoutConstraint!
    @IBOutlet weak var emailsStackHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewInnerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var addresses:[[String:UITextField]] = []
    var phoneNumbers:[UITextField] = []
    var emails:[UITextField] = []
    
    var addressesViews:[UIView] = []
    var phoneNumbersViews:[UIView] = []
    var emailsViews:[UIView] = []
    
    let addressViewsWidth = 350//also is a constraint in storyboard
    let addressViewsHeight = 46
    let addressViewsButtonWidth = 50
    let streetPlaceholder = "Street address"
    let cityStatePlaceholder = "City, State"
    let zipPlaceholder = "Zip code"
    
    let phoneNumberViewsWidth = 250
    let phoneNumberViewsHeight = 24
    let phoneNumberViewsButtonWidth = 50
    let phoneNumberViewsPlaceholder = "(xxx) xxx-xxxx"
    
    let emailViewsWidth = 250
    let emailViewsHeight = 24
    let emailViewsButtonWidth = 50
    let emailViewsPlaceholder = "example@domain.com"
    
    var scrollViewInnerViewHeightOriginal:CGFloat = 0
    var scrollViewInnerViewHeight:CGFloat = 0
    
    var contact: Contact?
    
    var i:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        
        phoneNumbersStackHeight.constant = CGFloat(phoneNumbers.count * phoneNumberViewsHeight)
        addressesStackHeight.constant = CGFloat(addresses.count * addressViewsHeight)
        emailsStackHeight.constant = CGFloat(emails.count * emailViewsHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollViewInnerView.frame = CGRect(x: scrollViewInnerView.frame.minX, y: scrollViewInnerView.frame.minY, width: scrollViewInnerView.frame.width, height: scrollViewInnerView.frame.height - 64)//adjust for navigation area
        scrollView.contentSize = scrollViewInnerView.frame.size
        
        scrollViewInnerViewHeightOriginal = scrollViewInnerView.frame.height
        scrollViewInnerViewHeight = scrollViewInnerView.frame.height
        
        if contact != nil {
            cancelButton.title = "Go Back"
            navigationItem.title = "Edit Contact"
            
            firstNameTextField.text = contact?.firstName
            lastNameTextField.text = contact?.lastName
            dobTextField.text = contact?.dob
            
            for (index, phoneNumberField) in (contact?.phoneNumbers.enumerated())! {
                addPhoneNumberButton.sendActions(for: .touchUpInside)
                phoneNumbers[index].text = phoneNumberField
            }
            
            for (index, emailField) in (contact?.emails.enumerated())! {
                addEmailButton.sendActions(for: .touchUpInside)
                emails[index].text = emailField
            }
            
            for (index, addressFields) in (contact?.addresses.enumerated())! {
                addAddressButton.sendActions(for: .touchUpInside)
                addresses[index]["street"]!.text = addressFields["street"]
                addresses[index]["cityState"]!.text = addressFields["cityState"]
                addresses[index]["zip"]!.text = addressFields["zip"]
            }
        } else {
            cancelButton.title = "Cancel"
            navigationItem.title = "New Contact"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //in preparation for subsequent call to viewDidLayoutSubviews below
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            //orientation change - will rotate...
            self.i = 0
        }) { [unowned self] _ in
            //orientation change - did rotate...
            self.i = 0
        }
    }
    
    override func viewDidLayoutSubviews() {
        //called after orientation change
        //bug fix for UI to scroll through all dynamic fields after orientation change
        if scrollViewInnerViewHeight > 0 {
            DispatchQueue.main.async {
                if self.i < 2 {
                    self.view.setNeedsLayout()
                    self.rectifyView()
                    self.scrollView.contentSize = self.scrollViewInnerView.frame.size
                }
                self.i = self.i + 1
            }
        }
    }
    
    //validation
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        let button = sender as? UIBarButtonItem
        var validated:Bool = true
        
        if button === saveButton {
            validationLabel.isHidden = false
            if (firstNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                validationLabel.text = "First Name Required"
                validated = false
            } else if (lastNameTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                validationLabel.text = "Last Name Required"
                validated = false
            } else if (dobTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
                validationLabel.text = "Date of Birth Required"
                validated = false
            } else if (phoneNumbers.count < 1 || (phoneNumbers.first?.text?.trimmingCharacters(in: .whitespaces).isEmpty)!) {
                validationLabel.text = "Primary Phone Number Required"
                validated = false
            } else if (emails.count < 1 || (emails.first?.text?.trimmingCharacters(in: .whitespaces).isEmpty)!) {
                validationLabel.text = "Primary Email Required"
                validated = false
            } else {
                //format validations
                let dobFieldVal = dobTextField.text?.trimmingCharacters(in: .whitespaces)
                if !isValidDOB(value: dobFieldVal!) {
                    validationLabel.text = "Incorrect DOB Format"
                    validated = false
                }
                
                for phoneNumberField in phoneNumbers {
                    let phoneNumberFieldVal = phoneNumberField.text!.trimmingCharacters(in: .whitespaces)
                    if !phoneNumberFieldVal.isEmpty && !isValidPhoneNumber(value: phoneNumberFieldVal) {
                        validationLabel.text = "Incorrect Phone Number Format"
                        validated = false
                        break
                    }
                }
                
                for emailField in emails {
                    let emailFieldVal = emailField.text!.trimmingCharacters(in: .whitespaces)
                    if !emailFieldVal.isEmpty && !isValidEmail(value: emailFieldVal) {
                        validationLabel.text = "Incorrect Email Format"
                        validated = false
                        break
                    }
                }
                
                for addressesFields in addresses {
                    let addressesFieldsStreetVal = addressesFields["street"]!.text!.trimmingCharacters(in: .whitespaces)
                    let addressesFieldsCityStateVal = addressesFields["cityState"]!.text!.trimmingCharacters(in: .whitespaces)
                    let addressesFieldsZipVal = addressesFields["zip"]!.text!.trimmingCharacters(in: .whitespaces)
                    
                    if (!addressesFieldsStreetVal.isEmpty || !addressesFieldsCityStateVal.isEmpty || !addressesFieldsZipVal.isEmpty) {
                        if (addressesFieldsStreetVal.isEmpty || addressesFieldsCityStateVal.isEmpty || addressesFieldsZipVal.isEmpty) {
                            validationLabel.text = "Missing Address Field(s)"
                            validated = false
                            break
                        } else {
                            if !isValidCityState(value: addressesFieldsCityStateVal) {
                                validationLabel.text = "Incorrect \"City, State\" Format"
                                validated = false
                                break
                            } else if !isValidZip(value: addressesFieldsZipVal) {
                                validationLabel.text = "Incorrect Zip Code Format"
                                validated = false
                                break
                            }
                        }
                    }
                }
            }
        }
        
        if !validated {
            DispatchQueue.main.async {
                self.scrollView.contentOffset = CGPoint(x: 0, y: -64)//adjusted for navigation area
            }
            
            return false
        }
        
        validationLabel.isHidden = true
        return true
    }
    
    func isValidEmail(value: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: value)
    }
    
    func isValidPhoneNumber(value: String) -> Bool {
        let phoneRegEx = "^[(]\\d{3}[)] \\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phoneTest.evaluate(with: value)
    }
    
    func isValidDOB(value: String) -> Bool {
        let dobRegEx = "^\\d{2}[/]\\d{2}[/]\\d{2}$"
        let dobTest = NSPredicate(format: "SELF MATCHES %@", dobRegEx)
        return dobTest.evaluate(with: value)
    }
    
    func isValidCityState(value: String) -> Bool {
        let cityStateRegEx = "^[A-Za-z\\s.-]+[,] [A-Za-z\\s.-]+$"
        let cityStateTest = NSPredicate(format: "SELF MATCHES %@", cityStateRegEx)
        return cityStateTest.evaluate(with: value)
    }
    
    func isValidZip(value: String) -> Bool {
        let zipRegEx = "^\\d{5}(-\\d{4})?$"
        let zipTest = NSPredicate(format: "SELF MATCHES %@", zipRegEx)
        return zipTest.evaluate(with: value)
    }
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddContactMode = presentingViewController is UINavigationController
        
        if isPresentingInAddContactMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let button = sender as? UIBarButtonItem
        
        if button === saveButton {
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespaces)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespaces)
            let dob = dobTextField.text!.trimmingCharacters(in: .whitespaces)
            
            var phoneNumbersArr:[String] = []
            for phoneNumberField in phoneNumbers {
                let phoneNumberFieldVal = phoneNumberField.text!.trimmingCharacters(in: .whitespaces)
                if !phoneNumberFieldVal.isEmpty {
                    phoneNumbersArr.append(phoneNumberFieldVal)
                }
            }
            
            var emailsArr:[String] = []
            for emailField in emails {
                let emailFieldVal = emailField.text!.trimmingCharacters(in: .whitespaces)
                if !emailFieldVal.isEmpty {
                    emailsArr.append(emailFieldVal)
                }
            }
            
            var addressesArr:[[String:String]] = []
            for addressesFields in addresses {
                let addressesFieldsStreetVal = addressesFields["street"]!.text!.trimmingCharacters(in: .whitespaces)
                let addressesFieldsCityStateVal = addressesFields["cityState"]!.text!.trimmingCharacters(in: .whitespaces)
                let addressesFieldsZipVal = addressesFields["zip"]!.text!.trimmingCharacters(in: .whitespaces)
                
                if (!addressesFieldsStreetVal.isEmpty && !addressesFieldsCityStateVal.isEmpty && !addressesFieldsZipVal.isEmpty) {
                addressesArr.append(["street": addressesFieldsStreetVal, "cityState": addressesFieldsCityStateVal, "zip": addressesFieldsZipVal])
                }
            }
            
            let saveID = contact?.id
            contact = Contact(firstName: firstName, lastName: lastName, dob: dob, phoneNumbers: phoneNumbersArr, emails: emailsArr, addresses: addressesArr, fullName: firstName + " " + lastName)
            contact?.id = saveID
        }
    }
    
    
    func redrawPhoneNumbers() {
        for (index, phoneNumberView) in phoneNumbersViews.enumerated() {
            let yPos = index * phoneNumberViewsHeight
            phoneNumberView.frame = CGRect(x: 0, y: yPos, width: phoneNumberViewsWidth, height: phoneNumberViewsHeight)
            let views = phoneNumberView.subviews.filter{$0 is UIButton}
            let button = views[0] as! UIButton
            button.tag = index
        }
    }
    
    func redrawEmails() {
        for (index, emailView) in emailsViews.enumerated() {
            let yPos = index * emailViewsHeight
            emailView.frame = CGRect(x: 0, y: yPos, width: emailViewsWidth, height: emailViewsHeight)
            let views = emailView.subviews.filter{$0 is UIButton}
            let button = views[0] as! UIButton
            button.tag = index
        }
    }
    
    func redrawAddresses() {
        for (index, addressView) in addressesViews.enumerated() {
            let yPos = index * addressViewsHeight
            addressView.frame = CGRect(x: 0, y: yPos, width: addressViewsWidth, height: addressViewsHeight)
            let views = addressView.subviews.filter{$0 is UIButton}
            let button = views[0] as! UIButton
            button.tag = index
        }
    }
    
    
    func reloadPhoneNumbers(removing:Bool=false) {
        phoneNumbersStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        for phoneNumberView in phoneNumbersViews {
            phoneNumbersStackView.addSubview(phoneNumberView)
        }
        
        phoneNumbersStackHeight.constant = CGFloat(phoneNumbers.count * phoneNumberViewsHeight)
        let lowestStackYpos = (addressesStackHeight.constant + addressesParentStackView.frame.minY + addressesStackView.frame.minY)
        
        if (removing && (lowestStackYpos > scrollViewInnerViewHeightOriginal)) {
            scrollViewInnerViewHeight = scrollViewInnerViewHeight - CGFloat(phoneNumberViewsHeight)
            rectifyView()
            rectifyViewDelayed()
        } else if (lowestStackYpos > (scrollViewInnerViewHeightOriginal - CGFloat(addressViewsHeight))) {
            scrollViewInnerViewHeight = scrollViewInnerViewHeight + CGFloat(phoneNumberViewsHeight)
            rectifyView()
        }
        
        scrollView.contentSize = scrollViewInnerView.frame.size
    }
    
    func reloadEmails(removing:Bool=false) {
        emailsStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        for emailView in emailsViews {
            emailsStackView.addSubview(emailView)
        }
        
        emailsStackHeight.constant = CGFloat(emails.count * emailViewsHeight)
        let lowestStackYpos = (addressesStackHeight.constant + addressesParentStackView.frame.minY + addressesStackView.frame.minY)
        
        if (removing && (lowestStackYpos > scrollViewInnerViewHeightOriginal)) {
            scrollViewInnerViewHeight = scrollViewInnerViewHeight - CGFloat(emailViewsHeight)
            rectifyView()
            rectifyViewDelayed()
        } else if (lowestStackYpos > (scrollViewInnerViewHeightOriginal - CGFloat(addressViewsHeight))) {
            scrollViewInnerViewHeight = scrollViewInnerViewHeight + CGFloat(emailViewsHeight)
            rectifyView()
        }
        
        scrollView.contentSize = scrollViewInnerView.frame.size
    }
    
    func reloadAddresses(removing:Bool=false) {
        addressesStackView.subviews.forEach({ $0.removeFromSuperview() })
        
        for addressView in addressesViews {
            addressesStackView.addSubview(addressView)
        }
        
        addressesStackHeight.constant = CGFloat(addresses.count * addressViewsHeight)
        let lowestStackYpos = (addressesStackHeight.constant + addressesParentStackView.frame.minY + addressesStackView.frame.minY)
        
        if (removing && (lowestStackYpos > scrollViewInnerViewHeightOriginal)) {
            scrollViewInnerViewHeight = scrollViewInnerViewHeight - CGFloat(addressViewsHeight)
            rectifyView()
            rectifyViewDelayed()
        } else if (lowestStackYpos > (scrollViewInnerViewHeightOriginal - CGFloat(addressViewsHeight))) {
            scrollViewInnerViewHeight = scrollViewInnerViewHeight + CGFloat(addressViewsHeight)
            rectifyView()
        }
        
        scrollView.contentSize = scrollViewInnerView.frame.size
    }
    
    
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        rectifyView()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        rectifyView()
        rectifyViewDelayed()
    }
    
    //rectify needed due to autolayout issue with scrollview's subview requirements and orientation changes
    @objc func rectifyView() {
        DispatchQueue.main.async {
            self.scrollViewInnerView.frame = CGRect(x: self.scrollViewInnerView.frame.minX, y: self.scrollViewInnerView.frame.minY, width: self.scrollViewInnerView.frame.width, height: self.scrollViewInnerViewHeight)
        }
    }
    
    func rectifyViewDelayed() {
        //resolve outlier of scrolling to bottom, bounce, and removing subviews
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.rectifyView), userInfo: nil, repeats: false)
    }
    
    
    
    
    @objc func removePhoneNumberButtonAction(sender: UIButton!) {
        phoneNumbers.remove(at: sender.tag)
        phoneNumbersViews.remove(at: sender.tag)
        redrawPhoneNumbers()
        reloadPhoneNumbers(removing:true)
    }
    
    @objc func removeEmailButtonAction(sender: UIButton!) {
        emails.remove(at: sender.tag)
        emailsViews.remove(at: sender.tag)
        redrawEmails()
        reloadEmails(removing:true)
    }
    
    @objc func removeAddressButtonAction(sender: UIButton!) {
        addresses.remove(at: sender.tag)
        addressesViews.remove(at: sender.tag)
        redrawAddresses()
        reloadAddresses(removing:true)
    }
    
    
    
    @IBAction func addPhoneNumberButtonAction(_ sender: UIButton) {
        let yPos = phoneNumbers.count * phoneNumberViewsHeight
        let view = UIView(frame: CGRect(x: 0, y: yPos, width: phoneNumberViewsWidth, height: phoneNumberViewsHeight))
        
        let button = UIButton(type: .custom)
        button.tag = phoneNumbers.count
        button.frame = CGRect(x: 0, y: 0, width: phoneNumberViewsButtonWidth, height: phoneNumberViewsHeight)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "RemoveIcon"), for: .normal)
        button.addTarget(self, action: #selector(removePhoneNumberButtonAction), for: .touchUpInside)
        view.insertSubview(button, at: phoneNumbers.count)
        
        let textField = UITextField(frame: CGRect(x: phoneNumberViewsButtonWidth, y: 1, width: phoneNumberViewsWidth - phoneNumberViewsButtonWidth, height: phoneNumberViewsHeight))
        textField.placeholder = phoneNumberViewsPlaceholder
        textField.adjustsFontSizeToFitWidth = true
        view.insertSubview(textField, at: phoneNumbers.count)
        
        phoneNumbers.append(textField)
        phoneNumbersViews.append(view)
        reloadPhoneNumbers()
    }
    
    @IBAction func addEmailButtonAction(_ sender: UIButton) {
        let yPos = emails.count * emailViewsHeight
        let view = UIView(frame: CGRect(x: 0, y: yPos, width: emailViewsWidth, height: emailViewsHeight))
        
        let button = UIButton(type: .custom)
        button.tag = emails.count
        button.frame = CGRect(x: 0, y: 0, width: emailViewsButtonWidth, height: emailViewsHeight)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "RemoveIcon"), for: .normal)
        button.addTarget(self, action: #selector(removeEmailButtonAction), for: .touchUpInside)
        view.insertSubview(button, at: emails.count)
        
        let textField = UITextField(frame: CGRect(x: emailViewsButtonWidth, y: 1, width: emailViewsWidth - emailViewsButtonWidth, height: emailViewsHeight))
        textField.placeholder = emailViewsPlaceholder
        textField.adjustsFontSizeToFitWidth = true
        textField.autocapitalizationType = .none
        view.insertSubview(textField, at: emails.count)
        
        emails.append(textField)
        emailsViews.append(view)
        reloadEmails()
    }
    
    
    @IBAction func addAddressButtonAction(_ sender: UIButton?) {
        let yPos = addresses.count * addressViewsHeight
        let view = UIView(frame: CGRect(x: 0, y: yPos, width: addressViewsWidth, height: addressViewsHeight))
        
        let button = UIButton(type: .custom)
        button.tag = addresses.count
        button.frame = CGRect(x: 0, y: 0, width: addressViewsButtonWidth, height: addressViewsHeight)
        button.imageView?.contentMode = .scaleAspectFit
        button.setImage(UIImage(named: "RemoveIcon"), for: .normal)
        button.addTarget(self, action: #selector(removeAddressButtonAction), for: .touchUpInside)
        view.insertSubview(button, at: addresses.count)
        
        let innerView = UIView(frame: CGRect(x: addressViewsButtonWidth, y: 2, width: addressViewsWidth - addressViewsButtonWidth, height: addressViewsHeight - 4))//padding
        innerView.layer.borderWidth = 1
        innerView.layer.borderColor = UIColor.lightGray.cgColor
        innerView.layer.cornerRadius = 3.0
        innerView.clipsToBounds = true
        //innerView.frame = innerView.frame.insetBy(dx: -1, dy: -1)
        
        let textFieldStreet = UITextField(frame: CGRect(x: 0, y: 0, width: innerView.frame.width, height: innerView.frame.height / 2))
        textFieldStreet.placeholder = streetPlaceholder
        textFieldStreet.adjustsFontSizeToFitWidth = true
        textFieldStreet.autocapitalizationType = .words
        innerView.addSubview(textFieldStreet)
        
        let textFieldCityState = UITextField(frame: CGRect(x: 0, y: innerView.frame.height / 2, width: (innerView.frame.width / 3) * 2, height: innerView.frame.height / 2))
        textFieldCityState.placeholder = cityStatePlaceholder
        textFieldCityState.adjustsFontSizeToFitWidth = true
        textFieldCityState.autocapitalizationType = .words
        innerView.addSubview(textFieldCityState)
        
        let textFieldZip = UITextField(frame: CGRect(x: (innerView.frame.width / 3) * 2, y: innerView.frame.height / 2, width: (innerView.frame.width / 3), height: innerView.frame.height / 2))
        textFieldZip.placeholder = zipPlaceholder
        textFieldZip.adjustsFontSizeToFitWidth = true
        innerView.addSubview(textFieldZip)
        
        view.insertSubview(innerView, at: addresses.count)
        addresses.append(["street":textFieldStreet, "cityState":textFieldCityState, "zip": textFieldZip])
        addressesViews.append(view)
        reloadAddresses()
    }

    
}
