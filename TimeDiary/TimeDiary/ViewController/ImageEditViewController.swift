//
//  ImageEditViewController.swift
//  TimeDiary
//
//  Created by 김진영 on 2021/11/18.
//

import UIKit

final class ImageEditViewController: UIViewController {

    static let identifier = "ImageEditViewController"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeStampView: UIView!
    @IBOutlet weak var designView: UIView!
    
    @IBOutlet weak var colorButton1: UIButton!
    @IBOutlet weak var colorButton2: UIButton!
    @IBOutlet weak var colorButton3: UIButton!
    @IBOutlet weak var colorButton4: UIButton!
    @IBOutlet weak var colorButton5: UIButton!
    @IBOutlet weak var colorButton6: UIButton!
    @IBOutlet weak var colorButton7: UIButton!
    @IBOutlet weak var colorButton8: UIButton!
    @IBOutlet weak var colorButton9: UIButton!
    
    @IBOutlet weak var colorWell: UIColorWell!
    

    @IBOutlet weak var fontNameLabel: UILabel!
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    @IBOutlet weak var designCollectionView: UICollectionView!
    
    var selectedImage = UIImage() //앨범, 카메라에서 선택한 사진 전달받을 변수
    private var customView: UIView! //타임스탬프 디자인을 담을 view
    private var stampDesignName = StampDesign.Stamp_1 //디자인 초기값
    private var stampDesignColor = UIColor.white //디자인 색상 초기값
    private var stampFontSizePlus = CGFloat(0) //디자인 폰트 +- 해줄 값
    private var stampDate = Date()
    
