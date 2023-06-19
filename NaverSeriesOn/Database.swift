//
//  Database.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/10.
//

import Foundation

enum DbAction{
    case Reset, Add, Delete, Modify
}

protocol Database{
    init(parentNotification: ((MovieInfo?, DbAction?) -> Void)?)

    func queryMovie(genreName: String, sortMethod: String)
    func searchMovie(searchWord: String)
    func saveChange(movieInfo:MovieInfo, action:DbAction)
}
