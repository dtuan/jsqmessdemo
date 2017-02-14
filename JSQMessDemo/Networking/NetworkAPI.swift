//
//  NetworkAPI.swift
//  kurashiki
//
//  Created by Tuan Do on 12/5/16.
//  Copyright © 2016 Resola. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire

let APP_ID        = "72a636636dc341f3b735440813631527" // DEV

enum KurashikiApi {
    case chat(appid: String, content: String, userid: String)
}

extension KurashikiApi : TargetType {
    public var task: Task {
        return .request
    }
    
    var path: String {
        switch self {
        case .chat:
            return "/web"
        }
    }
    
    var base: String {
        return "https://dev.resola.ai/api"
    }

    var baseURL: URL {
        return URL(string: base)!
    }
    
    var method: Moya.Method {
        switch self {
            
        case .chat(_, _, _):
            return .post
        
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .chat(let appid, let content, let user_id):
            return ["appid": appid,
                    "content": content,
                    "s": user_id
            ]
        }
    }
    
    var sampleData: Data {
        return stubbedResponse("chat")
    }
}

func stubbedResponse(_ filename: String) -> Data! {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    let path = bundle.path(forResource: filename, ofType: "json")
    return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
}
