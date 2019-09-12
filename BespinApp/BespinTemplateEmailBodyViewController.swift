//
//  BespinTemplateEmailBodyViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/28/18.
//

import UIKit

class BespinTemplateEmailBodyViewController: UIViewController {

    var emailBody: BespinTemplateViewController.EmailBody! 
    
    @IBOutlet weak var bodyTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyTextView.text = emailBody.body

        
        
        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? BespinTemplateViewController {
            vc.unwindFromText = self.bodyTextView.text
        }
                
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
