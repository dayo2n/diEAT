//
//  ViewController.swift
//  diEAT
//
//  Created by 문다 on 2021/07/28.
//

import UIKit
import FSCalendar
import RealmSwift
import SwiftUI

class ViewController: UIViewController {

    @IBOutlet var calendar: FSCalendar!
    let dateFormatter = DateFormatter()
    @IBOutlet weak var eatLog: UICollectionView!
    
    static let shared = ViewController()
    var didSelectDate = ""
    let realm = try! Realm()
    var logs: Results<LogData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalendar()
        didSelectDate = dateFormatter.string(from: Date())
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(documentsDirectory)
        
        // set EatLog
        eatLog.delegate = self
        eatLog.dataSource = self
        
        let nibName = UINib(nibName: "EatLogCollectionViewCell", bundle: nil)
        eatLog.register(nibName, forCellWithReuseIdentifier: "EatLogCollectionViewCell")
        DispatchQueue.main.async {
            self.eatLog.reloadData()
        }
        
        logs = realm.objects(LogData.self)
    }
    
    // 로그 기록 후 돌아오면
    @IBAction func unwindAfterSave(segue:UIStoryboardSegue) {
    }
    
    // segue 전에 다음 컨트롤러로 정보를 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddEatLogViewController {
            guard let vc = segue.destination as? AddEatLogViewController else { return }
                    vc.didSelectDate = self.didSelectDate
        }
    }
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let selectedDateLogs = logs.filter("date == '\(didSelectDate)'")
        return selectedDateLogs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EatLogCollectionViewCell", for: indexPath) as! EatLogCollectionViewCell
        
        let selectedDateLogs = logs.filter("date == '\(didSelectDate)'")
        let log = selectedDateLogs[indexPath.row]
//          let log = logs[indexPath.row]
        cell.eatImage.image = loadImageFromDocumentDirecory(imgName: "\(log._id).png")
        cell.eatLabel.text = log.time
        return cell
    }
    
    // 아래는 셀들의 사이즈, 간격을 조정해주는 코드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // 이거는 인스타처럼 셀이 세개씩 보이게 해주는 코드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 4) / 3
            
        return CGSize(width: width, height: width)
    }
}


// calendar
extension ViewController : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    
    private func setCalendar() {
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        calendar.delegate = self
        calendar.dataSource = self
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(dateFormatter.string(from: date))
        didSelectDate = dateFormatter.string(from: date)
        print(didSelectDate)
        DispatchQueue.main.async {
            self.eatLog.reloadData()
        }
    }
    
    // 각 날짜의 border color 설정. 옅은 회색을 줘서, 칸처럼 보이게.
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        
        return UIColor.borderColor()
    }
    
    func loadImageFromDocumentDirecory(imgName: String) -> UIImage? {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDominMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDominMask, true)
        
        if let directoryPath = path.first{
            let imgURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imgName)
            return UIImage(contentsOfFile: imgURL.path)
        }
        return nil
    }
}
