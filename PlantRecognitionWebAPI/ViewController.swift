//
//  ViewController.swift
//  PlantRecognitionWebAPI
//
//  Created by PaiConor on 2017/5/7.
//  Copyright © 2017年 PaiConorMAPZONE. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ChoosePhoto(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //允许编辑
            picker.allowsEditing = false
            //打开相机
            picker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(picker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    @IBAction func TakePhoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            //创建图片控制器
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //设置来源
            picker.sourceType = UIImagePickerControllerSourceType.camera
            //允许编辑
            picker.allowsEditing = false
            //打开相机
            picker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(picker, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //dismissViewControllerAnimated(true, completion: nil)
        dismiss(animated: true, completion: nil) // 选中图片, 关闭选择器...这里你也可以 picker.dismissViewControllerAnimated 这样调用...但是效果都是一样的...
        
        imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage // 显示图片
        imageView.contentMode = .scaleAspectFit // 缩放显示, 便于查看全部的图片
        
        uploadPicture(image: imageView.image!)
    }

    func uploadPicture(image: UIImage)
    {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let now = Date()
        let picName = formatter.string(from: now) + ".jpg"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        let Boundary:NSString = "*****ABCDE*****"
        let StartBoundary = NSString(format:"--%@",Boundary)
        var EndBoundary = NSString(format:"%@--", StartBoundary)
        let body = NSMutableString()
        
        
        body.appendFormat("%@\r\n",StartBoundary)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(picName)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        
        EndBoundary = NSString(format: "\r\n%@\r\n", EndBoundary)
        let requestData = NSMutableData()
        requestData.append(body.data(using: String.Encoding.utf8.rawValue)!)
        requestData.append(UIImageJPEGRepresentation(image, 0.4)!)
        requestData.append(EndBoundary.data(using: String.Encoding.utf8.rawValue)!)
        
        let req = NSMutableURLRequest(url:NSURL(string: "http://192.168.1.140:5000/upload")! as URL)
        req.httpMethod = "POST"
        req.addValue("multipart/form-data; boundary=*****ABCDE*****", forHTTPHeaderField: "Content-Type")
        
        let task = session.uploadTask(with: req as URLRequest, from: requestData as Data) {
            (data:Data?, response:URLResponse?, error:Error?) -> Void in
            //上传完毕后
            if error != nil{
                print(error!)
            }else{
                print (response as Any)
                let str = String(data: data!, encoding: String.Encoding.utf8)
                //self.lblResult.text = str
                let alertController = UIAlertController(title: "识别结果",message: str, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        task.resume()
        //}
    }
}

