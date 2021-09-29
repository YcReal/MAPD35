//
//  ViewController.swift
//  NoteApp
//
//  Created by Yancheng Lin on 2021/5/28.
//
import CoreData
import UIKit
import StoreKit
import MessageUI
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds

//多型 : 多個型態
class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate ,NoteViewControllerDelegate, UISearchResultsUpdating, MFMailComposeViewControllerDelegate, GADBannerViewDelegate{
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var data: [Note] = [] // All data, searchcontroller isActive = false
    var filteredData: [Note] = []// Filtered data, searchcontroller isActive = true
    
    var searchController = UISearchController(searchResultsController: nil)
    var bannerView: GADBannerView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        /*112233
        //準備資料，10筆假的資料，『 按照順序 』顯示在畫面上
        for i in 0..<10 {
            let note = Note()
            note.text = "Note \(i)"
            self.data.append(
        }*/
        //NotificationCenter.default.addObserver(self, selector: #selector(finishUpdate(notification:)), name: .noteUpdate, object: nil)
        //self.loadFromFile()
        self.queryFromDB()
        //新addNote 刪commitediting 改delegate 查
        
    }
    /*
    @objc func finishUpdate(notification: Notification) {
        if let note = notification.userInfo?["note"] as? Note {
            if let index = self.data.firstIndex(of: note) {
                //如果有找到位置
                //根據位置更新畫面上的cell
                let indexPath = IndexPath(item: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    deinit {
        //在被記憶體清除前，移除通知訂閱
        NotificationCenter.default.removeObserver(self)
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        //delegate,
        self.tableView.dataSource = self//也可以透過storyboard做設定
        self.tableView.delegate = self//也可以透過storyboard做設定
        self.navigationItem.title = NSLocalizedString("List", comment: "List")
        //編輯按鈕，自動切換Edit <-> Done，支援多國語系，被按時會呼叫setEditing:animated
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        //self.tabBarItem
        //self.tableView.separatorStyle = .none
        
        //self.topConstraint.constant = 100 //原本是top，間距是0
        
        self.navigationItem.searchController = self.searchController
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        
        ATTrackingManager.requestTrackingAuthorization { status in
            
            DispatchQueue.main.async {
                self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
                self.bannerView?.translatesAutoresizingMaskIntoConstraints = false
                self.bannerView?.adUnitID = "ca-app-pub-3940256099942544/2934735716"
                    //"ca-app-pub-3940256099942544/2934735716"
                    //"ca-app-pub-1922580867074078/6108463108" // 廣告編號
                self.bannerView?.rootViewController = self
                self.bannerView?.delegate = self
                self.bannerView?.load(GADRequest())
            }
            
           

        }
    }
    /*
    override func viewDidAppear(_ animated: Bool) {
        if let scene = self.view.window?.windowScene {
        SKStoreReviewController.requestReview(in: scene)
        }
    }*/

    @IBAction func support(){
            if ( MFMailComposeViewController.canSendMail()){
                let alert = UIAlertController(title: "", message: "We want to hear from you, Please send us your feedback by email in English or Chinese", preferredStyle: .alert)
                let email = UIAlertAction(title: "email", style: .default, handler:
                { (action) -> Void in
                    let mailController = MFMailComposeViewController()
                    mailController.mailComposeDelegate = self
                    mailController.title = "I have question"
                    mailController.setSubject("I have question")
                    let version = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString")
                    let product = Bundle.main.object(forInfoDictionaryKey:"CFBundleName")
                    let messageBody = "<br/><br/><br/>Product:\(product!)(\(version!))"
                    mailController.setMessageBody(messageBody, isHTML: true)
                    mailController.setToRecipients(["support@yoursupportemail.com"])
                    self.present(mailController, animated: true, completion: nil)
                    })
                alert.addAction(email)
                self.present(alert, animated: true, completion: nil)
            }else{
                    //alert user can't send email
            }
        }
    
    @IBAction func upload(_ sender: Any) {
        
        [][0]
        
        let item = sender as! UIBarButtonItem
        //customview可以改變 item的圖示
        let indicatorView = UIActivityIndicatorView(style: .medium)
        item.customView = indicatorView
        indicatorView.startAnimating()//開始旋轉
        //模擬網路下載，需要5秒
        //async: 非同步，括號內的程式，什麼時候被執行是未知的
        DispatchQueue.global().async {//放在這個block中的程式會在背景(非Thread 1 )執行
            Thread.sleep(forTimeInterval: 5)//暫停程式5秒時間
            //假設下載完了，回復到原本按鈕的樣子
            DispatchQueue.main.async {
                item.customView = nil//如果不是在Thread 1 上執行，就會出現以下的錯誤，修正的方式，丟回main Queue執行，main Queue 會保證該行程式會在Thread 1 上執行。
            }
        }
    
        //在5秒內，畫面是卡死的，不能動，因為執行的程式是Thread 1
        //重點是 : 執行長時間的作業，不能放在Thread 1 上執行。
        //Global Queue的作法會把程式放在背景執行緒中執行
        //Main Queue會把程式放在主要執行緒Thread 1 中執行
        //reason: 'Modifications to the layout engine must not be performed from a background thread after it has been accessed from the main thread.'
        //表示你今天更動畫面，但在非Thread 1 執行，所以會有錯誤的警告
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userName = UserDefaults.standard.string(forKey: "userName")
        if userName == nil {
        let alertController = UIAlertController(title: nil, message: "請輸入名字", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "請問大名"
        }
            let action = UIAlertAction(title: "Save", style: .default) { action in
            //取得textfield中的值
            if let input = alertController.textFields?[0].text {
                UserDefaults.standard.set(input, forKey: "userName")
                UserDefaults.standard.synchronize()
            }
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
        } else {
            print("登入使用者為\(userName!)")
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: true)
        
    }
    /*
    @IBAction func edit(_ sender: Any) {
        
        //self.tableView.isEditing = !self.tableView.isEditing
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        
        
    }*/
    
    @IBAction func addNote(_ sender: Any) {
        
        if let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "noteVC")as? NoteViewController {
            
            let naviC = UINavigationController(rootViewController: noteVC)
            noteVC.delegate = self
            
            self.present(naviC, animated: true, completion: nil)
            //present 是整組的 controller 為 navigationController，而NoteViewController 是他的第一組controller
        }
      
        /*
        let moc = CoreDataHelper.shared.managedObjectContext()
        //let note = Note()
        let note = Note(context: moc) //insert, awakeFromInsert
        note.text = "new Note.."
        CoreDataHelper.shared.saveContext()//把Note資料存到sqlite
        //1.先加到self.data中
        //self.data.append(note) //note 1, note 2 ,note 3
                               //    [0]     [1]     [2]
                                                    //== 3 - 1
        self.data.insert(note, at: 0)//new note ,note 1, note 2 ,note 3
        //self.writeToFile()
        //2.再通知畫面進行更新
        //let indexPath = IndexPath(row: self.data.count - 1, section: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        */
    }
    //MARK: Archiving
    func writeToFile() {
        //
        let home = URL(fileURLWithPath: NSHomeDirectory())//利用URL物件組路徑
        let doc = home.appendingPathComponent("Documents")//Documents 不要拼錯
        let filePath = doc.appendingPathComponent("notes.archive")
        do {
            //將data陣列，轉成Data型式（二進位資料）
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.data, requiringSecureCoding: false)
            try data.write(to: filePath, options: .atomic)
        } catch {
            print("error while saving to file \(error)")
        }
    }

    func loadFromFile() {
        let home = URL(fileURLWithPath: NSHomeDirectory())//利用URL物件組路徑
        let doc = home.appendingPathComponent("Documents")//Documents 不要拼錯
        let filePath = doc.appendingPathComponent("notes.archive")
        do {
            let data = try Data(contentsOf: filePath)//載入成Data (二進位資料)
            if let arrayData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Note] {
                self.data = arrayData//轉成功就放到self.data裡
            }
        } catch  {
            print("error while fetching data array \(error)")
            self.data = []//有任何錯誤,空陣列
        }
    }
    //MARK: Core Data
    func queryFromDB () {
        let moc = CoreDataHelper.shared.managedObjectContext()
        
        let request = NSFetchRequest<Note>(entityName: "Note")//設定查詢得Entity(table) //select * from Note order by xxx 
        //let predicate = NSPredicate(format: "text contains[cd] %@", "note")//sql where 條件
        //request.predicate = predicate
        moc.performAndWait {
            do {
                let result = try moc.fetch(request)//送到DB(sqlite)做查詢
                self.data = result
            } catch {
                print("error query db \(error)")
                self.data = []
            }
        }
    }
    
    //MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        //optional:不實作，預設值就是一個section
        return 1
    }
    //請問section = 0有幾筆資料
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchController.isActive { // search model, filteredData
            return self.filteredData.count
        } else {
        return self.data.count//10
        }
    }
    
    
    //請每一筆長的像什麼樣子，顯示在畫面上
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        var cell : UITableViewCell
        if indexPath.row % 2 == 0 {
            //奇數
            cell = tableView.dequeueReusableCell(withIdentifier: "evencell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        }
        */
        //let cell = UITableViewCell(style: .default, reuseIdentifier: "aaa")
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        /*guard let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as? NoteCell
            else{
            fatalError()
        }*/
        
        //let note = self.data[indexPath.row] //取得相對應位置的note物件，畫面上第1=陣列中的第一筆
        
        let note = self.searchController.isActive ? self.filteredData[indexPath.row] : self.data[indexPath.row]
        /*if self.searchController.isActive {
            note = self.filteredData[indexPath.row]
        } else {
            note = self.data[indexPath.row]
        }*/
        
        //cell.noteLabel.text = note.text
        //cell.showsReorderControl = true
        cell.textLabel?.text = note.text
        let now = Date()
        /*
        // 預設作法，百分之99%用這種
        cell.detailTextLabel?.text = DateFormatter.localizedString(from: now, dateStyle: .long, timeStyle: .short)
        */
        
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .republicOfChina)// 民國日曆
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateFormatter.calendar = calendar // 設定為民國曆
        cell.detailTextLabel?.text = dateFormatter.string(from: now)
        
        cell.detailTextLabel?.text = NumberFormatter.localizedString(from: -1234.56, number: .currencyAccounting)
        
        cell.imageView?.image = note.thumbnailImage()
        cell.showsReorderControl = true
        cell.accessoryType = .disclosureIndicator
        //cell.accessoryView = UISwitch()// custom setting
        
        return cell
        
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {//紅色刪除，另一種是綠色加號
            //1.刪除data中的資料
            let note = self.searchController.isActive ? self.filteredData.remove(at: indexPath.row) : self.data.remove(at: indexPath.row)
            
            if let index = self.data.firstIndex(of: note) {//補刪除self.data中的資料
                self.data.remove(at: index)
            }
            
            let moc = CoreDataHelper.shared.managedObjectContext()
            moc.performAndWait {
                moc.delete(note)//delete from table ....
            }
            CoreDataHelper.shared.saveContext() //commit
            //archiving delete
            /*if let imageName = note.imageName {
                let home = URL(fileURLWithPath: NSHomeDirectory())//利用URL物件組路徑
                let doc = home.appendingPathComponent("Documents")//Documents 不要拼錯
                let filePath = doc.appendingPathComponent(imageName)//利用noteID做檔案名稱.jpg
                try? FileManager.default.removeItem(at: filePath) //移除檔案
            }*/
            //self.writeToFile()
            //2.通知畫面更新
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    /* //設定哪個位置可以移動
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row % 2 == 0 {
            return false
        }
        return true
    }*/
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //調整data中的note的位置，從sourceIndexPath 到 destinationIndexPath
        let note = self.data.remove(at: sourceIndexPath.row)//先從原本的位置移出來
        //再移到最後的位置
        self.data.insert(note, at: destinationIndexPath.row)
        
        //不用再更新畫面，因為畫面已經被使用者更新
    }
    
    //MARK: UITableViewDelegate
    //使用者點選某筆資料時會被呼叫
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("選\(indexPath.row)")
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        //透過storyboard產生下一組畫面
        /*
        if let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "noteVC"){
        //let noteVC = NoteViewController //此方法是錯誤的，不能自己初始需透過storyboard
        self.navigationController?.pushViewController(noteVC, animated: true)
        self.show()
        }
        */
        
    }
    
    /*//可調整每一個Row高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            return 50
        }
        return 80
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteSegue" {
            //前往NoteVC
            if let noteVC = segue.destination as? NoteViewController,
               let indexPath = self.tableView.indexPathForSelectedRow
            
            {
                //print("indexPath: \(indexPath)")
                let note = self.searchController.isActive ? self.filteredData[indexPath.row] : self.data[indexPath.row]
                noteVC.currentNote = note
                noteVC.delegate = self
            }
        }
    }
    //被NoteVC按下done時呼叫
    func didFinishUpdata(note: Note) {
        print("note updated \(note.text!)")
        //self.writeToFile()
        CoreDataHelper.shared.saveContext()
        //更新畫面
        //找到被修改這筆note在data中的位置,如果是搜尋畫面要找filteredData,其他才找self.data
        if let index = self.searchController.isActive ? self.filteredData.firstIndex(of: note) : self.data.firstIndex(of: note) {
            //print("index: \(index)")
            //如果有找到位置
            //根據位置更新畫面上的cell
            let indexPath = IndexPath(item: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            //新增的情況
            self.data.insert(note, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    //MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        // key search 字會被呼叫的delegate方法
        // 根據使用者輸入的字，過濾資料放到filteredData
        generateFilterData()
        // 更新tableView
        self.tableView.reloadData()
        
    }
    func generateFilterData() {
        
        if self.searchController.isActive, let text = self.searchController.searchBar.text {
            //根據使用者輸入的字，過濾資料放到filterdData, self.data(全部) -> self.filteredData
            self.filteredData = self.data.filter { n in
                if let content = n.text {
                    // 轉成小寫做比較
                    return content.lowercased().contains(text.lowercased())//true表示符合資料
                }
                return false
            }
        } else {
            self.filteredData = []
        }
        
        
        
    }
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            print("user cancelled")
        case .failed:
            print("user failed")
        case .saved:
            print("user saved email")
        case .sent:
            print("email sent")
        @unknown default:
            print("other options")
        }
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: - GADBannerViewDelegate
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        //self.tableView.tableHeaderView = bannerView
        if bannerView.superview == nil {
            // 第一次廣告進來
            self.view.addSubview(bannerView)
            self.topConstraint.isActive = false // 關閉tableView上緣的條件
            // 廣告上緣貼齊safearea的上緣
            bannerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            // 廣告下緣貼齊tableView的上緣
            bannerView.bottomAnchor.constraint(equalTo: self.tableView.topAnchor).isActive = true
            // 廣告左右緣貼齊self.view的左右
            bannerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            bannerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        }
        
    }
}
/*
//定義通知名稱
extension Notification.Name {
    static let noteUpdate = Notification.Name("noteUpdated")
    
}
*/







