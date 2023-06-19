//
//  MovieGroup.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/13.
//

import Foundation

class MovieGroup: NSObject{
    var movies = [MovieInfo]()
    var genre:Genre!
    var database: Database!
    var parentNotification: ((MovieInfo?, DbAction?) -> Void)?
    
    init(parentNotification: ((MovieInfo?, DbAction?) -> Void)?){
        super.init()
        self.parentNotification = parentNotification
        database = DbMemory(parentNotification: receivingNotification)
    }
    
    func receivingNotification(movieInfo:MovieInfo?, action:DbAction?){
        if let movieInfo = movieInfo{
            switch(action){
                case .Reset: resetMovieInfo()
                case .Add: addMovieInfo(movieInfo:movieInfo)
                case .Modify: modifyMovieInfo(modifiedMovieInfo: movieInfo)
                case .Delete: removeMovieInfo(removedMovieInfo: movieInfo)
                default: break
            }
        }
        if let parentNotification = parentNotification{
            parentNotification(movieInfo, action)
        }
    }
}

extension MovieGroup{
    func queryData(genreName: String, sortMethod: String){
        movies.removeAll()
        database.queryMovie(genreName: genreName, sortMethod: sortMethod)
    }
    
    func searchData(searchWord: String){
        movies.removeAll()
        database.searchMovie(searchWord: searchWord)
    }
    func saveChange(movieInfo: MovieInfo, action: DbAction){
        database.saveChange(movieInfo: movieInfo, action: action)
    }
}

extension MovieGroup{
    func getMovies(idx:Int? = nil) -> [MovieInfo]{
        if let idx = idx{
            return [movies[idx]]
        }
        return movies
    }
}

extension MovieGroup{
    private func count() -> Int{ return movies.count }
    
    private func find(_ key: String) -> Int?{
        for i in 0..<movies.count{
            if key == movies[i].key{
                return i
            }
        }
        return nil
    }
}

extension MovieGroup{
    private func resetMovieInfo(){movies.removeAll()}
    
    private func addMovieInfo(movieInfo:MovieInfo){ movies.append(movieInfo) }
    
    private func modifyMovieInfo(modifiedMovieInfo: MovieInfo){
        if let idx = find(modifiedMovieInfo.key){
            movies[idx] = modifiedMovieInfo
        }
    }
    
    private func removeMovieInfo(removedMovieInfo: MovieInfo){
        if let idx = find(removedMovieInfo.key){
            movies.remove(at: idx)
        }
    }
//    func changePlan(from: Plan, to: Plan){
//        if let fromIndex = find(from.key), let toIndex = find(to.key) {
//        plans[fromIndex] = to
//        plans[toIndex] = from }
//    }
}
