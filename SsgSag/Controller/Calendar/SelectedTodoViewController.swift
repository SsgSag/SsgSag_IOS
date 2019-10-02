//
//  SelectedTodoViewController.swift
//  SsgSag
//
//  Created by admin on 14/06/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit

protocol selectedTodoDelegate: class {
    func changeCurrentWindowDate(_ currentDate: Date)
}

class SelectedTodoViewController: UIViewController {
    
    static let tableViewCellReuseIdentifier = "DetailTodoListTableViewCell"
    
    var delegate: selectedTodoDelegate?
    var indexPath: IndexPath?
    private var monthTodoData: [MonthTodoData]?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .black
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let firstTableView: UITableView = {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let secondTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let thirdTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let fourthTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let fifthTableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var firstDayPosters: [MonthTodoData] = []
    private var secondDayPosters: [MonthTodoData] = []
    private var thirdDayPosters: [MonthTodoData] = []
    private var fourthDayPosters: [MonthTodoData] = []
    private var fifthDayPosters: [MonthTodoData] = []
    
    private var currentWindowDate: Date?
    
    private let calendarServiceImp: CalendarService
        = DependencyContainer.shared.getDependency(key: .calendarService)
    
    private let calendar = Calendar.current
    
    var currentDate: Date? {
        didSet {
            guard let date = currentDate,
                let monthTodoData = monthTodoData else {
                return
            }
            
            let firstDate = date.changeDaysBy(days: -2)
            
            let secondDate = date.changeDaysBy(days: -1)
            
            let fourthDate = date.changeDaysBy(days: 1)
            
            let fifthDate = date.changeDaysBy(days: 2)
            
            for todo in monthTodoData {
                let endDate = DateCaculate.stringToDateWithGenericFormatter(using: todo.posterEndDate!)
                
                if DateCaculate.isSameDate(firstDate, endDate) {
                    firstDayPosters.append(todo)
                }
                
                if DateCaculate.isSameDate(secondDate, endDate) {
                    secondDayPosters.append(todo)
                }
                
                if DateCaculate.isSameDate(date, endDate) {
                    thirdDayPosters.append(todo)
                }
                
                if DateCaculate.isSameDate(fourthDate, endDate) {
                    fourthDayPosters.append(todo)
                }
                
                if DateCaculate.isSameDate(fifthDate, endDate) {
                    fifthDayPosters.append(todo)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let date = currentDate else {return}
        
//        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        currentWindowDate = date
        
        requestData()
        
        addTapGesture()
        
        setDelegate()
        
        setScrollView()
        
        setCurrentContentOffset(with: date)
        
        addTableView()
    }
    
    private func requestData() {
        guard let date = currentDate else { return }
        
        let year = String(calendar.component(.year, from: date))
        let month = String(calendar.component(.month, from: date))
        
        calendarServiceImp.requestMonthTodoList(year: year,
                                              month: month, [0,1,2,4,7,8], favorite: 0) { [weak self] dataResponse in
            switch dataResponse {
            case .success(let monthTodoData):
                self?.monthTodoData = monthTodoData
                DispatchQueue.main.async {
                    self?.setDefaultScrollViewAndReloadTableView(using: 0)
                }
            case .failed(let error):
                assertionFailure(error.localizedDescription)
                return
            }
        }
    }
    
    private func setScrollView() {
        view.addSubview(scrollView)
        scrollView.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        scrollView.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
        scrollView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor).isActive = true
        scrollView.heightAnchor.constraint(
            equalTo: view.heightAnchor).isActive = true
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = true
    }
    
    private func setCurrentContentOffset(with selectedDate: Date) {
        
        let numberOfCurrentMonthDays = getCurrentMonthsDay(selectedDate)
        
        scrollView.contentSize = CGSize(width: self.view.frame.width * numberOfCurrentMonthDays,
                                        height: self.view.frame.height)
        
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width * 2, y: 0), animated: false)
    }
    
    private func getCurrentMonthsDay(_ selectedDay: Date) -> CGFloat{
        return 5
    }
    
    private func setDelegate() {
        firstTableView.delegate = self
        secondTableView.delegate = self
        thirdTableView.delegate = self
        fourthTableView.delegate = self
        fifthTableView.delegate = self
        
        firstTableView.dataSource = self
        secondTableView.dataSource = self
        thirdTableView.dataSource = self
        fourthTableView.dataSource = self
        fifthTableView.dataSource = self
        
        firstTableView.separatorStyle = .none
        secondTableView.separatorStyle = .none
        thirdTableView.separatorStyle = .none
        fourthTableView.separatorStyle = .none
        fifthTableView.separatorStyle = .none
        
        firstTableView.register(UINib(nibName: "DetailTodoListTableViewCell", bundle: nil),
                                forCellReuseIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier)
        
        secondTableView.register(UINib(nibName: "DetailTodoListTableViewCell", bundle: nil),
                                 forCellReuseIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier)
        
        thirdTableView.register(UINib(nibName: "DetailTodoListTableViewCell", bundle: nil),
                                forCellReuseIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier)
        
        fourthTableView.register(UINib(nibName: "DetailTodoListTableViewCell", bundle: nil),
                                forCellReuseIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier)
        
        fifthTableView.register(UINib(nibName: "DetailTodoListTableViewCell", bundle: nil),
                                forCellReuseIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier)
        
    }
    
    private func addTableView() {
        
        scrollView.addSubview(firstTableView)
        scrollView.addSubview(secondTableView)
        scrollView.addSubview(thirdTableView)
        scrollView.addSubview(fourthTableView)
        scrollView.addSubview(fifthTableView)
        
        firstTableView.centerXAnchor.constraint(
            equalTo: scrollView.centerXAnchor).isActive = true
        firstTableView.centerYAnchor.constraint(
            equalTo: scrollView.centerYAnchor).isActive = true
        firstTableView.widthAnchor.constraint(
            equalTo: scrollView.widthAnchor,
            multiplier: 0.88).isActive = true
        firstTableView.heightAnchor.constraint(
            equalTo: self.scrollView.heightAnchor,
            multiplier: 0.8).isActive = true
        
        secondTableView.centerXAnchor.constraint(
            equalTo: firstTableView.centerXAnchor,
            constant: self.view.frame.width).isActive = true
        secondTableView.centerYAnchor.constraint(
            equalTo: scrollView.centerYAnchor).isActive = true
        secondTableView.widthAnchor.constraint(
            equalTo: scrollView.widthAnchor,
            multiplier: 0.88).isActive = true
        secondTableView.heightAnchor.constraint(
            equalTo: self.scrollView.heightAnchor,
            multiplier: 0.8).isActive = true
        
        thirdTableView.centerXAnchor.constraint(
            equalTo: secondTableView.centerXAnchor,
            constant: self.view.frame.width).isActive = true
        thirdTableView.centerYAnchor.constraint(
            equalTo: scrollView.centerYAnchor).isActive = true
        thirdTableView.widthAnchor.constraint(
            equalTo: scrollView.widthAnchor,
            multiplier: 0.88).isActive = true
        thirdTableView.heightAnchor.constraint(
            equalTo: self.scrollView.heightAnchor,
            multiplier: 0.8).isActive = true
        
        fourthTableView.centerXAnchor.constraint(
            equalTo: thirdTableView.centerXAnchor,
            constant: self.view.frame.width).isActive = true
        fourthTableView.centerYAnchor.constraint(
            equalTo: scrollView.centerYAnchor).isActive = true
        fourthTableView.widthAnchor.constraint(
            equalTo: scrollView.widthAnchor,
            multiplier: 0.88).isActive = true
        fourthTableView.heightAnchor.constraint(
            equalTo: self.scrollView.heightAnchor,
            multiplier: 0.8).isActive = true
        
        fifthTableView.centerXAnchor.constraint(
            equalTo: fourthTableView.centerXAnchor,
            constant: self.view.frame.width).isActive = true
        fifthTableView.centerYAnchor.constraint(
            equalTo: scrollView.centerYAnchor).isActive = true
        fifthTableView.widthAnchor.constraint(
            equalTo: scrollView.widthAnchor,
            multiplier: 0.88).isActive = true
        fifthTableView.heightAnchor.constraint(
            equalTo: self.scrollView.heightAnchor,
            multiplier: 0.8).isActive = true
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDisView))
        scrollView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
    }
    
    @objc private func dismissDisView() {
        dismiss(animated: true)
    }
    
    deinit {
        print("SelectedTodoViewController is deleted")
    }
    
    private func setDefaultScrollViewAndReloadTableView(using by: Int) {
        
        self.scrollView.setContentOffset(CGPoint(x: self.view.frame.width * 2, y: 0), animated: false)
        
        currentDate = currentDate?.changeDaysBy(days: by)
        
        guard let date = currentDate,
            let monthTodoData = monthTodoData else {return}
        
        firstDayPosters = []
        secondDayPosters = []
        thirdDayPosters = []
        fourthDayPosters = []
        fifthDayPosters = []
        
        let firstDate = date.changeDaysBy(days: -2)
        
        let secondDate = date.changeDaysBy(days: -1)
        
        let fourthDate = date.changeDaysBy(days: 1)
        
        let fifthDate = date.changeDaysBy(days: 2)
        
        for todo in monthTodoData {
            let endDate = DateCaculate.stringToDateWithGenericFormatter(using: todo.posterEndDate!)
            
            if DateCaculate.isSameDate(firstDate, endDate) {
                firstDayPosters.append(todo)
            }
            
            if DateCaculate.isSameDate(secondDate, endDate) {
                secondDayPosters.append(todo)
            }
            
            if DateCaculate.isSameDate(date, endDate) {
                thirdDayPosters.append(todo)
            }
            
            if DateCaculate.isSameDate(fourthDate, endDate) {
                fourthDayPosters.append(todo)
            }
            
            if DateCaculate.isSameDate(fifthDate, endDate) {
                fifthDayPosters.append(todo)
            }
        }
        
        firstTableView.reloadData()
        secondTableView.reloadData()
        thirdTableView.reloadData()
        fourthTableView.reloadData()
        fifthTableView.reloadData()
    }
    
}

