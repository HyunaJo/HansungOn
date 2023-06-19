//
//  DbMemory.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/10.
//

import Foundation

class DbMemory: Database{
    private var storage = [MovieInfo]()
    private var requestMovieGroup = [MovieInfo]()
    private var movieDict:[Int:MovieInfo] = [:]
    private var creditDict:[Int:Credit] = [:]

    var parentNotification: ((MovieInfo?, DbAction?) -> Void)?

    required init(parentNotification: ((MovieInfo?, DbAction?) -> Void)?){
        self.parentNotification = parentNotification

        movieDict = loadMovieCSV()
        loadCreditCSV()
        
        storage = Array(movieDict.values)
        storage = storage.sorted(by: { firstMovie, secondMovie in
            return firstMovie.vote_count > secondMovie.vote_count
        })
    }
}

extension DbMemory{
    func loadCreditCSV() -> Void{
        guard let filePath = Bundle.main.path(forResource: "credits", ofType: "csv") else {
            print("CSV file couldn't be found")
            return
        }
        
        var data = ""
        do{
            data = try String(contentsOfFile: filePath)
            
            var rows = data.components(separatedBy: "\n")
            rows.remove(at: 0)
            for row in rows{
                if row == ""{
                    continue
                }
                var creditData = [String]()
                let columns = row.components(separatedBy: ",")
                var columnData = ""
                for column in columns {
                    if column == "[]"{
                        creditData.append(column)
                    }
                    else if column.contains("["){
                        columnData = column
                    }
                    else if column.contains("]"){
                        columnData = columnData+","+column
                        creditData.append(columnData)
                        columnData = ""
                    }
                    else if creditData.count == 2{
                        creditData.append(column)
                    }
                    else if column.contains("{") || column.contains(":"){
                        columnData = columnData+","+column
                    }
                    else{
                        columnData = columnData+"@@"+column
                    }
                }
                if creditData.count == 3{
                    if movieDict.index(forKey: Int(creditData[2]) ?? -1) != nil {
                        let credit = Credit(castStr: creditData[0], crewStr: creditData[1])
                        movieDict[Int(creditData[2])!]!.setCredit(credit: credit)
                    }
                }
            }
        }catch{
            print(error)
        }
    }
}

extension DbMemory{
    func loadMovieCSV() -> [Int:MovieInfo]{
        guard let filePath = Bundle.main.path(forResource: "movies_metadata", ofType: "csv") else {
            print("CSV file couldn't be found")
            return [:]
        }
        
        var data = ""
        do{
            data = try String(contentsOfFile: filePath)
            
            let rows = data.components(separatedBy: "\n")

            var movieInfo = [[Any]]()
            for row in rows{
                var movieData:[Any] = []
                let columns = row.components(separatedBy: ",")
                var columnData = ""
                
                for column in columns {
                    if (column == ""){
                        movieData.append(column)
                        columnData = ""
                    }
                    else{
                        var modifiedColumn = column.replacingOccurrences(of:"”",with:"\"")
                        if(String(modifiedColumn).contains("\"") || String(modifiedColumn).contains("'") ||  modifiedColumn.prefix(1) == " " ){
                            modifiedColumn = column.replacingOccurrences(of: " ", with: "").replacingOccurrences(of:"\"\"",with:"\'")
                            if(modifiedColumn.prefix(1)=="\"" && modifiedColumn.suffix(1)=="\""){
                                movieData.append(column)
                                columnData = ""
                            }
                            else if(modifiedColumn.prefix(1)=="\""){
                                columnData = column
                            }
                            else if(modifiedColumn.suffix(1)=="\""){
                                columnData = columnData+","+column
                                movieData.append(columnData)
                                columnData = ""
                            }
                            else{
                                columnData = columnData+","+column
                            }
                        }
                        else{
                            movieData.append(column)
                            columnData = ""
                        }
                    }
                }
                movieInfo.append(movieData)
            }
            movieInfo = movieInfo.filter { row in
                return row.count == 24
            }
            
            movieInfo.remove(at: 0) // header 삭제
            // vote_count 기준으로 내림차순 정렬
            var sortmovieInfo = movieInfo.sorted(by: { firstArr, secondArr in
                let voteCnt1 = firstArr[23] as! String
                let voteCnt2 = secondArr[23] as! String
                
                return Int(voteCnt1)! > Int(voteCnt2)!
            })
            sortmovieInfo = Array(sortmovieInfo.prefix(100)) // 상위 100개 영화
            
            for info in sortmovieInfo {
                let id = Int(info[5] as! String)!
                let title = info[8] as! String
                let vote_average = Float(info[22] as! String)!
                let vote_count = Int(info[23] as! String)!
                let runtime = Float(info[16] as! String)!
                let release_date = info[14] as! String
                var overview = info[9] as? String ?? ""
                if overview != ""{
                    if overview.prefix(1)=="\""{
                        overview = String(overview.dropFirst(1))
                        if overview.suffix(1)=="\""{
                            overview = String(overview.dropLast(1))
                        }
                    }
                }
                let genresStr = info[3] as! String
                let is_adult = info[0] as! String
                
                movieDict[id] = MovieInfo(id: id, title: title, vote_average: vote_average, vote_count: vote_count, runtime: runtime, release_date: release_date, overview: overview, genreStr: genresStr, is_adult: is_adult)
            }
            return movieDict
        }catch{
            print(error)
            return [:]
        }
    }
}

