//
//  ResultViewController.swift
//  ruler
//
//  Created by Portia Wang on 8/9/17.
//  Copyright © 2017 Portia Wang. All rights reserved.
//

import UIKit
import CoreMotion
class ResultViewController: UIViewController {
    
    
    //MARK: - Properties
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tapToMeasureButton: UIButton!
    @IBOutlet weak var remeasureButton: UIButton!
    let motionManager = CMMotionManager()
    var CMValue = 0.0
    var dropTimeSeconds = 0.0
    var spike = CMAccelerometerData()
    //MARK: - Lifecycles
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.addTarget(self, action: #selector(ResultViewController.changeUnit), for: .valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.backgroundView.isHidden = true
        self.tapToMeasureButton.isEnabled = true
        self.tapToMeasureButton.isHidden = false
        segmentControl.isHidden = true
        remeasureButton.isHidden = true
        saveButton.isHidden = true
        unitLabel.isHidden = true    }
    
    
    //MARK: - Functions
    
    
    func changeUnit(){
        if segmentControl.selectedSegmentIndex == 0{
            self.valueLabel.text = String(roundtoSecond(num:CMValue))
            self.unitLabel.text = "CM"
        }
        if segmentControl.selectedSegmentIndex == 1{
            self.valueLabel.text = String(roundtoSecond(num:CMValue/100.0))
            self.unitLabel.text = "M"
        }
        if segmentControl.selectedSegmentIndex == 2{
            self.valueLabel.text = String(roundtoSecond(num:CMValue/2.54))
            self.unitLabel.text = "INCH"
        }
        if segmentControl.selectedSegmentIndex == 3{
            self.valueLabel.text = String(roundtoSecond(num:CMValue/30.48))
            self.unitLabel.text = "FOOT"
        }
        if segmentControl.selectedSegmentIndex == 4{
            let ft = Int(CMValue/30.48)
            let inch = Double(CMValue/2.54 - ((Double(ft)*12)))
            
            self.valueLabel.text = String(ft) + "ft"
            self.unitLabel.text = String(Double(Int(inch*10))/10) + "in"
        }
    }
    
    @IBAction func historyButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
        })
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SaveViewController") as? SaveViewController
        popOverVC?.CMValue = CMValue
        popOverVC?.unit = self.unitLabel.text!
        popOverVC?.value = self.valueLabel.text!
        self.segmentControl.isHidden = true
        self.addChildViewController(popOverVC!)
        popOverVC?.view.frame = self.view.frame
        self.backgroundView.isHidden = false
        popOverVC?.didMove(toParentViewController: self)
        
        UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: { _ in
            self.view.addSubview((popOverVC?.view)!)
        }, completion: nil)
    }
    func stabilizeAccerlerometer() {
        print("stabilizing")
        
    }
    func endTimer(){
        print("drop time: \(dropTimeSeconds)s")
        
        self.CMValue = dropTimeSeconds*dropTimeSeconds*9.81*0.5*100
        print("drop height: \(self.CMValue)s")
        self.backgroundView.isHidden = true
        self.tapToMeasureButton.isHidden = true
        remeasureButton.isHidden = false
        saveButton.isHidden = false
        segmentControl.isHidden = false
        segmentControl.selectedSegmentIndex = 0
        self.unitLabel.text = "CM"
        unitLabel.isHidden = false
        self.valueLabel.text = String(CMValue)
        
        dropTimeSeconds = 0.0
        
    }
    
    @IBAction func measureButtonTapped(_ sender: Any) {
        let timeStartRaw: UInt64 = mach_absolute_time()
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        print("Pre-start Accelereometer Update")
        print("--W--=--W--")
        print("---H-=-H---")
        print("----Y=Y----")
        print("")
        //let timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(ResultViewController.addTimer), userInfo: nil, repeats: true)
        
        motionManager.accelerometerUpdateInterval = 0.0
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let spike = data {
                //print(self.time)
                self.spike = spike
                let magnitude = sqrt(spike.acceleration.y*spike.acceleration.y + spike.acceleration.x*spike.acceleration.x + spike.acceleration.z*spike.acceleration.z)
                
                print("G's: \(magnitude)")
                print("----------")
                
              
                let timeEndRaw = mach_absolute_time()
                
                let elapsedTimeRaw = timeEndRaw - timeStartRaw
                
                let timeSeconds = (Double(elapsedTimeRaw) * Double(info.numer) / Double(info.denom)) / 1_000_000_000.0
                
                print("Time: \(timeSeconds)")
                print("----------")
                
                
                
                
                
                if magnitude >= 3.4 {
                    self.dropTimeSeconds = timeSeconds
                    self.motionManager.stopAccelerometerUpdates()
                    //timer.invalidate()
                    self.endTimer()
                    self.dropTimeSeconds = 0.0
                }
                
                
            } else {
                print("error: data is nil!")
            }
        }
        
    }
    @IBAction func reMeasureButtonTapped(_ sender: Any) {
        viewWillAppear(true)
    }
    
    func roundtoSecond( num: Double) -> Double{
        return (Double(Int(num*100))/100.0)
    }
    
}