extension SelectedTodoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == firstTableView {
            return firstDayPosters.count
        } else if tableView == secondTableView {
            return secondDayPosters.count
        } else if tableView == thirdTableView {
            return thirdDayPosters.count
        } else if tableView == fourthTableView {
            return fourthDayPosters.count
        } else {
            return fifthDayPosters.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == thirdTableView {
            guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier) as? DetailTodoListTableViewCell else {
                return .init()
            }
            
            tableViewCell.selectionStyle = .none
            tableViewCell.poster = thirdDayPosters[indexPath.row]
            
            if thirdDayPosters[indexPath.row].photoUrl == tableViewCell.poster?.photoUrl {
                let imageURL = thirdDayPosters[indexPath.row].photoUrl ?? ""
                guard let url = URL(string: imageURL) else {return tableViewCell}
                
                ImageNetworkManager.shared.getImageByCache(imageURL: url){ (image, error) in
                    if error == nil {
                        tableViewCell.posterImageView.image = image
                    }
                }
            }
            
            return tableViewCell
        } else if tableView == firstTableView {
            guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier) as? DetailTodoListTableViewCell else {
                return .init()
            }
            
            tableViewCell.selectionStyle = .none
            tableViewCell.poster = firstDayPosters[indexPath.row]
            
            if firstDayPosters[indexPath.row].photoUrl == tableViewCell.poster?.photoUrl {
                let imageURL = firstDayPosters[indexPath.row].photoUrl ?? ""
                guard let url = URL(string: imageURL) else {return tableViewCell}
                
                ImageNetworkManager.shared.getImageByCache(imageURL: url){ (image, error) in
                    if error == nil {
                        tableViewCell.posterImageView.image = image
                    }
                }
            }
            
            return tableViewCell
        } else if tableView == secondTableView {
            guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier) as? DetailTodoListTableViewCell else {
                return .init()
            }
            
            tableViewCell.selectionStyle = .none
            tableViewCell.poster = secondDayPosters[indexPath.row]
            
            if secondDayPosters[indexPath.row].photoUrl == tableViewCell.poster?.photoUrl {
                let imageURL = secondDayPosters[indexPath.row].photoUrl ?? ""
                guard let url = URL(string: imageURL) else {return tableViewCell}
                
                ImageNetworkManager.shared.getImageByCache(imageURL: url){ (image, error) in
                    if error == nil {
                        tableViewCell.posterImageView.image = image
                    }
                }
            }
            
            return tableViewCell
        } else if tableView == fourthTableView {
            guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier) as? DetailTodoListTableViewCell else {
                return .init()
            }
            
            tableViewCell.selectionStyle = .none
            tableViewCell.poster = fourthDayPosters[indexPath.row]
            
            if fourthDayPosters[indexPath.row].photoUrl == tableViewCell.poster?.photoUrl {
                let imageURL = fourthDayPosters[indexPath.row].photoUrl ?? ""
                guard let url = URL(string: imageURL) else {return tableViewCell}
                
                ImageNetworkManager.shared.getImageByCache(imageURL: url){ (image, error) in
                    if error == nil {
                        tableViewCell.posterImageView.image = image
                    }
                }
            }
            
            return tableViewCell
        } else if tableView == fifthTableView {
            guard let tableViewCell = tableView.dequeueReusableCell(withIdentifier: SelectedTodoViewController.tableViewCellReuseIdentifier) as? DetailTodoListTableViewCell else {
                return .init()
            }
            
            tableViewCell.selectionStyle = .none
            tableViewCell.poster = fifthDayPosters[indexPath.row]
            
            if fifthDayPosters[indexPath.row].photoUrl == tableViewCell.poster?.photoUrl {
                let imageURL = fifthDayPosters[indexPath.row].photoUrl ?? ""
                guard let url = URL(string: imageURL) else {return tableViewCell}
                
                ImageNetworkManager.shared.getImageByCache(imageURL: url){ (image, error) in
                    if error == nil {
                        tableViewCell.posterImageView.image = image
                    }
                }
            }
            
            return tableViewCell
        }
        
        return .init()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let storyBoard = UIStoryboard(name: StoryBoardName.calendar, bundle: nil)
