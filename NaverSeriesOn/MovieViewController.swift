//
//  ViewController.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/10.
//

import UIKit

class MovieViewController: UIViewController {

    @IBOutlet weak var movieTableView: UITableView!
    var notificationTableView:UITableView?
    
    @IBOutlet weak var totalMovieButton: UIButton!
    @IBOutlet weak var fantasyMovieButton: UIButton!
    @IBOutlet weak var comedyMovieButton: UIButton!
    @IBOutlet weak var thrillerMovieButton: UIButton!
    

    @IBOutlet weak var basedCntButton: UIButton!
    @IBOutlet weak var basedAvgButton: UIButton!
    
    var movieGroup: MovieGroup!
    
    var clickedMovieGenre: String = "all"
    var clickedSortMethod: String = "vote_count"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.dataSource = self
        movieTableView.delegate = self
        movieTableView.rowHeight = 145
        
        notificationTableView = movieTableView
        movieGroup = MovieGroup(parentNotification: receivingNotification)
        
        movieTableView.separatorInset = UIEdgeInsets.zero
    }
    
    func receivingNotification(movieInfo:MovieInfo?, action:DbAction?){
        self.notificationTableView!.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        notificationTableView = movieTableView
        movieGroup.queryData(genreName: clickedMovieGenre, sortMethod: clickedSortMethod)
        
    }
    
    @IBAction func clickTotalMovieButton(_ sender: UIButton) {
        sender.tintColor = .white
        basedCntButton.tintColor = .white
        
        clickedMovieGenre = "all"
        clickedSortMethod = "vote_count"
        
        changeButtonStyle(otherButtons: [basedAvgButton, fantasyMovieButton, comedyMovieButton, thrillerMovieButton])
        movieGroup.queryData(genreName: clickedMovieGenre, sortMethod: clickedSortMethod)
        
        scrollUpTableView()
    }
    
    @IBAction func clickFantasyMovieButton(_ sender: UIButton) {
        sender.tintColor = .white
        basedCntButton.tintColor = .white
        
        clickedMovieGenre = "Fantasy"
        clickedSortMethod = "vote_count"
        
        changeButtonStyle(otherButtons: [basedAvgButton, totalMovieButton, comedyMovieButton, thrillerMovieButton])
        movieGroup.queryData(genreName: clickedMovieGenre, sortMethod: clickedSortMethod)
        
        scrollUpTableView()
    }
    
    @IBAction func clickComedyButton(_ sender: UIButton) {
        sender.tintColor = .white
        basedCntButton.tintColor = .white
        
        clickedMovieGenre = "Comedy"
        clickedSortMethod = "vote_count"
        
        changeButtonStyle(otherButtons: [basedAvgButton, totalMovieButton, fantasyMovieButton, thrillerMovieButton])
        movieGroup.queryData(genreName: clickedMovieGenre, sortMethod: clickedSortMethod)
        
        scrollUpTableView()
    }
    
    
    @IBAction func clickThrillerMovieButton(_ sender: UIButton) {
        sender.tintColor = .white
        basedCntButton.tintColor = .white
        
        clickedMovieGenre = "Thriller"
        clickedSortMethod = "vote_count"
        
        changeButtonStyle(otherButtons: [basedAvgButton, totalMovieButton, fantasyMovieButton, comedyMovieButton])
        movieGroup.queryData(genreName: clickedMovieGenre, sortMethod: clickedSortMethod)
        
        scrollUpTableView()
    }
    
    @IBAction func clickBasedCntButton(_ sender: UIButton) {
        sender.tintColor = .white
        
        clickedSortMethod = "vote_count"
        
        changeButtonStyle(otherButtons: [basedAvgButton])
        movieGroup.queryData(genreName: clickedMovieGenre, sortMethod: clickedSortMethod)
        
        scrollUpTableView()
    }
    
    @IBAction func clickBasedAvgButton(_ sender: UIButton) {
        sender.tintColor = .white
        
        clickedSortMethod = "vote_average"
        
        changeButtonStyle(otherButtons: [basedCntButton])
        movieGroup.queryData(genreName: clickedMovieGenre, sortMethod: clickedSortMethod)
        
        scrollUpTableView()
    }

    
    func changeButtonStyle(otherButtons:[UIButton]){
        for otherButton in otherButtons{
            otherButton.tintColor = UIColor(displayP3Red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
        }
    }
    
    func scrollUpTableView(){
        let indexPath = NSIndexPath(row:NSNotFound, section:0)
        self.movieTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
}

extension MovieViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movieGroup = movieGroup{
            return movieGroup.getMovies().count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableViewCell") as! RankingTableViewCell
        let movie = movieGroup.movies[indexPath.row]
        
        cell.moviePoster.image = UIImage(named: "poster_sample.jpg")
        cell.rankLabel.text = String(indexPath.row+1)
        cell.titleLabel.text = movie.title
        cell.voteLabel.text = movie.printVoteAverage()+" ("+String(movie.vote_count)+"개)  |  "+String(movie.id)
        return cell
    }
}

extension MovieViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
    }
}

extension MovieViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgMovieDetail"{
            if let movieDetailVC = segue.destination as? MovieDetailViewController {
                let selectedRow = movieTableView.indexPathForSelectedRow!.row
                movieDetailVC.movieInfo = movieGroup.getMovies(idx: selectedRow)[0]
            }
        }
    }
}
