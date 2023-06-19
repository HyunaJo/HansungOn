//
//  MovieInfo.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/10.
//

import Foundation

struct Genre: Codable{
    let id:Int
    let name:String
}

struct Cast:Codable{
    let cast_id:Int
    let character:String
    let credit_id:String
    let gender:Int
    let id:Int
    let name:String
    let order:Int
    let profile_path:String
}

struct Crew:Codable{
    let credit_id:String
    let department:String
    let gender:Int
    let id:Int
    let job:String
    let name:String
    let profile_path:String
}

class Credit: NSObject{
    var cast:[Cast] = [Cast]()
    var crew:[Crew] = [Crew]()
    
    init(castStr: String, crewStr: String) {
        super.init()
        
        if(castStr != "[]"){
            self.cast = modifyCastStr(str: castStr)
        }
        
        
        if(crewStr != "[]"){
            self.crew = modifyCrewStr(str: crewStr)
        }
    }
}

extension Credit{
    func modifyIntData(str:String)->Int{
        return Int(str.trimmingCharacters(in: .whitespacesAndNewlines)) ?? -1
    }
    
    func modifyStringData(str:String)->String{
        return String(str.trimmingCharacters(in: .whitespacesAndNewlines).dropLast().dropFirst())
    }
}

extension Credit{
    func modifyCastStr(str:String)->[Cast]{
        var castArr = [Cast]()
        
        let strArr = str.split(separator: ",")
        
        var cast_id:Int = -1
        var character:String = ""
        var credit_id:String = ""
        var gender:Int = -1
        var id:Int = -1
        var name:String = ""
        var order:Int = -1
        var profile_path:String = ""
        
        for sequence in strArr {
            if sequence.contains("{"){
                cast_id = -1
                character = ""
                credit_id = ""
                gender = -1
                id = -1
                name = ""
                order = -1
                profile_path = ""
            }
            
            let key = String(sequence.split(separator: ":")[0]).replacingOccurrences(of: " ", with: "")
            let value = String(sequence.split(separator: ":")[1]).replacingOccurrences(of: "@@", with: ",").trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch key {
            case _ where key.contains("'cast_id'"):
                cast_id = modifyIntData(str: value)
            case _ where key.contains("'gender'"):
                gender = modifyIntData(str: value)
            case _ where key.contains("'id'"):
                id = modifyIntData(str: value)
            case _ where key.contains("'order'"):
                order = modifyIntData(str: value)
            case _ where key.contains("'character'"):
                character = modifyStringData(str: value)
            case _ where key.contains("'credit_id'"):
                credit_id = modifyStringData(str: value)
            case _ where key.contains("'name'"):
                name = modifyStringData(str: value)
            case _ where key.contains("'profile_path'"):
                profile_path = modifyStringData(str: value)
            default:
                break
            }
            
            if sequence.contains("}"){
                castArr.append(Cast(cast_id: cast_id, character: character, credit_id: credit_id, gender: gender, id: id, name: name, order: order, profile_path: profile_path))
            }
        }
        return castArr
    }
}

extension Credit{
    func modifyCrewStr(str:String)->[Crew]{
        var crewArr = [Crew]()
        
        let strArr = str.split(separator: ",")

        var credit_id:String = ""
        var department:String = ""
        var gender:Int = -1
        var id:Int = -1
        var job:String = ""
        var name:String = ""
        var profile_path:String = ""

        for sequence in strArr {
            if sequence.contains("{"){
                credit_id = ""
                department = ""
                gender = -1
                id = -1
                job = ""
                name = ""
                profile_path = ""
            }

            let key = String(sequence.split(separator: ":")[0]).replacingOccurrences(of: " ", with: "")
            var value = sequence.split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines)

            switch key {
            case _ where key.contains("'gender'"):
                gender = modifyIntData(str: value)
            case _ where key.contains("'id'"):
                id = modifyIntData(str: value)
            case _ where key.contains("'credit_id'"):
                credit_id = modifyStringData(str: value)
            case _ where key.contains("'department'"):
                department = modifyStringData(str: value)
            case _ where key.contains("'job'"):
                job = modifyStringData(str: value)
            case _ where key.contains("'name'"):
                name = modifyStringData(str: value)
            case _ where key.contains("'profile_path'"):
                profile_path = modifyStringData(str: value)
            default:
                break
            }

            if sequence.contains("}"){
                crewArr.append(Crew(credit_id: credit_id, department: department, gender: gender, id: id, job: job, name: name, profile_path: profile_path))
            }
        }
        return crewArr
    }
}

class MovieInfo: NSObject{
    var key: String
    var id: Int
    var title:String // 영화 제목
    var vote_average:Float // 평균 평점
    var vote_count:Int // 평가 개수
    var runtime:Float // 영화 시간
    var release_date:String // 개봉일
    var overview:String // 영화 소개
    var genres:[Genre] // 장르
    var is_adult:Bool // 청불 여부
    var credit:Credit? = nil
    var review:ReviewInfo? = nil
    
    init(id: Int, title: String, vote_average: Float, vote_count: Int, runtime: Float, release_date: String, overview: String, genreStr: String, is_adult: String) {
        self.key = UUID().uuidString
        self.id = id
        self.title = title
        self.vote_average = vote_average
        self.vote_count = vote_count
        self.runtime = runtime
        self.release_date = release_date
        self.overview = overview
        
        let genreJson = genreStr.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: "\"").data(using: .utf8)
        let genreArr = try! JSONDecoder().decode([Genre].self, from: genreJson!)

        self.genres = genreArr
        self.is_adult = Bool(is_adult.lowercased().trimmingCharacters(in: .whitespaces))!
        super.init()
    }
    
    func setCredit(credit:Credit){
        self.credit = credit
    }
    
    func printVoteAverage() -> String{
        return String(trunc(self.vote_average*10)/10)
    }
    
    func addReview(rating: Float, content:String){
        let authorDetail = AuthorDetail(name: "user", username: "user", avatar_path: "", rating: rating)
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayFormattedDate = dateFormatter.string(from: todayDate)
        review!.results.append(ReviewDetail(author: "user", author_details: authorDetail, content: content, created_at: todayFormattedDate, id: UUID().uuidString, updated_at: todayFormattedDate, url: ""))
        
    }
}

