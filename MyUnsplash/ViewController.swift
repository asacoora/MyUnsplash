//
//  ViewController.swift
//  MyUnsplash
//
//  Created by kisoo Um on 2020/11/17.
//  Copyright © 2020 kisoo Um. All rights reserved.
//

import UIKit

protocol CelldataHandler {
    func getCellData() ->[UnsplashData]
}
protocol  CallbackProtocol {
    func callbackAfterDismiss(indexPath : IndexPath)
}

class ViewController: UIViewController {
    
    var cellData_un : [UnsplashData] = []
    var page = 0
    var totalPages : Int? = nil
    let perPage = 10
    var currentQueryStr : String = ""
    var viewModel : ViewModelProtocal = ViewModel()
    @IBOutlet weak var txtQuery: UITextField!{
        didSet{
            txtQuery.delegate = self
        }
    }
    @IBOutlet weak var imgCollectionView: UICollectionView! {
        didSet {
            self.imgCollectionView.delegate = self
            self.imgCollectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registKeyboardNoti()
        
        
        viewModel.request(type: .getImages , page: self.page, perPage: self.perPage, callback:  .getImagesCompletion(callback: self.requestCallback) , errorCallback: errorCallback)
    }
    
    lazy var requestCallback = {  [weak self]  (newCellData : [UnsplashData] )  ->Void   in
        guard let self = self else {
            return
        }
        
        self.page += 1
        var newIndexPaths : [IndexPath] = []
        
        for i  in 0..<newCellData.count{
            let indexPath = IndexPath(row: self.cellData_un.count + i, section: 0)
            newIndexPaths.append(indexPath)
        }
        self.cellData_un = self.cellData_un + newCellData
        DispatchQueue.main.async {
            self.imgCollectionView.insertItems(at: newIndexPaths)
            self.loadImageData(indexPaths: newIndexPaths)
            //self?.imgCollectionView.reloadData()
        }
    }
    lazy var requestCallbackBySearch = {  [weak self]  (newCellData : [UnsplashData] , totalPages : Int? )  ->Void   in
        guard let self = self else {
            return
        }
        
        self.totalPages = totalPages
        self.page += 1
        var newIndexPaths : [IndexPath] = []
        
        for i  in 0..<newCellData.count{
            let indexPath = IndexPath(row: self.cellData_un.count + i, section: 0)
            newIndexPaths.append(indexPath)
        }
        self.cellData_un = self.cellData_un + newCellData
        DispatchQueue.main.async {
            self.imgCollectionView.insertItems(at: newIndexPaths)
            self.loadImageData(indexPaths: newIndexPaths)
            //self?.imgCollectionView.reloadData()
        }
    }
    lazy var errorCallback = { ( error : UnsplashAppError  ) ->Void in
        
        switch error {
        case  .invalidUrl:
            print("invalid url")
        case .badResponse :
            print("bad response")
        case .imposibleDecodeing :
            print("imposible decoding")
        default:
            print(error)
        }
        return
        
    }
    func loadImageData(indexPaths : [IndexPath]){
        DispatchQueue.global().async {
            for indexPath in indexPaths{
                let item = self.cellData_un[indexPath.row]
                let thumb = item.thumbUrl
                
                let imgUrl = URL(string : thumb)
                
                
                if  (self.cellData_un[indexPath.row].thumbData == nil){
                    //print ("thumb data load")
                    guard let data  : Data = try? Data(contentsOf: imgUrl!) else{
                        return
                    }
                    //self.cellData_un[indexPath.row].thumbData = try? Data(contentsOf: imgUrl!)
                    self.cellData_un[indexPath.row].thumbData = data
                }
                guard let d = self.cellData_un[indexPath.row].thumbData else{
                    return
                }
                DispatchQueue.main.async{
                    if let c = self.imgCollectionView.cellForItem(at: indexPath) as? ImgCollectionViewCell {
                        c.setImg(i: UIImage(data: d)!)
                    }
                    //self.imgCollectionView.reloadItems(at: [indexPath])
                    //self.imgCollectionView.reloadData()
                    /*if (c != nil){
                    }else{
                    }
 */
                    
                }
            }
            //self.imgCollectionView.reloadItems(at: indexPaths)
            
        }
        
    }
    
    func moreImages(){
        if (currentQueryStr == "" ){
            viewModel.request(type: .getImages , page: self.page + 1, perPage: self.perPage, callback: .getImagesCompletion(callback: self.requestCallback) , errorCallback: self.errorCallback )
        }else{
            if ( self.totalPages != nil && self.page < self.totalPages!){
                
                viewModel.request(type: .search(queryString: self.currentQueryStr) , page: self.page + 1 , perPage: self.perPage, callback: .searchCompletion(callback: self.requestCallbackBySearch) , errorCallback: self.errorCallback )
                
            }
            
        }
    }
}

extension ViewController {
    func registKeyboardNoti(){
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
}
extension ViewController : CallbackProtocol{
    
    func callbackAfterDismiss(indexPath : IndexPath){
        self.imgCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
        self.imgCollectionView.reloadItems(at: [indexPath])
        
    }
    
    
    
}

extension ViewController : CelldataHandler{
    func getCellData() -> [UnsplashData] {
        return self.cellData_un
    }
    
}

extension ViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == self.cellData_un.count - 1){
            moreImages()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = cellData_un[indexPath.row]
        let id = item.id
        
        guard let vc = (self.storyboard?.instantiateViewController(withIdentifier: "detailviewcontroller"))! as? DetailViewController else{
            return
        }
        vc.setId(id : id)
        vc.setCellDataHandler(handler: self)
        vc.setCallback(c: self)
        vc.setCurrentIndexPath(indexPath: indexPath)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    
}
extension ViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cellData_un.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let imgCell = imgCollectionView.dequeueReusableCell(withReuseIdentifier:"imgcell", for: indexPath) as? ImgCollectionViewCell  else{
            return UICollectionViewCell()
        }
        //let thumb = self.cellData_un[indexPath.row].thumbUrl
        
        //let imgUrl = URL(string : thumb)
        if  (self.cellData_un[indexPath.row].thumbData != nil){
            guard let d = self.cellData_un[indexPath.row].thumbData else{
                return imgCell
            }
            imgCell.setImg(i: UIImage(data: d)!)
            
        }
        
        return imgCell
    }
}
extension ViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtQuery.resignFirstResponder()
        //print(txtQuery.text)
        
        self.currentQueryStr = self.txtQuery.text!
        cellData_un.removeAll()
        self.imgCollectionView.reloadData()
        //print("celldata_un : \(cellData_un.count)" )
        if (self.txtQuery.text != nil && self.txtQuery.text! != ""  ){
            self.page = 0
            self.totalPages = nil
            viewModel.request(type: .search(queryString: self.currentQueryStr) , page: self.page, perPage: self.perPage, callback: .searchCompletion(callback: self.requestCallbackBySearch) , errorCallback: self.errorCallback)
        }else{
            self.page = 0
            self.totalPages = nil
            viewModel.request(type: .getImages , page: self.page, perPage: self.perPage, callback: .getImagesCompletion(callback: self.requestCallback) , errorCallback: self.errorCallback)
        }
        return true
    }
    
}
