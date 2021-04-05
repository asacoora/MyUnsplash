//
//  ViewModel.swift
//  MyUnsplash
//
//  Created by kisoo Um on 2020/11/19.
//  Copyright © 2020 kisoo Um. All rights reserved.
//

import UIKit

enum RequestType{
    case getImages
    case search(queryString : String)
}
enum SuccessCompletionType{
    case getImagesCompletion( callback : ( _ cellData : [UnsplashData]) -> Void                )
    case searchCompletion(callback : ( _ cellData : [UnsplashData]  , _ totalPage : Int?) -> Void   )
}
enum UnsplashAppError : Error{
    case invalidUrl
    case badResponse
    case imposibleDecodeing
    
}
protocol ViewModelProtocal {
    func request( type : RequestType,  page : Int ,perPage : Int , callback:  SuccessCompletionType , errorCallback : (( _ error :UnsplashAppError)->Void)?   )
}

class ViewModel: NSObject ,ViewModelProtocal{

    let requestUrlStr : String = {
        return AppData.requestUrlStr
    }()
    let accessKey : String = {
        return AppData.accessKey
    }()
    lazy var basicPathlStr : String  = { [weak self] in
        return "/photos"
    }()
    lazy var queryPathStr :  String  = { [weak self] in
        return "/search/photos"
    }()
    func request( type : RequestType,  page : Int ,perPage : Int , callback:  SuccessCompletionType ,  errorCallback : ((  _ error : UnsplashAppError )->Void)?)  {
        guard var urlCompo = URLComponents(string: self.requestUrlStr) else{
            errorCallback?( .invalidUrl )
            return
        }
        var items = getQueryItems()
        items.append(URLQueryItem(name: "page", value: String(page)))
        items.append(URLQueryItem(name: "per_page", value: String(perPage)))
        
        switch type {
        case .getImages:
            urlCompo.path = self.basicPathlStr
            
        case .search(let queryStr	) :
            urlCompo.path = self.queryPathStr
            items.append((URLQueryItem(name: "query", value: String(queryStr))))
            
        }
        
        urlCompo.queryItems = items
        
        let req = URLRequest(url: (urlCompo.url!))
        
        let config : URLSessionConfiguration = URLSessionConfiguration.default
        let session : URLSession = URLSession(configuration: config)
        let dataTask = session.dataTask(with: req) {
            (data, response, error) in
            
            if (error != nil){
                print("request error")
                print(error.debugDescription)
                return
            }
            //print( "status : \((response as! HTTPURLResponse).statusCode)")
            if let respo : HTTPURLResponse = response as? HTTPURLResponse{
                
                switch respo.statusCode {
                case 200:
                    guard let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) else{
                            print("json serialization nil")
                            return
                    }
                    var arr : [Any] = []
                    var totalPages :Int?
                    if let _arr = json as? [Any] {
                        arr = _arr
                    }
                    else if let rst = json as? [String: Any]{
                        //print(rst["total_pages"])
                        totalPages = rst["total_pages"] as? Int
                        //print(rst)
                        guard let _arr = rst["results"]  as? [Any] else{
                            print ("arr nil")
                            return
                        }
                        arr = _arr
                    }
                    
                    var cellData : [UnsplashData] = []
                    for i in arr{
                        guard let  item = i as? [String : Any] else{      return                  }
                        let cell :UnsplashData = UnsplashData(item: item)
                        cellData.append(cell)
                    }
                    switch callback {
                    case .getImagesCompletion(let completion):
                        completion(cellData)
                        
                    case .searchCompletion( let completion):
                        completion(cellData, totalPages)
                        
                    }
                    /*
                    if (callback != nil){
                        callback(cellData)
                    }else{
                        print("no callback")
                    }
                     */
                default:
                    print (response?.description)
                }
            }else{
                print("error casting to HTTPURLResponse")
            }
            
            
        }
       
        dataTask.resume()
        
        
    }
    func getQueryItems() -> [URLQueryItem]{
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: "client_id", value: self.accessKey))
        return items
    }
    
    
}