//        let CalendarDetailVC = storyBoard.instantiateViewController(withIdentifier: ViewControllerIdentifier.detailPosterViewController) as! CalendarDetailVC
//
        
        let detailInfoVC = DetailInfoViewController()
        
        if tableView == thirdTableView {
            detailInfoVC.posterIdx = thirdDayPosters[indexPath.row].posterIdx
        } else if tableView == firstTableView {
            detailInfoVC.posterIdx = firstDayPosters[indexPath.row].posterIdx
        } else if tableView == secondTableView {
            detailInfoVC.posterIdx = secondDayPosters[indexPath.row].posterIdx
        } else if tableView == fourthTableView {
            detailInfoVC.posterIdx = fourthDayPosters[indexPath.row].posterIdx
        } else if tableView == fifthTableView {
            detailInfoVC.posterIdx = fifthDayPosters[indexPath.row].posterIdx
        }
//
//        navigationController?.pushViewController(CalendarDetailVC, animated: true)
        
        navigationController?.pushViewController(detailInfoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let viewRect = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70)
        let view = UIView(frame: viewRect)
        view.backgroundColor = .white
        
        view.addSubview(dateLabel)
        dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        guard let date = currentDate else {return .init()}
        
        let firstDate = date.changeDaysBy(days: -2)
        
        let secondDate = date.changeDaysBy(days: -1)
        
        let fourthDate = date.changeDaysBy(days: 1)
        
        let fifthDate = date.changeDaysBy(days: 2)
        
        var tempText = ""
        if tableView == thirdTableView {
            let component = Calendar.current.dateComponents([.month, .day, .weekday], from: date)
            guard let weekDay = WeekDays(rawValue: component.weekday!) else {return .init()}
            tempText = "\(component.month!)월 \(component.day!)일 \(weekDay.koreanWeekdays)요일"
        } else if tableView == firstTableView {
            let component = Calendar.current.dateComponents([.month, .day, .weekday], from: firstDate)
            guard let weekDay = WeekDays(rawValue: component.weekday!) else {return .init()}
            tempText = "\(component.month!)월 \(component.day!)일 \(weekDay.koreanWeekdays)요일"
        } else if tableView == secondTableView {
            let component = Calendar.current.dateComponents([.month, .day, .weekday], from: secondDate)
            guard let weekDay = WeekDays(rawValue: component.weekday!) else {return .init()}
            tempText = "\(component.month!)월 \(component.day!)일 \(weekDay.koreanWeekdays)요일"
        } else if tableView == fourthTableView {
            let component = Calendar.current.dateComponents([.month, .day, .weekday], from: fourthDate)
            guard let weekDay = WeekDays(rawValue: component.weekday!) else {return .init()}
            tempText = "\(component.month!)월 \(component.day!)일 \(weekDay.koreanWeekdays)요일"
        } else if tableView == fifthTableView {
            let component = Calendar.current.dateComponents([.month, .day, .weekday], from: fifthDate)
            guard let weekDay = WeekDays(rawValue: component.weekday!) else {return .init()}
            tempText = "\(component.month!)월 \(component.day!)일 \(weekDay.koreanWeekdays)요일"
        }
        
        dateLabel.text = tempText
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
}

