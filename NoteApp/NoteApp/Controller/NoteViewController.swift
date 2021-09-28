//
//  NoteViewController.swift
//  NoteApp
//
//  Created by Yancheng Lin on 2021/6/1.
//
import GoogleMobileAds
import UIKit

 protocol NoteViewControllerDelegate : AnyObject  {
     func didFinishUpdata(note: Note)
}

class NoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADFullScreenContentDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    //從listVC傳過來使用者選到的note物件
    var currentNote : Note? // 新增進到NoteVC時會是空值，更新從清單進來的才會有值
    weak var delegate : NoteViewControllerDelegate? //從listVC傳自己過來到listVC屬性
    
    var isNewImage : Bool = false
    
    var imageRatioConstraint : NSLayoutConstraint!
    
    var interstital: GADInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textView.text = self.currentNote?.text
        self.imageView.image = self.currentNote?.image()

        self.imageView.layer.borderWidth = 10
        self.imageView.layer.borderColor = UIColor.blue.cgColor
        self.imageView.layer.cornerRadius = 10
        self.imageView.layer.shadowColor = UIColor.darkGray.cgColor
        self.imageView.layer.shadowOpacity = 0.8
        self.imageView.layer.shadowOffset = CGSize(width: 10, height: 10)
        print("toolbar \(self.toolbar.intrinsicContentSize)")//CGSize,w h
        //高 = 寬*0.75(4:3)
        
        self.imageRatioConstraint = self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 0.75)
        if self.traitCollection.verticalSizeClass == .regular {//直向 h:R
        self.imageRatioConstraint.isActive = true
        }
        
        // 新增的時候，左上角要自己加上取消按鈕
        if self.currentNote == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel) )
            self.textView.text = NSLocalizedString("new.note", comment: "New Note")// comment 只是說明這個key，實際上沒有作用
        }
        
        // 載入插頁式廣告
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-1521801495507235/3326580616", request: GADRequest()) { [weak self] ad, error in
            
            if let e = error {
                print("error loading ads \(e)")
                return
            }
            
            guard let adview = ad else { return }
            self?.interstital = adview
            self?.interstital?.fullScreenContentDelegate = self
            print("插頁式廣告已載入")
        }
        
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        //如果是直向 H:R，4:3條件是要的，其它的情況不需要4:3條件
        if newCollection.verticalSizeClass == .regular {
            self.imageRatioConstraint.isActive = true
        } else {
            self.imageRatioConstraint.isActive = false
        }
        self.toolbar.invalidateIntrinsicContentSize()
    }
    
    
    
    //ctrl + 6 快選方法
    //移動到某行 : cmd + l:行數最少是1
    @IBAction func done(_ sender: Any) {
        
        let note: Note
        if self.currentNote != nil {
            //修改時會執行的，note = self.currentNote
            note = self.currentNote!
        } else {
            //新增時，要產生Note資料
            note = Note(context: CoreDataHelper.shared.managedObjectContext())
        }
      
        note.text = self.textView.text
        //self.currentNote.image = self.imageView.image
        
        if let image = self.imageView.image  , self.isNewImage {
            let home = URL(fileURLWithPath: NSHomeDirectory())//利用URL物件組路徑
            let doc = home.appendingPathComponent("Documents")//Documents 不要拼錯
            let filePath = doc.appendingPathComponent("\(note.noteID).jpg")//利用noteID做檔案名稱.jpg
            if let imageData = image.jpegData(compressionQuality: 1) {
                do {
                    try imageData.write(to: filePath, options: .atomic)//寫到指定的路徑filePath
                    note.imageName = "\(note.noteID).jpg"
                }catch {
                    print("照片寫擋有錯 \(error)")
                }
            }
        }
        self.delegate?.didFinishUpdata(note: note)
        //NotificationCenter.default.post(name: .noteUpdate, object: nil, userInfo: ["note" : self.currentNote!])
        if self.currentNote == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            // update
            if let adview = self.interstital {
                // 廣告已經載入，顯示廣告
                adview.present(fromRootViewController: self)
            } else {
            self.navigationController?.popViewController(animated: true) //push(show) <-> pop, 沒有廣告就照原路回去
            }
        }
        
    }
    
    @IBAction func camera(_ sender: Any) {
        
        let pickerController = UIImagePickerController()//iOS 13 14都不需權限，假設 : 12是要的
        pickerController.sourceType = .savedPhotosAlbum // 圖庫，最近拍照清單
        //pickerController.sourceType = .photoLibrary //相簿
        //pickerController.sourceType = .camera //相機，實機才能測
        pickerController.delegate = self
        self.present(pickerController, animated: true, completion: nil)//present <-> dismiss
    }
    //MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage { //jpeg(照片,有方向性) , png(icon)
            
            self.imageView.image = image
            self.isNewImage = true
        }
        self.dismiss(animated: true, completion: nil)//把選照片視窗關閉
    }
    
   //MARK: - GADFullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        // 使用者按下了x, 沒有興趣
        // 回到前一頁
        self.navigationController?.popViewController(animated: true)
        
    }
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        // 使用者點擊廣告，恭喜你賺錢
        self.dismiss(animated: true) {
            //廣告已經dismiss掉，回到前一頁
            self.navigationController?.popViewController(animated: true)
        }
    }

}
