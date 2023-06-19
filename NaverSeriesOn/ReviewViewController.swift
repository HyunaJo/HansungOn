//
//  ReviewViewController.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/17.
//

import UIKit

class ReviewViewController: UIViewController {
    
    var movieInfo:MovieInfo? = nil
    
    @IBOutlet weak var reviewTableView: UITableView!
    
    @IBOutlet weak var reviewTextField: UITextField!
    @IBOutlet weak var addReviewButton: UIButton!
    
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    var fCurTextfieldBottom: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 6/255, green: 6/255, blue: 6/255, alpha: 1)
        
        reviewTableView.dataSource = self
        reviewTableView.separatorInset = UIEdgeInsets.zero
        
        reviewTextField.delegate = self
        reviewTextField.returnKeyType = .done
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func clickMinusButton(_ sender: UIButton) {
        if voteLabel.text != "0.0"{
            voteLabel.text = String(Float(voteLabel.text!)!-0.5)
        }
    }
    
    @IBAction func clickPlusButton(_ sender: UIButton) {
        if voteLabel.text != "10.0"{
            voteLabel.text = String(Float(voteLabel.text!)!+0.5)
        }
    }
    @IBAction func clickAddReviewButton(_ sender: UIButton) {
        if reviewTextField.text?.replacingOccurrences(of: " ", with: "") != ""{
            let voteSum = Float(voteLabel.text!)!+(movieInfo!.vote_average*Float(movieInfo!.vote_count))
            movieInfo!.vote_count = movieInfo!.vote_count+1
            movieInfo!.vote_average = voteSum/Float(movieInfo!.vote_count)
            
            movieInfo!.addReview(rating: Float(voteLabel.text!)!, content: reviewTextField.text!)
            
            reviewTextField.text = ""
            voteLabel.text = "10.0"
            
            reviewTableView.reloadData()
            
            let lastSection = reviewTableView.numberOfSections - 1
            let lastRow = reviewTableView.numberOfRows(inSection: lastSection) - 1
            let indexPath = IndexPath(row: lastRow, section: lastSection)
            reviewTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        else{
            print("review 작성 필요")
        }
        
        reviewTextField.resignFirstResponder()
    }
}

extension ReviewViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        fCurTextfieldBottom = textField.frame.origin.y + textField.frame.height
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if fCurTextfieldBottom <= self.view.frame.height - keyboardSize.height {
                return
            }
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                self.view.frame.origin.y += self.tabBarController!.tabBar.frame.size.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
         textField.resignFirstResponder()
         return true
     }
    
}

extension ReviewViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if movieInfo!.review == nil{
            return 0
        }
        else{
            return movieInfo!.review!.results.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell") as! ReviewTableViewCell
        cell.selectionStyle = .none
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.backgroundColor = UIColor.white
        let reviewInfo = movieInfo!.review
        
        cell.authorNameLabel.text = reviewInfo!.results[indexPath.row].author
        var voteText = ""
        if reviewInfo!.results[indexPath.row].author_details.rating < 0{
            voteText = "(평점 없음)"
        }
        else{
            voteText = String(reviewInfo!.results[indexPath.row].author_details.rating)
        }
        cell.voteLabel.text = voteText+" | " + String(reviewInfo!.results[indexPath.row].created_at.split(separator: "T")[0]).replacingOccurrences(of: "-", with: ".")
        cell.reviewLabel.text = reviewInfo!.results[indexPath.row].content
        
        return cell
    }
}
