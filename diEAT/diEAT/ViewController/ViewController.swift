//
//  ViewController.swift
//  diEAT
//
//  Created by 문다 on 2021/07/28.
//

import UIKit
import FSCalendar
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var eatLog: UITableView!
    let realm = try! Realm()
    
    var breakfast : [String] = ["그릭요거트", "딸기", "오트밀", "아몬드브리즈"]
    var lunch : [String] = ["두부유부초밥", "팽이버섯구이"]
    var dinner : [String] = ["소고기구이", "구운김치", "아삭이고추", "상추"]
    var etc : [String] = []
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var selectedMeal: UISegmentedControl!
    @IBAction func addButton(_ sender: UIButton, _: UISegmentedControl){
        switch self.selectedMeal.selectedSegmentIndex {
        case 0:
            breakfast.append(String(self.textField.text!))
            self.eatLog.reloadSections(IndexSet(0...0), with: UITableView.RowAnimation.automatic)
        case 1:
            lunch.append(String(self.textField.text!))
            self.eatLog.reloadSections(IndexSet(1...1), with: UITableView.RowAnimation.automatic)
        case 2:
            dinner.append(String(self.textField.text!))
            self.eatLog.reloadSections(IndexSet(2...2), with: UITableView.RowAnimation.automatic)
        case 3:
            etc.append(String(self.textField.text!))
            self.eatLog.reloadSections(IndexSet(3...3), with: UITableView.RowAnimation.automatic)
        default:
            return
        }
        self.textField.text = ""
    }
    
    let cellIdentifier: String = "cell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalendar()
        setEatLog()
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    

    private func setEatLog(){
        eatLog.delegate = self
        eatLog.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        switch section {
        case 0:
            return self.breakfast.count
        case 1:
            return self.lunch.count
        case 2:
            return self.dinner.count
        case 3:
            return self.etc.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        let text : String

        switch indexPath.section {
        case 0:
            text = self.breakfast[indexPath.row]
        case 1:
            text = self.lunch[indexPath.row]
        case 2:
            text = self.dinner[indexPath.row]
        case 3:
            text = self.etc[indexPath.row]
        default:
            text = ""
        }
        cell.textLabel?.text = text

        return cell


    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        switch section {
        case 0:
            return " [ 아침 ] "
        case 1:
            return " [ 점심 ] "
        case 2:
            return " [ 저녁 ] "
        case 3:
            return " [ 기타 ] "
        default:
            return ""
        }
    }
}

extension ViewController : FSCalendarDelegate, FSCalendarDataSource{
    
    private func setCalendar() {
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
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM-dd-YYYY"
        
    }
}
