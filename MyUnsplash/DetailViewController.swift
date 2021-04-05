//
//  DetailViewController.swift
//  MyUnsplash
//
//  Created by kisoo Um on 2020/11/17.
//  Copyright © 2020 kisoo Um. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var onceOnly = false
    var dataHandler : CelldataHandler?
    var callback : CallbackProtocol?
    var id : String = ""
    var currentIndexPath : IndexPath?
    @IBOutlet weak var imgCollectionView: UICollectionView! {
        didSet{
            self.imgCollectionView.dataSource = self
            self.imgCollectionView.delegate = self
            
        }
    }
    lazy var cellData : [UnsplashData] = { [weak self] ()->[UnsplashData] in
        guard let self = self else{
            return [UnsplashData]()
        }
        guard self.dataHandler != nil  else{
            return [UnsplashData]()
        }
        return self.dataHandler!.getCellData()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registSwipeDown()
        self.imgCollectionView.performBatchUpdates(nil, completion: {
            (result) in
            let indexPaths = self.imgCollectionView.indexPathsForVisibleItems
            self.loadImageData(indexPaths: indexPaths)
        })
    }
    func loadImageData(indexPaths : [IndexPath]){
        DispatchQueue.global().async {
            for indexPath in indexPaths{
                let item =  self.cellData[indexPath.row]
                let regular = item.regularUrl
                    
                let imgUrl = URL(string : regular)
                if  (self.cellData[indexPath.row].regularData == nil){
                    
                    guard let data : Data = try? Data(contentsOf: imgUrl!) else {
                        return
                    }
                    
                    //self.cellData[indexPath.row].regularData = try! Data(contentsOf: imgUrl!)
                    self.cellData[indexPath.row].regularData = data
                }
                guard let d = self.cellData[indexPath.row].regularData else{
                    return
                }
                DispatchQueue.main.async {
                    let c = self.imgCollectionView.cellForItem(at: indexPath) as? DetailImgCollectionviewCellCollectionViewCell
                    if (c != nil){
                        c?.setImg(i: UIImage(data: d)!)
                        //self.imgCollectionView.reloadItems(at: [indexPath])
                    }
                    
                }
            }
        }
        
    }
    func registSwipeDown(){
        let swipeDown = UISwipeGestureRecognizer()
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        swipeDown.addTarget(self, action: #selector(swipe(sender:)))
    }
    
    deinit {
        let indexPaths = imgCollectionView.indexPathsForVisibleItems
        self.callback?.callbackAfterDismiss(indexPath: indexPaths[0])
        
    }
    
    @IBAction func clkClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    func setCurrentIndexPath(indexPath : IndexPath){
        self.currentIndexPath = indexPath
    }
    func setId(id : String){
        self.id = id
    }
    func setCellDataHandler(handler : CelldataHandler){
        self.dataHandler = handler
    }
    func setCallback (c : CallbackProtocol ){
        self.callback = c
    }
    @objc func swipe(sender : UISwipeGestureRecognizer){
        switch sender.direction {
        case .down:
            print("swipe down")
            self.dismiss(animated: true, completion: nil)
        default:
            print("swipe default")
        }
    }

}
extension DetailViewController : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let indexPaths = self.imgCollectionView.indexPathsForVisibleItems
        self.loadImageData(indexPaths: indexPaths)
    }
    
}
extension DetailViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
            self.imgCollectionView.scrollToItem(at: currentIndexPath!, at: .left, animated: false)
            onceOnly = true
        }
        
        
    }
}
extension DetailViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellData.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imgCell = imgCollectionView.dequeueReusableCell(withReuseIdentifier:"detailimgcell", for: indexPath) as? DetailImgCollectionviewCellCollectionViewCell else{
            return UICollectionViewCell()
        }
        DispatchQueue.global().async {
            if (self.cellData[indexPath.row].regularData != nil){
                guard let d = self.cellData[indexPath.row].regularData else{
                    return
                }
                self.setImage(imgData: d, cell: imgCell)
            }
        }
        return imgCell
    }
    
    func setImage( imgData : Data, cell : DetailImgCollectionviewCellCollectionViewCell){
        DispatchQueue.main.async {
            cell.setImg(i : UIImage(data: imgData)!)
        }
    }
}

extension DetailViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = self.imgCollectionView.bounds
        return CGSize(width : size.width, height: size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
}

