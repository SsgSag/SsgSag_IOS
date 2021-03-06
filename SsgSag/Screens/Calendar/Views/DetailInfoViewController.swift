//
//  DetailInfoViewController.swift
//  SsgSag
//
//  Created by 이혜주 on 18/07/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
//import AdBrixRM
import FBSDKCoreKit

class DetailInfoViewController: UIViewController {
    var isCalendar: Bool = true
    var isSave: Int = 1
    
    private var safeAreaViewBottomConstraint = NSLayoutConstraint()
    private var posterServiceImp: PosterService
        = DependencyContainer.shared.getDependency(key: .posterService)
    private var commentServiceImp: CommentService
        = DependencyContainer.shared.getDependency(key: .commentService)
    private var calendarService: CalendarService
        = DependencyContainer.shared.getDependency(key: .calendarService)
    
    var currentTextField: UITextField?
    var callback: ((Int) -> ())?
    var posterIdx: Int?
    var posterDetailData: DataClass?
    var imageSize: CGSize?
    private var columnData: [Column]?
    private var analyticsData: Analytics?
    private var firstCount: Int = 0
    
    private lazy var infoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    let safeAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.3843137255, green: 0.4156862745, blue: 1, alpha: 1)
        return view
    }()
    
    lazy var buttonsView: DetailInfoButtonsView = {
        let view = DetailInfoButtonsView(isCalendar: self.isCalendar,
                                         isSave: self.isSave)
        view.delegate = self
        view.commentDelegate = self
        view.commentTextField.delegate = self
        view.saveAtCalendar = { [weak self] in
            self?.saveAtCalendar()
        }
        view.removeAtCalendar = { [weak self] in
            self?.removeAtCalendar()
        }
        view.callback = { [weak self] in
            self?.requestDatas(section: 0)
        }
        view.alertCallback = { [weak self] in
            let alert = UIAlertController(title: "포스터가 저장되었습니다.", message: nil, preferredStyle: .alert)
            alert.modalPresentationStyle = .fullScreen
            self?.present(alert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alert.dismiss(animated: true)
            }
        }
        return view
    }()
    
    private lazy var shareBarButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(named: "ic_share"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(touchUpShareButton))
        barButton.tintColor = #colorLiteral(red: 0.4603668451, green: 0.5182471275, blue: 1, alpha: 1)
        return barButton
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
        setupNavigationBar()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleShowKeyboard),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleHideKeyboard),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
        
        requestDatas()
        setupLayout()
        setupCollectionView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        infoCollectionView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: self.safeAreaView.frame.height + self.buttonsView.frame.height,
                                                       right: 0)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "상세정보"
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_ArrowBack"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(touchUpBackButton))
        
        navigationItem.rightBarButtonItem = shareBarButton
    }
    
    private func requestDatas(section: Int? = nil) {
        guard let posterIdx = posterIdx else { return }
        
        posterServiceImp.requestPosterDetail(posterIdx: posterIdx) { [weak self] response in
            switch response {
            case .success(let detailData):
                self?.posterDetailData = detailData
                self?.buttonsView.posterIndex = posterIdx
                self?.buttonsView.isLike = detailData.isFavorite
                self?.buttonsView.isExistApplyURL = detailData.posterWebSite2 != nil ? true : false
                
                if detailData.categoryIdx == 3 || detailData.categoryIdx == 5 {
                    guard let columnJson = detailData.outline,
                        let data = columnJson.data(using: .utf8) else {
                            return
                    }
                    
                    do {
                        self?.columnData = try JSONDecoder().decode([Column].self,
                                                                    from: data)
                    } catch let error {
                        print(error)
                        return
                    }
                }
                
                guard let analyticsJson = detailData.analytics,
                    let data = analyticsJson.data(using: .utf8),
                    var photoUrl = detailData.photoUrl else {
                    return
                }
                
                if detailData.photoUrl2 != "" && detailData.photoUrl2 != nil {
                    photoUrl = detailData.photoUrl2 ?? ""
                }

                do {
                    self?.analyticsData = try JSONDecoder().decode(Analytics.self,
                                                                   from: data)
                } catch let error {
                    print(error)
                    return
                }
                
                guard let _ = self?.imageSize else {
                    ImageNetworkManager.shared.getImageByCache(imageURL: photoUrl) { [weak self] image, error in
                        DispatchQueue.main.async {
                            guard let image = image,
                                let width = self?.view.frame.width else {
                                return
                            }

                            self?.imageSize
                                = self?.imageWithImage(sourceImage: image, scaledToWidth: width).size
                            
                            guard let section = section else {
                                self?.infoCollectionView.reloadData()
                                return
                            }
                            
                            self?.infoCollectionView.reloadSections(IndexSet(integer: section))
                        }
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    guard let section = section else {
                        self?.infoCollectionView.reloadData()
                        return
                    }
                    
                    self?.infoCollectionView.reloadSections(IndexSet(integer: section))
                }
            case .failed(let error):
                assertionFailure(error.localizedDescription)
                return
            }
        }
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        buttonsView.delegate = self
        
        view.addSubview(infoCollectionView)
        infoCollectionView.addSubview(buttonsView)
        infoCollectionView.addSubview(safeAreaView)
        
        infoCollectionView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        infoCollectionView.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        infoCollectionView.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        infoCollectionView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor).isActive = true
        
        buttonsView.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        buttonsView.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        buttonsView.heightAnchor.constraint(
            equalToConstant: 93).isActive = true
        buttonsView.bottomAnchor.constraint(
            equalTo: safeAreaView.topAnchor).isActive = true
        
        safeAreaViewBottomConstraint = safeAreaView.bottomAnchor.constraint(
            equalTo:view.bottomAnchor)
        
        safeAreaView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        safeAreaView.leadingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        safeAreaView.trailingAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        safeAreaViewBottomConstraint.isActive = true
    }
    
    private func setupCollectionView() {
        // header
        let posterHeaderNib = UINib(nibName: "PosterHeaderCollectionReusableView", bundle: nil)
        
        infoCollectionView.register(posterHeaderNib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "posterHeaderID")
        
        let seeMoreHeaderNib = UINib(nibName: "SeeMoreCollectionReusableView", bundle: nil)
        
        infoCollectionView.register(seeMoreHeaderNib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "seeMoreHeaderID")
        
        infoCollectionView.register(TempCollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: "tempHeader")
        
        // footer
        let posterFooterNib = UINib(nibName: "PosterFooterCollectionReusableView", bundle: nil)
        
        infoCollectionView.register(posterFooterNib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                    withReuseIdentifier: "posterFooterID")
        
        infoCollectionView.register(SeperateCollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                    withReuseIdentifier: "seperateFooter")
        
        infoCollectionView.register(TempCollectionReusableView.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                    withReuseIdentifier: "tempFooter")
        
        // cell
        infoCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "tempCell")
        
        let dateNib = UINib(nibName: "DateCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(dateNib, forCellWithReuseIdentifier: "dateCell")
        
        let detailInfoNib = UINib(nibName: "DetailInfoCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(detailInfoNib, forCellWithReuseIdentifier: "detailInfoCellID")
        
        let detailImageNib = UINib(nibName: "DetailImageCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(detailImageNib, forCellWithReuseIdentifier: "detailImageCell")
        
        let analyticsNib = UINib(nibName: "AnalysticsCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(analyticsNib, forCellWithReuseIdentifier: "analyticsCellID")
        
        let commentNib = UINib(nibName: "CommentCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(commentNib, forCellWithReuseIdentifier: "commentCellID")
        
        let commentWriteNib = UINib(nibName: "CommentWriteCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(commentWriteNib, forCellWithReuseIdentifier: "commentWriteCellID")
        
        let hideNib = UINib(nibName: "HideAnalyticsCommentsCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(hideNib, forCellWithReuseIdentifier: "hideAnalyticsCommentsCell")
        
        let noCommentNib = UINib(nibName: "NoCommentCollectionViewCell", bundle: nil)
        
        infoCollectionView.register(noCommentNib, forCellWithReuseIdentifier: "noCommentCell")
        
    }
    
    func estimatedFrame(width: CGFloat,
                        text: String,
                        font: UIFont,
                        paragraphStyle: NSMutableParagraphStyle? = nil) -> CGRect {
        let size = CGSize(width: width, height: 3000) // temporary size
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        var attribute: [NSAttributedString.Key : Any]? = [NSAttributedString.Key.font: font]
        
        guard paragraphStyle != nil else {
            return NSString(string: text).boundingRect(with: size,
                                                       options: options,
                                                       attributes: attribute,
                                                       context: nil)
        }
        
        attribute?.updateValue(paragraphStyle, forKey: NSAttributedString.Key.paragraphStyle)
        
        return NSString(string: text).boundingRect(with: size,
                                                   options: options,
                                                   attributes: attribute,
                                                   context: nil)
    }
    
    private func saveAtCalendar() {
        guard let posterIdx = posterIdx else {
            assertionFailure()
            return
        }
        
        posterServiceImp.requestPosterStore(of: posterIdx,
                                            type: .liked) { [weak self] result in
            switch result {
            case .success(let status):
                switch status {
                case .sucess:
                    print("성공")
                case .dataBaseError:
                    self?.simplerAlert(title: "데이터베이스 에러")
                case .serverError:
                    self?.simplerAlert(title: "서버 에러")
                default:
                    print("슥/삭 실패")
                }
            case .failed(let error):
                print(error)
                return
            }
        }
    }
    
    private func removeAtCalendar() {
        guard let posterIdx = posterIdx else {
            assertionFailure()
            return
        }
        
        calendarService.requestTodoDelete([posterIdx]) { [weak self] result in
            switch result {
            case .success(let status):
                DispatchQueue.main.async {
                    switch status {
                    case .processingSuccess:
                        print("성공")
                    case .dataBaseError:
                        self?.simplerAlert(title: "데이터베이스 에러")
                    case .serverError:
                        self?.simplerAlert(title: "서버 에러")
                    default:
                        print("슥/삭 실패")
                    }
                }
            case .failed(let error):
                print(error)
                return
            }
        }
    }
    
    @objc private func touchUpBackButton() {
        callback?(buttonsView.isLike ?? 0)
        navigationController?.popViewController(animated: true)
        tabBarController?.tabBar.isHidden = false
        
        
    }
    
    // MARK: - 공유 버튼
    @objc func touchUpShareButton(){
//        let adBrix = AdBrixRM.getInstance
//        adBrix.event(eventName: "touchUp_Share",
//                     value: ["posterIdx": posterIdx])

        let template = KMTFeedTemplate { [weak self] feedTemplateBuilder in
            
            guard let posterName = self?.posterDetailData?.posterName,
                let photoUrl = self?.posterDetailData?.photoUrl,
                let tag = self?.posterDetailData?.keyword,
                let imageUrl = URL(string: photoUrl),
                let posterIdx = self?.posterIdx else {
                return
            }
            
            feedTemplateBuilder.content = KMTContentObject(builderBlock: { contentBuilder in
                contentBuilder.imageURL = imageUrl
                contentBuilder.title = posterName
                contentBuilder.desc = tag
                
                contentBuilder.link = KMTLinkObject(builderBlock: { linkBuilder in
                    linkBuilder.androidExecutionParams = "param=\(posterIdx)&from=main"
                    linkBuilder.iosExecutionParams = "posterIdx=\(posterIdx)"
                })
            })

            feedTemplateBuilder.addButton(KMTButtonObject(builderBlock: { buttonBuilder in
                buttonBuilder.title = "앱에서 보기"

                buttonBuilder.link = KMTLinkObject(builderBlock: { linkBuilder in
//                            linkBuilder.webURL = URL(string: )
                    linkBuilder.androidExecutionParams = "param=\(posterIdx)&from=main"
                    linkBuilder.iosExecutionParams = "posterIdx=\(posterIdx)"

                })

            }))
        }

        // 카카오링크 실행
        KLKTalkLinkCenter.shared().sendDefault(with: template, success: { warningMsg, argumentMsg in
            // 성공
            print("warning message: \(String(describing: warningMsg))")
            print("argument message: \(String(describing: argumentMsg))")
        }, failure: { error in
            // 실패
            print("error \(error)")
            
        })
    }
    
    @objc func handleShowKeyboard(notification: NSNotification) {
        guard let keyboardFrame
            = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                as? CGRect else {
                    return
        }
        
        safeAreaViewBottomConstraint.constant = -keyboardFrame.height
        self.view.layoutIfNeeded()
    }
    
    @objc func handleHideKeyboard(notification: NSNotification) {
        safeAreaViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    private func addObjects(with objectsToshare: [Any]) {
        let activityVC = UIActivityViewController(activityItems: objectsToshare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        activityVC.popoverPresentationController?.sourceView = view
        activityVC.modalPresentationStyle = .fullScreen
        self.present(activityVC, animated: true, completion: nil)
    }
    
    private func requestClickRecord(type: Int) {
        guard let posterIdx = posterIdx else {
            return
        }
        
        calendarService.requestTodoListClickRecord(posterIdx, type: type) { result in
            switch result {
            case .success(let status):
                switch status {
                case .processingSuccess:
                    print("기록 성공")
                case .dataBaseError:
                    print("DB 에러")
                case .serverError:
                    print("server 에러")
                default:
                    print("기록 실패")
                }
            case .failed:
                assertionFailure()
                return
            }
        }
    }
    
    func imageWithImage(sourceImage: UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), true, 10.0)
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension DetailInfoViewController: UICollectionViewDelegate {
    
}

extension DetailInfoViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        guard let isTryWithoutLogin = UserDefaults.standard.object(forKey: "isTryWithoutLogin") as? Bool else {
            return .init()
        }
        
        if isTryWithoutLogin {
            return 4
        }
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            // 이미지
            return 1
        case 2:
            // 상세정보
            return 0
        case 3:
            return 1
        case 4:
            return posterDetailData?.commentList?.count != 0 ? (posterDetailData?.commentList?.count ?? 0) : 1
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let categoryIdx = posterDetailData?.categoryIdx,
            let category = PosterCategory(rawValue: categoryIdx) else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "tempCell", for: indexPath)
        }
        
        let infoTitles = category.titleStringByCategory()
        
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                guard let cell
                    = collectionView.dequeueReusableCell(withReuseIdentifier: "dateCell",
                                                         for: indexPath)
                        as? DateCollectionViewCell else {
                    return .init()
                }
                
                let dateString
                    = DateCaculate.getDifferenceBetweenStartAndEnd(startDate: posterDetailData?.posterStartDate,
                                                                   endDate: posterDetailData?.posterEndDate)
                
                cell.configure(dateString, dday: posterDetailData?.dday)
                
                return cell
            case 1:
                guard let cell
                    = collectionView.dequeueReusableCell(withReuseIdentifier: "detailInfoCellID",
                                                         for: indexPath) as? DetailInfoCollectionViewCell else {
                                                            return .init()
                }
                
                if columnData?.count ?? 3 < 1 {
                    return cell
                }
                
                if categoryIdx == 3 || categoryIdx == 5 {
                    cell.configure(titleString: columnData?[0].columnName ?? "",
                                   detailString: columnData?[0].columnContent ?? "")
                } else if posterDetailData?.categoryIdx == 8 {
                    cell.configure(titleString: infoTitles[0],
                                   detailString: posterDetailData?.benefit ?? "")
                } else {
                    cell.configure(titleString: infoTitles[0],
                                   detailString: posterDetailData?.outline ?? "")
                }
                
                return cell
            case 2:
                guard let cell
                    = collectionView.dequeueReusableCell(withReuseIdentifier: "detailInfoCellID",
                                                         for: indexPath) as? DetailInfoCollectionViewCell else {
                                                            return .init()
                }
                
                if columnData?.count ?? 3 < 2 {
                    return cell
                }
                
                if categoryIdx == 3 || categoryIdx == 5 {
                    cell.configure(titleString: columnData?[1].columnName ?? "",
                                   detailString: columnData?[1].columnContent ?? "")
                } else if posterDetailData?.categoryIdx == 2 {
                    cell.configure(titleString: infoTitles[1],
                                   detailString: posterDetailData?.period ?? "")
                } else {
                    cell.configure(titleString: infoTitles[1],
                                   detailString: posterDetailData?.target ?? "")
                }
                return cell
            case 3:
                guard let cell
                    = collectionView.dequeueReusableCell(withReuseIdentifier: "detailInfoCellID",
                                                         for: indexPath) as? DetailInfoCollectionViewCell else {
                                                            return .init()
                }
                
                if columnData?.count ?? 3 < 3 {
                    return cell
                }
                
                if categoryIdx == 3 || categoryIdx == 5 {
                    cell.configure(titleString: columnData?[2].columnName ?? "",
                                   detailString: columnData?[2].columnContent ?? "")
                } else if posterDetailData?.categoryIdx == 7 {
                    cell.configure(titleString: infoTitles[2],
                                   detailString: posterDetailData?.period ?? "")
                } else if posterDetailData?.categoryIdx == 8 {
                    cell.configure(titleString: infoTitles[2],
                                   detailString: posterDetailData?.outline ?? "")
                } else {
                    cell.configure(titleString: infoTitles[2],
                                   detailString: posterDetailData?.benefit ?? "")
                }
                
                return cell
            default:
                return UICollectionViewCell()
            }
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailImageCell", for: indexPath) as? DetailImageCollectionViewCell else {
                return UICollectionViewCell()
            }

            if var photoUrl = posterDetailData?.photoUrl {
                if posterDetailData?.photoUrl2 != nil && posterDetailData?.photoUrl2 != "" {
                    photoUrl = posterDetailData?.photoUrl2 ?? ""
                }
                
                ImageNetworkManager.shared.getImageByCache(imageURL: photoUrl) { [weak self] image, error in
                    DispatchQueue.main.async {
                        guard let image = image, let width = self?.view.frame.width else {
                            return
                        }

                        let resizeImage = self?.imageWithImage(sourceImage: image,
                                                               scaledToWidth: width)
                        cell.posterImageView.image = resizeImage
                    }
                }
            }
            
            return cell
        case 3:
            guard let isTryWithoutLogin = UserDefaults.standard.object(forKey: "isTryWithoutLogin") as? Bool else {
                return .init()
            }
            
            if isTryWithoutLogin {
                guard let cell
                    = collectionView.dequeueReusableCell(withReuseIdentifier: "hideAnalyticsCommentsCell",
                                                         for: indexPath) as? HideAnalyticsCommentsCollectionViewCell else {
                                                            return .init()
                }
                
                cell.callBack = {
                    KeychainWrapper.standard.removeObject(forKey: TokenName.token)
                    
                    guard let window = UIApplication.shared.keyWindow else {
                        return
                    }
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "LoginStoryBoard", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "splashVC") as! SplashViewController
                    
                    let rootNavigationController = UINavigationController(rootViewController: viewController)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = rootNavigationController
                    
                    rootNavigationController.view.layoutIfNeeded()
                    
                    UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                        window.rootViewController = rootNavigationController
                    }, completion: nil)
                }
                
                return cell
            }
            
            guard let cell
                = collectionView.dequeueReusableCell(withReuseIdentifier: "analyticsCellID",
                                                     for: indexPath) as? AnalysticsCollectionViewCell else {
                                                        return .init()
            }
            
            if cell.majorChartView.layer.sublayers != nil {
                return cell
            }
            
            cell.configure(analyticsData: analyticsData)
            
            return cell
        default:
            if posterDetailData?.commentList?.count == 0 {
                guard let cell
                    = collectionView.dequeueReusableCell(withReuseIdentifier: "noCommentCell",
                                                         for: indexPath) as? NoCommentCollectionViewCell else {
                                                            return .init()
                }
                
                return cell
            }
            guard let cell
                = collectionView.dequeueReusableCell(withReuseIdentifier: "commentCellID",
                                                     for: indexPath) as? CommentCollectionViewCell else {
                                                        return .init()
            }
            
            guard let comment = posterDetailData?.commentList?[indexPath.item] else {
                return cell
            }
            
            cell.delegate = self
            cell.comment = comment
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            switch indexPath.section {
            case 0:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "posterHeaderID",
                                                                                   for: indexPath)
                    as? PosterHeaderCollectionReusableView else {
                    return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "tempHeader",
                                                                           for: indexPath)
                }
                
                header.delegate = self
                header.detailData = posterDetailData
                
                if let thumbPhotoUrl = posterDetailData?.thumbPhotoUrl {
                    ImageNetworkManager.shared.getImageByCache(imageURL: thumbPhotoUrl) { image, error in
                        DispatchQueue.main.async {
                            header.posterImageView.image = image
                        }
                    }
                }

                return header
            case 2:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: "seeMoreHeaderID",
                                                                                   for: indexPath)
                    as? SeeMoreCollectionReusableView else {
                    return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "tempHeader",
                                                                           for: indexPath)
                }
                
                header.configure(posterDetailData?.posterDetail ?? "")
                
                return header
            default:
                return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                withReuseIdentifier: "tempHeader",
                for: indexPath)
            }
            
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: "seperateFooter",
                                                                   for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        currentTextField?.resignFirstResponder()
    }
}