extension DbMemory{
    
    // genre에 해당하는 MovieInfo를 sortMethod 기준으로 리턴
    // parentNotification에게 한번에 한개씩 리턴
    func queryMovie(genreName: String, sortMethod: String) {
        requestMovieGroup.removeAll()
        
        switch (genreName){
        case "all":
            requestMovieGroup = storage
            break
        case "nothing":
            if let parentNotification = parentNotification{
                parentNotification(nil, .Reset)
            }
        default:
            for i in 0..<storage.count{
                for genreInfo in storage[i].genres{
                    if genreInfo.name == genreName{
                        requestMovieGroup.append(storage[i])
                    }
                }
            }
        }
        
        if sortMethod == "vote_average"{ // 평균 평점 기준 정렬
            requestMovieGroup = requestMovieGroup.sorted(by: { firstMovie, secondMovie in
                return firstMovie.vote_average > secondMovie.vote_average
            })
        }
        
        requestMovieGroup = Array(requestMovieGroup.prefix(20)) // 상위 20개 영화
        for i in 0..<requestMovieGroup.count{
            if let parentNotification = parentNotification{
                parentNotification(requestMovieGroup[i], .Add)
            }
        }
    }
}

extension DbMemory{
    func searchMovie(searchWord: String) {
        var requestMovieGroup = [MovieInfo]()
        
        for i in 0..<storage.count{
            if storage[i].title.lowercased().contains(searchWord.lowercased()){
                requestMovieGroup.append(storage[i])
            }
            else if storage[i].credit != nil{
                var actorArr = storage[i].credit!.cast
                for actor in actorArr{
                    if actor.name.lowercased().contains(searchWord.lowercased()){
                        requestMovieGroup.append(storage[i])
                        break
                    }
                }
            }
        }
        
        requestMovieGroup = requestMovieGroup.sorted(by: { firstMovie, secondMovie in
            return firstMovie.vote_average > secondMovie.vote_average
        })
        
        if requestMovieGroup.count == 0{
            if let parentNotification = parentNotification{
                parentNotification(nil, .Reset)
            }
        }
        
        for i in 0..<requestMovieGroup.count{
            if let parentNotification = parentNotification{
                parentNotification(requestMovieGroup[i], .Add)
            }
        }
    }
}

extension DbMemory{
    // 주어진 MovieInfo에 대하여 삽입, 수정, 삭제를 storage에서 하고
    // parentListener를 호출하고 알림
    func saveChange(movieInfo: MovieInfo, action: DbAction) {
        if action == .Add{
            storage.append(movieInfo)
        }else{
            for i in 0..<storage.count{
                if movieInfo.key == storage[i].key{
                    if action == .Delete{storage.remove(at:i)}
                    if action == .Modify{storage[i] = movieInfo}
                    break
                }
            }
        }
        if let parentNotification = parentNotification{
            parentNotification(movieInfo, action)
        }
    }
}
