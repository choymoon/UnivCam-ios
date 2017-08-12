//
//  SelectAlbumVC.swift
//  UnivCam
//
//  Created by BLU on 2017. 8. 10..
//  Copyright © 2017년 futr_blu. All rights reserved.
//

import UIKit

class SelectAlbumVC: UIViewController {
    
    var capturedImage : UIImage?
    
    
    @IBOutlet var selectMessageLabel: UILabel!
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: "UICollectionViewCell")
        }
    }
    
    
    
    var albums = [Album]()
    var selectedAlbums = [Album]()
    var _selectedCells : NSMutableArray = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        albums.removeAll()
        RealmHelper.fetchData(dataList: &albums)
        collectionView.reloadData()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func unwindToCapturedVC(_ sender: UIBarButtonItem) {
        print("no")
        let vc = self.navigationController?.viewControllers[1] as! CapturedImageVC
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func storeImagesToFolder(_ sender: Any) {
        print(capturedImage)
        print(_selectedCells)
        let fileManager = FileManager.default
        for i in _selectedCells {
            let idx = i as! IndexPath
            let imageName = String(describing: Date())
            let imageData =  UIImageJPEGRepresentation(capturedImage!, 1.0)
            try! imageData?.write(to: URL.init(fileURLWithPath: albums[idx.row].url + "/\(imageName)"), options: .atomicWrite)
            folderUpdate(idx: idx)
            
        }
        self.dismiss(
            animated: true,
            completion: nil
        )
    }
    func folderUpdate(idx: IndexPath) {
        guard let indexPath: IndexPath = idx else { return }
        let oldAlbum = albums[indexPath.row]
        let updateAlbum = Album()
        updateAlbum.title = oldAlbum.title
        updateAlbum.id = oldAlbum.id
        updateAlbum.createdAt = oldAlbum.createdAt
        updateAlbum.isFavorite = oldAlbum.isFavorite
        updateAlbum.createdAt = oldAlbum.createdAt
        updateAlbum.url = oldAlbum.url
        updateAlbum.photoCount = oldAlbum.photoCount + 1
        
        let query = "id == \(updateAlbum.id)"
        RealmHelper.updateObject(data: updateAlbum, query: query)
        
    }
    
}

extension SelectAlbumVC: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "UICollectionViewCell"
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! AlbumCell
        let album = albums[indexPath.row]
        
        cell.cameraButton.isHidden = true
        cell.imageView.image = UIImage(named: "back")
        cell.titleLabel.text = album.title
        cell.favoriteButton.isHidden = true
        cell.editButton.isHidden = true
        cell.pictureCountLabel.text = String(album.photoCount) + "장의 사진"
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.lightGray.cgColor
        
        if _selectedCells.contains(indexPath) {
            cell.isSelected=true
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.top)
            cell.backgroundColor = UIColor.lightGray
            cell.checkImage.isHidden = false
        }
        else{
            cell.isSelected=false
            cell.checkImage.isHidden = true
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(_selectedCells)
        _selectedCells.add(indexPath)
        collectionView.reloadItems(at: [indexPath])
        selectMessageLabel.text = "\(_selectedCells.count)개의 사진 선택"
        print("selected")
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        _selectedCells.remove(indexPath)
        collectionView.reloadItems(at: [indexPath])
        if _selectedCells.count == 0 {
            selectMessageLabel.text = "앨범을 선택해주세요"
        } else {
            selectMessageLabel.text = "\(_selectedCells.count)개의 사진 선택"
        }
        print("deselected")
    }
    
}

extension SelectAlbumVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        return CGSize(width: 175.5, height: 243)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(27, 8, 27, 8)
    }
}