extension DetailInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: view.frame.width, height: 220)
        case 2:
            guard posterDetailData?.posterDetail != nil else {
                return CGSize(width: view.frame.width, height: 0)
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            
            let collectionViewCellHeight = estimatedFrame(width: view.frame.width - 46,
                                                          text: posterDetailData?.posterDetail ?? "",
                                                          font: UIFont.systemFont(ofSize: 12),
                                                          paragraphStyle: paragraphStyle).height
            
            return CGSize(width: view.frame.width,
                          height: collectionViewCellHeight + 47 + 20)
        default:
            return CGSize(width: view.frame.width, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: view.frame.width, height: 30)
        } else if section == 4 {
            return CGSize(width: view.frame.width, height: 0)
        }
        return CGSize(width: view.frame.width, height: 7)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            switch indexPath.item {
            case 0:
                return CGSize(width: view.frame.width, height: 26)
            case 1:
                if columnData?.count ?? 3 < 1 {
                    return CGSize(width: view.frame.width, height: 0)
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10
                
                let collectionViewCellHeight = estimatedFrame(width: view.frame.width - 79,
                                                              text: posterDetailData?.outline ?? "",
                                                              font: UIFont.systemFont(ofSize: 15),
                                                              paragraphStyle: paragraphStyle).height
                
                return CGSize(width: view.frame.width,
                              height: collectionViewCellHeight + 7)
            case 2:
                if columnData?.count ?? 3 < 2 {
                    return CGSize(width: view.frame.width, height: 0)
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10
                
                let collectionViewCellHeight = estimatedFrame(width: view.frame.width - 79,
                                                              text: posterDetailData?.target ?? "",
                                                              font: UIFont.systemFont(ofSize: 15),
                                                              paragraphStyle: paragraphStyle).height
                
                return CGSize(width: view.frame.width,
                              height: collectionViewCellHeight + 7 + 3)
            case 3:
                if columnData?.count ?? 3 < 3 {
                    return CGSize(width: view.frame.width, height: 0)
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 10
                
                let collectionViewCellHeight = estimatedFrame(width: view.frame.width - 79,
                                                              text: posterDetailData?.benefit ?? "",
                                                              font: UIFont.systemFont(ofSize: 15),
                                                              paragraphStyle: paragraphStyle).height
                
                return CGSize(width: view.frame.width,
                              height: collectionViewCellHeight + 7 + 3)
            default:
                return CGSize(width: view.frame.width, height: 0)
            }
        case 1:
            return imageSize ?? CGSize(width: view.frame.width, height: 0)
//            guard let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 1)) as? DetailImageCollectionViewCell,
//                let size = cell.posterImageView.image?.size else {
//                return CGSize(width: view.frame.width, height: 0)
//            }
//
//            return size
            
//            return CGSize(width: view.frame.width, height: 400)
        case 3:
            return CGSize(width: view.frame.width, height: 268)
        default:
            if posterDetailData?.commentList?.count == 0 {
                return CGSize(width: view.frame.width, height: 80)
            }
            
            let collectionViewCellHeight
                = estimatedFrame(width: view.frame.width - 48 - 74 - 28,
                                 text: posterDetailData?.commentList?[indexPath.item].commentContent ?? "",
                                 font: UIFont.systemFont(ofSize: 13)).height
            
            return CGSize(width: view.frame.width, height: collectionViewCellHeight + 12 + 8 + 20 + 10 + 3)
        }
        
    }
}