    private let fontList = [TimeBearFont.KYOBO_HANDWRITING_2019.rawValue, TimeBearFont.HEIR_OF_LIGHT_BOLD.rawValue, TimeBearFont.KOTRA_HOPE.rawValue, TimeBearFont.ESAMARU_OTF_BOLD.rawValue,
                            TimeBearFont.DUNGGEUNMO.rawValue, TimeBearFont.JEJU_MYEONGJO_OTF.rawValue, TimeBearFont.KOTRA_SONGEULSSI.rawValue]
    private var fontIndex: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigation()
        setScrollView()
        setImageView()
        setColorButton()
        setCollectionView()
        setLabel()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
        
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    private func setNavigation() {
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        
        //네비게이션 바 아이템 setting
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(closeButtonClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(NSLocalizedString("next", comment: "다음으로 이동")), style: .plain, target: self, action: #selector(nextButtonClicked))
    }
    
    private func setScrollView() {
        //ScrollView zoom 관련 설정
        let imageWidth = selectedImage.size.width
        let imageHeight = selectedImage.size.height
        let screenWidth = UIScreen.main.bounds.width - 40
        
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.center = self.timeStampView.center
        
        if imageWidth > imageHeight {
            //scrollView.
            self.scrollView.minimumZoomScale = screenWidth / imageHeight
            self.scrollView.maximumZoomScale = 4
            //print(imageHeight / screenWidth)
        } else {
            //scrollView.
            self.scrollView.minimumZoomScale = screenWidth / imageWidth
            self.scrollView.maximumZoomScale = 4
        }
        self.scrollView.delegate = self
        
        //scrollView 초기 zoom scale 설정
        self.scrollView.zoomScale = scrollView.minimumZoomScale
    }
    
    private func setImageView() {
        //앨범에서 선택한 이미지 띄우기
        self.imageView.image = selectedImage

        //기본 타임 스탬프 디자인 보여주기
        self.stampDesignColor = .white
        
        DispatchQueue.global().async {
            // UI 업데이트 전 실행되는 코드
            DispatchQueue.main.sync {
                // UI 업데이트
                self.designUpdate()
            }
            // UI 업데이트 후 실행되는 코드
        }
    }
    
    private func setColorButton() {
        //컬러 버튼 setting
        setColorButton(button: colorButton1, color: .white)
        setColorButton(button: colorButton2, color: .black)
        setColorButton(button: colorButton3, color: UIColor().blue)
        setColorButton(button: colorButton4, color: UIColor().green)
        setColorButton(button: colorButton5, color: UIColor().yellow)
        setColorButton(button: colorButton6, color: UIColor().orange)
        setColorButton(button: colorButton7, color: UIColor().red)
        setColorButton(button: colorButton8, color: UIColor().pink)
        setColorButton(button: colorButton9, color: UIColor().purple)
        
        colorWell.supportsAlpha = false
        colorWell.addTarget(self, action: #selector(colorWellChanged), for: .valueChanged)
    }
    
    private func setCollectionView() {
        //collection view setting
        designCollectionView.delegate = self
        designCollectionView.dataSource = self
        
        //collection view xib setting
        let nibName = UINib(nibName: DesignCollectionViewCell.identifier, bundle: nil)
        designCollectionView.register(nibName, forCellWithReuseIdentifier: DesignCollectionViewCell.identifier)
        
        DispatchQueue.global().async {
            // UI 업데이트 전 실행되는 코드
            DispatchQueue.main.sync {
                //collection view flow layout 설정
                let layout = UICollectionViewFlowLayout()
                let spacing: CGFloat = 10
                let width = UIScreen.main.bounds.width - (spacing * 4) - 40
                layout.itemSize = CGSize(width: width / 3, height: (width / 3))
                
                //print(UIScreen.main.bounds.width, width / 3, width / 3)
                layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
                layout.minimumLineSpacing = spacing
                layout.minimumInteritemSpacing = spacing

                //디바이스별로 하단에 남는 공간의 정도에 따라 .horizontal, .vertical 정하기
                if self.designCollectionView.frame.height >= (width / 3) * 2 {
                    layout.scrollDirection = .vertical
                } else {
                    layout.scrollDirection = .horizontal
                }

                self.designCollectionView.collectionViewLayout = layout
            }
        }
    }
    
    private func setLabel() {
        //폰트 종류, 사이즈 조절 버튼 설정
        fontNameLabel.text = "Aa"
        fontNameLabel.font = UIFont(name: fontList[fontIndex], size: 25)
        fontNameLabel.textColor = UIColor(named: "bear")
        
        if fontNameLabel.adjustsFontSizeToFitWidth == false {
            fontNameLabel.adjustsFontSizeToFitWidth = true
        }
        
        fontSizeLabel.text = "\(Int(self.stampFontSizePlus) + 10)"
        fontSizeLabel.font = UIFont(name: "KOTRA_SONGEULSSI", size: 20)
        fontSizeLabel.textColor = UIColor(named: "bear")
    }
    
    @objc func closeButtonClicked() {
        print(#function)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func nextButtonClicked() {
        print(#function)
        let st = UIStoryboard(name: "AddDiary", bundle: nil)
        if let vc = st.instantiateViewController(withIdentifier: AddDiaryViewController.identifier) as? AddDiaryViewController {
            
            let render = UIGraphicsImageRenderer(size: self.timeStampView.bounds.size)
            let image = render.image { (context) in
                self.timeStampView.drawHierarchy(in: self.timeStampView.bounds, afterScreenUpdates: true)
            }
            
            vc.selectedImage = image
            vc.selectedDate = self.stampDate
            vc.modalPresentationStyle = .fullScreen
                
            //navigation bar를 포함하여 다음 뷰 컨트롤러로 화면전환 - push
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func colorWellChanged(_ sender: Any) {
        if let colorWellColor = colorWell.selectedColor {
            self.stampDesignColor = colorWellColor
            self.designUpdate()
        }
    }
    
    @IBAction func whiteColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = .white
        self.designUpdate()
    }
    
    @IBAction func blackColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = .black
        self.designUpdate()
    }
    
    @IBAction func blueColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = UIColor().blue
        self.designUpdate()
    }
    
    @IBAction func greenColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = UIColor().green
        self.designUpdate()
    }
    
    @IBAction func yellowColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = UIColor().yellow
        self.designUpdate()
    }
    
    @IBAction func orangeColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = UIColor().orange
        self.designUpdate()
    }
    
