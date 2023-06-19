//
//  SearchViewController.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/10.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    var movieVC:MovieViewController?
    var movieGroup: MovieGroup!
    
    var searchWord:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.keyboardDismissMode = .onDrag
        
//        let tapGesture = UITapGestureRecognizer(target: sear, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
        
        searchTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.rowHeight = 145
        
        movieVC = ((self.tabBarController?.viewControllers![0] as! UINavigationController).viewControllers[0] as! MovieViewController)
        movieGroup = movieVC!.movieGroup
        movieVC!.notificationTableView = searchTableView
        searchTableView.separatorInset = UIEdgeInsets.zero
    }
    
    func receivingNotification(movieInfo:MovieInfo?, action:DbAction?){
        self.searchTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        movieVC!.notificationTableView = searchTableView
       
        if searchWord == ""{
            movieGroup.queryData(genreName: "nothing", sortMethod: "")
        }
        else{
            movieGroup.searchData(searchWord: searchWord)
        }
    }
    
    @IBAction func clickSearchButton(_ sender: UIButton) {
        if let enterWord = searchTextField.text{
            if enterWord.replacingOccurrences(of: " ", with: "") != ""{
                searchWord = enterWord
                movieGroup.searchData(searchWord: searchWord)
                scrollUpTableView()
                searchTextField.resignFirstResponder()
            }
        }
    }
}

extension SearchViewController{
    @objc func dismissKeyboard(sender: UITapGestureRecognizer){
        searchTextField.resignFirstResponder()
    }
}
extension SearchViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movieGroup = movieGroup{
            return movieGroup.getMovies().count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        
        let movie = movieGroup.movies[indexPath.row]
        
        cell.moviePoster.image = UIImage(named: "poster_sample.jpg")
        cell.titleLabel.text = movie.title
        cell.voteLabel.text = movie.printVoteAverage() + "(" + String(movie.vote_count) + "개)  |  " + String(movie.id)
        if movie.overview != "" {
            cell.overviewLabel.text = movie.overview.split(separator: ".")[0]+"."
        }
        else{
            cell.overviewLabel.text = ""
        }
        return cell
    }
}

extension SearchViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        dump(tableView.cellForRow(at: indexPath))
//        print(indexPath.row)
    }
    
}

extension SearchViewController{
    func scrollUpTableView(){
        let indexPath = NSIndexPath(row:NSNotFound, section:0)
        self.searchTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
}

extension SearchViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgMovieDetail"{
            if let movieDetailVC = segue.destination as? MovieDetailViewController {
                let selectedRow = searchTableView.indexPathForSelectedRow!.row
                movieDetailVC.movieInfo = movieGroup.getMovies(idx: selectedRow)[0]
            }
        }
    }
}