extension DetailInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DetailInfoViewController: UIGestureRecognizerDelegate {
}

extension DetailInfoViewController: WebsiteDelegate {
    func moveToWebsite(isApply: Bool) {
        if isApply {
            guard let applysiteURL = posterDetailData?.posterWebSite2,
                let url = URL(string: applysiteURL) else {
                    return
            }
            
            requestClickRecord(type: 1)
            
            UIApplication.shared.open(url)
        } else {
//            let adBrix = AdBrixRM.getInstance
//            adBrix.event(eventName: "touchUp_MoveToWebsite",
//                         value: ["posterIdx": posterIdx])
            AppEvents.logEvent(.viewedContent, valueToSum: 3)
            
            guard let websiteURL = posterDetailData?.posterWebSite,
                let url = URL(string: websiteURL) else {
                    return
            }
            
            requestClickRecord(type: 0)
            
            UIApplication.shared.open(url)
        }
    }
}

extension DetailInfoViewController: CommentWriteDelegate {
    func commentRegister(text: String) {
        guard let index = posterIdx else {
            return
        }
        
        commentServiceImp.requestAddComment(index: index,
                                            comment: text) { [weak self] result in
                                                switch result {
                                                case .success(let status):
                                                    switch status {
                                                    case .secondSucess:
                                                        DispatchQueue.main.async {
                                                            self?.currentTextField?.resignFirstResponder()
                                                            self?.simplerAlert(title: "댓글 등록이 완료되었습니다.")
                                                            self?.requestDatas(section: 2)
                                                        }
                                                    case .dataBaseError:
                                                        DispatchQueue.main.async {
                                                            self?.simplerAlert(title: "database error")
                                                        }
                                                        return
                                                    case .serverError:
                                                        DispatchQueue.main.async {
                                                            self?.simplerAlert(title: "server error")
                                                        }
                                                        return
                                                    default:
                                                        return
                                                    }
                                                case .failed(let error):
                                                    print(error)
                                                    return
                                                }
        }
    }
}

