//
//  MovieDetailViewController.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/15.
//

import UIKit
import Foundation

let headers = [
  "accept": "application/json",
  "Authorization": "" // api key
]

class MovieDetailViewController: UIViewController {

    var movieInfo:MovieInfo? = nil
    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var actorLabel: UILabel!
    @IBOutlet weak var staffLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.white]
        if movieInfo!.review == nil {
            fetchDataFromIMDBapi()
        }
        
        titleLabel.text = movieInfo!.title
        voteLabel.text = movieInfo!.printVoteAverage()+"("+String(movieInfo!.vote_count)+") | "+String(movieInfo!.release_date).replacingOccurrences(of: "-", with: ".")+" | "+String(movieInfo!.runtime).split(separator: ".")[0]+"분"
        overviewLabel.text = movieInfo!.overview
        if let credit = movieInfo!.credit{
            if credit.crew.count == 0{
                directorLabel.text = "-"
                staffLabel.text = "-"
            }
            else{
                directorLabel.text = getDirectorInfo(crews: credit.crew)
                staffLabel.text = getStaffInfo(crews: credit.crew)
            }
            actorLabel.text = getActorInfo(casts: credit.cast)
            
        }else{
            directorLabel.text = "-"
            actorLabel.text = "-"
            staffLabel.text = "-"
        }
        
    }
}

extension MovieDetailViewController{
    func getDirectorInfo(crews:[Crew]) -> String{
        for crew in crews {
            if crew.job == "Director"{
                return String(crew.name)
            }
        }
        
        return "-"
    }
    
    func getActorInfo(casts:[Cast]) -> String{
        if casts.count == 0 {
            return "-"
        }
        
        var castInfo = ""
        for i in 0..<casts.prefix(5).count{
            let cast = casts[i]
            if castInfo == "" {
                castInfo = String(cast.name)+"("+String(cast.character)+")"
            }
            else{
                castInfo = castInfo + ", " + String(cast.name) + "(" + String(cast.character) + ")"
            }
        }
        return castInfo
    }
    
    func getStaffInfo(crews:[Crew]) -> String{
        var staffInfo = "-"
        
        for i in 0..<crews.prefix(6).count {
            let crew = crews[i]
            if crew.job != "Director"{
                if staffInfo == "-"{
                    staffInfo = String(crew.name)+"("+String(crew.job)+")"
                }
                else{
                    staffInfo = staffInfo + ", " + String(crew.name) + "(" + String(crew.job) + ")"
                }
            }
        }
        
        return staffInfo
    }
}

extension MovieDetailViewController{
    func fetchDataFromIMDBapi(){
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/\(self.movieInfo!.id)/reviews?language=en-US")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error as Any)
          } else {
              let httpResponse = response as? HTTPURLResponse
              var resultString = String(data: data!, encoding: .utf8) ?? ""
              
              if resultString != ""{
                  resultString = resultString.replacingOccurrences(of: "\"rating\":null", with: "\"rating\":-10.0").replacingOccurrences(of: "\"avatar_path\":null", with: "\"avatar_path\":\"\"")
                  do{
                      let reviewDatailJson = resultString.data(using: .utf8)
                      let reviewDetail = try JSONDecoder().decode(ReviewInfo.self, from: reviewDatailJson!)
                      self.movieInfo!.review = reviewDetail
                  }
                  catch {
                      self.movieInfo!.review = nil
                  }
                  
              }
          }
        })
        dataTask.resume()
    }
}

extension MovieDetailViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgReviewDetail"{
            if let reviewVC = segue.destination as? ReviewViewController {
                reviewVC.movieInfo = movieInfo
            }
        }
    }
}