    @IBAction func redColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = UIColor().red
        self.designUpdate()
    }
    
    @IBAction func pinkColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = UIColor().pink
        self.designUpdate()
    }
    
    @IBAction func purpleColorButtonClicked(_ sender: UIButton) {
        self.stampDesignColor = UIColor().purple
        self.designUpdate()
    }
    
    @IBAction func showColorPickerButtonClicked(_ sender: UIButton) {
        let picker = UIColorPickerViewController()
        picker.delegate = self
        picker.supportsAlpha = false
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func fontPlusButtonClicked(_ sender: UIButton) {
        if self.stampFontSizePlus < 10 {
            self.stampFontSizePlus += 1
            designUpdate()
            fontSizeLabel.text = "\(Int(self.stampFontSizePlus) + 10)"
        }
    }
    
    @IBAction func fontMinusButtonClicked(_ sender: UIButton) {
        if self.stampFontSizePlus > -10 {
            self.stampFontSizePlus -= 1
            designUpdate()
            fontSizeLabel.text = "\(Int(self.stampFontSizePlus) + 10)"
        }
    }
    
    @IBAction func nextFontButtonClicked(_ sender: UIButton) {
        fontIndex += 1
        
        if fontIndex >= fontList.count - 1 {
            fontIndex = 0
        }
        
        DispatchQueue.main.async {
            self.fontNameLabel.font = UIFont(name: self.fontList[self.fontIndex], size: 20)
            
            if self.fontNameLabel.adjustsFontSizeToFitWidth == false {
                self.fontNameLabel.adjustsFontSizeToFitWidth = true
            }
            self.designUpdate()
        }
    }
    
    @IBAction func previousFontButtonClicked(_ sender: UIButton) {
        fontIndex -= 1
        
        if fontIndex < 0 {
            fontIndex = fontList.count - 1
        }
        
        DispatchQueue.main.async {
            self.fontNameLabel.font = UIFont(name: self.fontList[self.fontIndex], size: 20)
            if self.fontNameLabel.adjustsFontSizeToFitWidth == false {
                self.fontNameLabel.adjustsFontSizeToFitWidth = true
            }
            self.designUpdate()
        }
    }
    
    private func setColorButton(button: UIButton, color: UIColor) {
        DispatchQueue.global().async {
            // UI 업데이트 전 실행되는 코드
            DispatchQueue.main.sync {
                //컬러버튼 설정
                button.setTitle("", for: .normal)
                button.layer.borderColor = UIColor.lightGray.cgColor
                button.layer.borderWidth = 2
                button.backgroundColor = color
                button.clipsToBounds = true
                button.layer.cornerRadius = 0.5 * button.bounds.size.width
            }
            // UI 업데이트 후 실행되는 코드
        }
    }
    
    private func designUpdate() {
        //subView가 쌓이지 않게 새로 추가하기 전에 삭제
        if self.designView.subviews.count > 0 {
            self.customView.removeFromSuperview()
        }
//        print(UIScreen.main)
//        print("timestampview:\(self.timeStampView.frame)")
//        print("designview   :\(self.designView.frame)")
//        print("scrollview   :\(self.scrollView.frame)")
//        print("imageview    :\(self.imageView.frame)")

        self.stampDate = Date()
        
        if self.stampDesignName == .Stamp_1 {
            self.customView = Stamp_1(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)

        } else if self.stampDesignName == .Stamp_2 {
            self.customView = Stamp_2(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_3 {
            self.customView = Stamp_3(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_4 {
            self.customView = Stamp_4(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_5 {
            self.customView = Stamp_5(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_6 {
            self.customView = Stamp_6(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_7 {
            self.customView = Stamp_7(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_8 {
            self.customView = Stamp_8(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_9 {
            self.customView = Stamp_9(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_10 {
            self.customView = Stamp_10(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_11 {
            self.customView = Stamp_11(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_12 {
            self.customView = Stamp_12(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_13 {
            self.customView = Stamp_13(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else if self.stampDesignName == .Stamp_14 {
            self.customView = Stamp_14(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
            
        } else {
            self.customView = Stamp_15(frame: self.designView.frame, color: self.stampDesignColor, fontName: self.fontList[self.fontIndex], fontSize: self.stampFontSizePlus)
        }

        self.designView.addSubview(self.customView)
        self.designView.layer.zPosition = 999
        self.designView.reloadInputViews()
    }
}

extension ImageEditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DesignCollectionViewCell.identifier, for: indexPath) as? DesignCollectionViewCell else {
            return UICollectionViewCell()
            
        }
        cell.backgroundColor = .lightGray
        cell.imageView.image = self.imageView.image
        cell.numLabel.text = "\(indexPath.row + 1)"
        cell.numLabel.font = UIFont().kotra_songeulssi_30
        
        cell.designView.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.65))

        cell.numLabel.layer.zPosition = 999
        cell.designView.layer.zPosition = 250
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.stampFontSizePlus = CGFloat(0)
        
        DispatchQueue.global().async {
            // UI 업데이트 전 실행되는 코드
            DispatchQueue.main.sync {
                self.fontSizeLabel.text = "\(Int(self.stampFontSizePlus) + 10)"
            }
        }
        
        if indexPath.row == 0 {
            self.stampDesignName = .Stamp_1
        } else if indexPath.row == 1 {
            self.stampDesignName = .Stamp_2
        } else if indexPath.row == 2 {
            self.stampDesignName = .Stamp_3
        } else if indexPath.row == 3 {
            self.stampDesignName = .Stamp_4
        } else if indexPath.row == 4 {
            self.stampDesignName = .Stamp_5
        } else if indexPath.row == 5 {
            self.stampDesignName = .Stamp_6
        } else if indexPath.row == 6 {
            self.stampDesignName = .Stamp_7
        } else if indexPath.row == 7 {
            self.stampDesignName = .Stamp_8
        } else if indexPath.row == 8 {
            self.stampDesignName = .Stamp_9
        } else if indexPath.row == 9 {
            self.stampDesignName = .Stamp_10
        } else if indexPath.row == 10 {
            self.stampDesignName = .Stamp_11
        } else if indexPath.row == 11 {
            self.stampDesignName = .Stamp_12
        } else if indexPath.row == 12 {
            self.stampDesignName = .Stamp_13
        } else if indexPath.row == 13 {
            self.stampDesignName = .Stamp_14
        } else {
            self.stampDesignName = .Stamp_15
        }
        
        self.designUpdate()
    }
}

extension ImageEditViewController: UIScrollViewDelegate {

   @available(iOS 2.0, *)
   func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return self.imageView
   }
    
   func scrollViewDidZoom(_ scrollView: UIScrollView) {
       scrollView.contentInset = .zero
   }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print(#function)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(#function)
    }
}

extension UIView {
    
    func asImage() -> UIImage {
          let renderer = UIGraphicsImageRenderer(bounds: bounds)
          return renderer.image { rendererContext in
              layer.render(in: rendererContext.cgContext)
          }
      }
    
    class func image(view: UIView, subview: UIView? = nil) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
    
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!

        UIGraphicsEndImageContext()
        
        if(subview != nil){
            var rect = (subview?.frame)!
            rect.size.height *= image.scale  //MOST IMPORTANT
            rect.size.width *= image.scale    //TOOK ME DAYS TO FIGURE THIS OUT
            let imageRef = image.cgImage!.cropping(to: rect)
            image = UIImage(cgImage: imageRef!, scale: image.scale, orientation: image.imageOrientation)
        }
        
        print(image.size.width, image.size.height)
        
        return image
    }
    
    func image() -> UIImage? {
        return UIView.image(view: self)
    }
    
    func image(withSubview: UIView) -> UIImage? {
        return UIView.image(view: self, subview: withSubview)
    }
}


extension ImageEditViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print(#function)
    }
}