extension DetailInfoViewController: CommentDelegate {
    
    func touchUpCommentLikeButton(index: Int, like: Int) {
        commentServiceImp.requestCommentLike(index: index,
                                             like: like) { [weak self] result in
                                                switch result {
                                                case .success(let status):
                                                    DispatchQueue.main.async {
                                                        switch status {
                                                        case .processingSuccess:
                                                            self?.requestDatas(section: 2)
                                                        case .dataBaseError:
                                                            self?.simplerAlert(title: "database error")
                                                            return
                                                        case .serverError:
                                                            self?.simplerAlert(title: "server error")
                                                            return
                                                        default:
                                                            return
                                                        }
                                                    }
                                                case .failed(let error):
                                                    print(error)
                                                    return
                                                }
        }
    }
    
    func presentAlertController(_ isMine: Bool, commentIndex: Int) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        if isMine {
            //            let editAction = UIAlertAction(title: "댓글 수정", style: .default) { [weak self] _ in
            //
            //            }
            
            let deleteAction = UIAlertAction(title: "댓글 삭제", style: .default) { [weak self] _ in
                self?.commentServiceImp.requestCommentDelete(index: commentIndex) { [weak self] result in
                    switch result {
                    case .success(let status):
                        DispatchQueue.main.async {
                            switch status {
                            case .processingSuccess:
                                self?.simplerAlert(title: "댓글이 삭제되었습니다")
                                self?.requestDatas(section: 2)
                            case .dataBaseError:
                                self?.simplerAlert(title: "database error")
                                return
                            case .serverError:
                                self?.simplerAlert(title: "server error")
                                return
                            default:
                                return
                            }
                        }
                    case .failed(let error):
                        print(error)
                        return
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                alertController.dismiss(animated: true)
            }
            
            //            alertController.addAction(editAction)
            alertController.addAction(deleteAction)
            alertController.addAction(cancelAction)

            alertController.modalPresentationStyle = .fullScreen
            present(alertController, animated: true)
        } else {
            
            let reportAction = UIAlertAction(title: "댓글 신고", style: .default) { [weak self] _ in
                self?.commentServiceImp.requestCommentReport(index: commentIndex) { [weak self] result in
                    switch result {
                    case .success(let status):
                        DispatchQueue.main.async {
                            switch status {
                            case .processingSuccess:
                                self?.simplerAlert(title: "댓글 신고가 완료되었습니다.")
                            case .dataBaseError:
                                self?.simplerAlert(title: "database error")
                                return
                            case .serverError:
                                self?.simplerAlert(title: "server error")
                                return
                            default:
                                return
                            }
                        }
                    case .failed(let error):
                        print(error)
                        return
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                alertController.dismiss(animated: true)
            }
            
            alertController.addAction(reportAction)
            alertController.addAction(cancelAction)
            alertController.modalPresentationStyle = .fullScreen
            
            present(alertController, animated: true)
        }
    }
}

extension DetailInfoViewController: LargeImageDelegate {
    func presentLargeImage() {
        let swipeStoryboard = UIStoryboard(name: StoryBoardName.swipe,
                                           bundle: nil)
        guard let zoomPosterVC = swipeStoryboard.instantiateViewController(withIdentifier: ViewControllerIdentifier.zoomPosterViewController) as? ZoomPosterVC else {return}
        
        zoomPosterVC.urlString = posterDetailData?.photoUrl
        zoomPosterVC.modalPresentationStyle = .fullScreen
        self.present(zoomPosterVC, animated: true)
    }
}

