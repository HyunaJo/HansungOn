//
//  ReviewInfo.swift
//  NaverSeriesOn
//
//  Created by 조현아 on 2023/06/17.
//

import Foundation

struct ReviewDetail:Codable{
    let author: String
    let author_details: AuthorDetail
    let content:String
    let created_at: String
    let id: String
    let updated_at: String
    let url: String
}

struct AuthorDetail:Codable{
    let name: String
    let username: String
    let avatar_path: String
    let rating: Float
}

struct ReviewInfo: Codable{
    var id: Int
    var page: Int
    var results:[ReviewDetail]
    var total_pages: Int
    var total_results: Int
}
