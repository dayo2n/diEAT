//
//  AddEatLogViewController.swift
//  diEAT
//
//  Created by 문다 on 2021/11/04.
//

import UIKit
import RealmSwift

class AddEatLogViewController: UIViewController {
    
    let imgPicker = UIImagePickerController()
    var selectedTime = "Breakfast"
    let realm = ViewController.shared.realm
    var didSelectDate = ""
    
    @IBOutlet weak var eatImgView: UIImageView!
    @IBAction func addImgBtn(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Select Image", message: "Photo or Camera", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: UIAlertAction.Style.default, handler: {(action) in self.openLibrary()}))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: {(action) in self.openCamera()}))
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openLibrary(){ // 사진보관함 오픈
        imgPicker.sourceType = .photoLibrary
        present(imgPicker ,animated: false, completion: nil)
    }
    func openCamera(){ // 카메라 오픈
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
        imgPicker.sourceType = .camera
        present(imgPicker, animated: false, completion: nil)
        }else{ // 시뮬레이터로 카메라 동작 불가
            print("Camera is not available on simulator, plz check on the iPhone")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPicker.delegate = self
        
//        eatDescription.layer.borderWidth = 0.5
//        eatDescription.layer.borderColor = UIColor.lightGray.cgColor
    }
    

    
    @IBAction func setTime(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            selectedTime = "Breakfast"
        }else if sender.selectedSegmentIndex == 1 {
            selectedTime = "Lunch"
        }else if sender.selectedSegmentIndex == 2 {
            selectedTime = "Dinner"
        }else if sender.selectedSegmentIndex == 3 {
            selectedTime = "etc"
        }
        print(didSelectDate)
        print("selectedTime is \(selectedTime)")
    }
    
    //log를 렘에 새로 추가하는 메소드
    func addNewLog(_ time:String,_ date:String) -> LogData{
        let newLog = LogData()

        newLog.time = time
        newLog.date = date
        return newLog
    }

    func save() {
        let newLog = self.addNewLog(selectedTime, didSelectDate)

        try! realm.write{
            realm.add(newLog)
            saveImgToDocumentDirectory(imgName: "\(newLog._id).png", img: eatImgView.image!)
        }
        print("저장됨")
        print(newLog)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SavedLog"{
            guard segue.destination is ViewController else { return }
            self.save()
        }
    }
}

extension AddEatLogViewController : UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    // 이미지 경로를 가져와서 UIImageView에 띄우고 창 내림(dismiss)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            eatImgView.image = image
            print(info)
        }
        dismiss(animated: true, completion: nil)
      
    }
    
    func saveImgToDocumentDirectory(imgName: String, img: UIImage){
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let imgURL = documentDirectory.appendingPathComponent(imgName)
        guard let data = img.pngData() else{
            print("압축 실패")
            return
        }
        if FileManager.default.fileExists(atPath:  imgURL.path){
            do{
                try FileManager.default.removeItem(at: imgURL)
                print(" img removed, 덮어쓰기 ")
            } catch{
                print(" failed to remove img ")
            }
        }
        do {
            try data.write(to: imgURL)
            print(" success to save img into doc")
        } catch {
            print(" faild to save img into doc")
        }
    }
}
