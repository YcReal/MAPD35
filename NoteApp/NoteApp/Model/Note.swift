//
//  Note.swift
//  NoteApp
//
//  Created by Yancheng Lin on 2021/5/28.
//
import UIKit
import Foundation
import CoreData

//NS: NextStep: Steve Job創立公司
//class Note : Equatable {}
//class Note : NSObject , NSCoding  {//Archiving
class Note: NSManagedObject {
    
    /*//Note物件寫到檔案: Dictionary
    func encode(with coder: NSCoder) {
        coder.encode(self.text, forKey: "text")
        coder.encode(self.imageName, forKey: "imageName")
        coder.encode(self.noteID, forKey: "noteID")
    }
    
    required init?(coder: NSCoder) {
        self.text = coder.decodeObject(forKey: "text") as? String
        self.noteID = coder.decodeObject(forKey: "noteID") as! String
        self.imageName = coder.decodeObject(forKey: "imageName") as? String
    }*/
    
    //用來判斷兩個Note物件是否相同
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.noteID == rhs.noteID
    }
    
    @NSManaged var text : String?
    //var image : UIImage? //UIKit
    @NSManaged var noteID : String //UUID
    //只存圖片擋名,不存UIImage
    @NSManaged var imageName : String?
    //@NSManaged var sequence : Int //排序欄位 
    /* comment out by Core Data
    override init(){
        self.noteID = UUID().uuidString
    }*/
    //新增時會呼叫的方法: Note(context:...)
    override func awakeFromInsert() {
        self.noteID = UUID().uuidString
    }
    //刪除時會被呼叫
    override func prepareForDeletion() {
        if let imageName = self.imageName {
            let home = URL(fileURLWithPath: NSHomeDirectory())//利用URL物件組路徑
            let doc = home.appendingPathComponent("Documents")//Documents 不要拼錯
            let filePath = doc.appendingPathComponent(imageName)//利用noteID做檔案名稱.jpg
            //if FileManager.default.fileExists(atPath: filePath.path)
            try? FileManager.default.removeItem(at: filePath) //移除檔案
        }
    }
    
    func image() -> UIImage? {
     
        if let fileName = self.imageName {
            let home = URL(fileURLWithPath: NSHomeDirectory())//利用URL物件組路徑
            let doc = home.appendingPathComponent("Documents")//Documents 不要拼錯
            let filePath = doc.appendingPathComponent(fileName)//利用noteID做檔案名稱.jpg
            return UIImage(contentsOfFile: filePath.path)//path : URL -> String
            
        }
        return nil
    }
    
    func thumbnailImage() -> UIImage? {
        if let image = self.image() {
        let thumbnailSize = CGSize(width:50, height: 50); //設定縮圖大小
        let scale = UIScreen.main.scale //找出目前螢幕的scale，視網膜技術為2.0 //產生畫布，第一個參數指定大小,第二個參數true:不透明(黑色底),false表示透明背景,scale為螢幕scale
        UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
        //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill //最小值MIN會變成UIViewContentModeScaleAspectFit
        let widthRatio = thumbnailSize.width / image.size.width
        let heightRadio = thumbnailSize.height / image.size.height
        let ratio = max(widthRatio,heightRadio)
        let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio);
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: thumbnailSize.width, height:thumbnailSize.height))
            circlePath.addClip()
        image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y:  -(imageSize.height-thumbnailSize.height)/2.0,
        width: imageSize.width,height: imageSize.height)) //取得畫布上的縮圖
        let smallImage = UIGraphicsGetImageFromCurrentImageContext() //關掉畫布
            UIGraphicsEndImageContext()
            return smallImage
        }else{
        return nil; }
    }
}