extension SelectedTodoViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < -80 {
            setDefaultScrollViewAndReloadTableView(using: -3)
        } else if scrollView.contentOffset.x > self.view.frame.width * 4 + 80 {
            setDefaultScrollViewAndReloadTableView(using: 3)
        }
        
        guard let date = currentDate else { return }
        
        let firstDate = date.changeDaysBy(days: -2)
        
        let secondDate = date.changeDaysBy(days: -1)
        
        let fourthDate = date.changeDaysBy(days: 1)
        
        let fifthDate = date.changeDaysBy(days: 2)
        
        if scrollView.contentOffset.x == 0 {
            delegate?.changeCurrentWindowDate(firstDate)
        } else if scrollView.contentOffset.x == self.view.frame.width {
            delegate?.changeCurrentWindowDate(secondDate)
        } else if scrollView.contentOffset.x == self.view.frame.width * 2 {
            delegate?.changeCurrentWindowDate(date)
        } else if scrollView.contentOffset.x == self.view.frame.width * 3 {
            delegate?.changeCurrentWindowDate(fourthDate)
        } else if scrollView.contentOffset.x == self.view.frame.width * 4 {
            delegate?.changeCurrentWindowDate(fifthDate)
        }
    }
}

extension SelectedTodoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self.scrollView
        {
            return false
        }
        return true
    }
}

extension Date {
    func changeDaysBy(days : Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}

enum WeekDays: Int {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thurday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var koreanWeekdays: String {
        switch self {
        case .monday:
            return "월"
        case .tuesday:
            return "화"
        case .wednesday:
            return "수"
        case .thurday:
            return "목"
        case .friday:
            return "금"
        case .saturday:
            return "토"
        case .sunday:
            return "일"
        }
    }
}
