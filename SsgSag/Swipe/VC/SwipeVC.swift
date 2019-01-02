let  MAX_BUFFER_SIZE = 3;
let  SEPERATOR_DISTANCE = 8;
let  TOPYAXIS = 75;

import UIKit

class SwipeVC: UIViewController {
    @IBOutlet weak var viewTinderBackGround: UIView!
    @IBOutlet weak var viewActions: UIView!
    @IBOutlet var countLabel: UILabel!
    

    @IBAction func moveToMyPage(_ sender: Any) {
        
    }
    
    var currentLoadedCardsArray = [SwipeCard]()
    var allCardsArray = [SwipeCard]()
    
    //var valueArray = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36"]
    
    var valueArray = ["1","2","3","4","5","6"]
    
    var abcde = "abcde"
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewActions.isUserInteractionEnabled = true
        
        countLabel.layer.cornerRadius = 10
        countLabel.layer.masksToBounds = true
    
        
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        abcde = "12341234"
        
        
        print("SwipeVC의 서브뷰 \(self.view.subviews.count)")
        
        countLabel.text = "\(valueArray.count)"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        self.tabBarController?.tabBar.frame = CGRect(x: 0, y: 0, width: (tabBarController?.tabBar.frame.width)!, height: (tabBarController?.tabBar.frame.height)!)
    }
    
    

    //캘린더 이동
    @IBAction func moveToCalendar(_ sender: Any) {
        let calendarVC = CalenderVC()
        present(calendarVC, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.layoutIfNeeded()
        
        viewActions.isUserInteractionEnabled = true
        
        loadCardValues()
    }
    
    //
    func loadCardValues() {
        if valueArray.count > 0 {
            print("이게 출력되나???")
            //currentLoadedCardsArray 에 스와이프 카드 추가.
            let capCount = (valueArray.count > MAX_BUFFER_SIZE) ? MAX_BUFFER_SIZE : valueArray.count
            
            for (i,value) in valueArray.enumerated() {
                let newCard = createSwipeCard(at: i,value: value)
                allCardsArray.append(newCard)
                if i < capCount {
                    currentLoadedCardsArray.append(newCard)
                }
            }
            
            //viewTinderBackGround의 서브뷰로 currentLoadedCardsArray를 추가 (각 스와이프 카드를 서브뷰로 추가)
            for (i,_) in currentLoadedCardsArray.enumerated() {
                if i > 0 {
                    viewTinderBackGround.insertSubview(currentLoadedCardsArray[i], belowSubview: currentLoadedCardsArray[i - 1])
                } else {
                    viewTinderBackGround.addSubview(currentLoadedCardsArray[i])
                }
            }
            animateCardAfterSwiping() //카드 처음로드 혹은 제거 추가 할시
        }
    }
    //SwipeCard 생성
    func createSwipeCard(at index: Int , value :String) -> SwipeCard {
        let card = SwipeCard(frame: CGRect(x: 0, y: 0, width: viewTinderBackGround.frame.size.width , height: viewTinderBackGround.frame.size.height - 10) ,value : value)
        card.delegate = self
        return card
    }
    
    //카드 객체 제거, 새로운 value추가
    func removeObjectAndAddNewValues() {
            currentLoadedCardsArray.remove(at: 0)
            currentIndex = currentIndex + 1
            countLabel.text = "\(valueArray.count-currentIndex)"
            print("카드 개수 \(currentIndex)")
        
            //마지막 카드를 사용하고나서도 앱이 꺼지지 않게 개수 조절!
            if (currentIndex + currentLoadedCardsArray.count) < allCardsArray.count {
                let card = allCardsArray[currentIndex + currentLoadedCardsArray.count]
                currentLoadedCardsArray.append(card)
            
                viewTinderBackGround.insertSubview(currentLoadedCardsArray[MAX_BUFFER_SIZE - 1], belowSubview: currentLoadedCardsArray[MAX_BUFFER_SIZE - 2])
            }
    
            animateCardAfterSwiping()
    }
    
    func animateCardAfterSwiping() {
        //모든 스와이프 카드에서
        for (i,card) in currentLoadedCardsArray.enumerated() {
            //각 카드에 스와이프 카드를 등록
            let storyboard = UIStoryboard(name: "SwipeStoryBoard", bundle: nil)
            let pageVC = storyboard.instantiateViewController(withIdentifier: "PageViewController")
            
            pageVC.view.frame = self.currentLoadedCardsArray[i].frame
            self.addChild(pageVC)
            self.currentLoadedCardsArray[i].insertSubview(pageVC.view, at: 0)
            pageVC.didMove(toParent: self)
            
            //최상단의 카드만 InteractionEnabled 하게 함
            if i == 0 {
                    card.isUserInteractionEnabled = true
            }
        }
    }
    
    //싫어요
    @IBAction func disLikeButtonAction(_ sender: Any) {
        let card = currentLoadedCardsArray.first
        card?.leftClickAction()
    }
    
    //좋아요
    @IBAction func LikeButtonAction(_ sender: Any) {
        let card = currentLoadedCardsArray.first
        card?.rightClickAction()
    }
}

extension SwipeVC : SwipeCardDelegate {
    //카드가 왼쪽으로 갔을때
    func cardGoesLeft(card: SwipeCard) {
        removeObjectAndAddNewValues()
    }
    //카드 오른쪽으로 갔을때
    func cardGoesRight(card: SwipeCard) {
        removeObjectAndAddNewValues()
    }
}



