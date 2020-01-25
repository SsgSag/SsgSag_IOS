//
//  MyFilterButtonCollectionViewCellReactor.swift
//  SsgSag
//
//  Created by bumslap on 30/11/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

private enum Section: Int {
    case jobKind
    case interestedField
    case userGrade
    
    init(section: Int) {
        self = Section(rawValue: section)!
    }
    
    init(at indexPath: IndexPath) {
        self = Section(rawValue: indexPath.section)!
    }
}

class MyFilterButtonCollectionViewCellReactor: Reactor, MyFilterCollectionViewCellReactor {
    enum Action {
        case set
        case userPressed(IndexPath, Int)
    }

    enum Mutation {
        case setBorderColor(UIColor)
        case setTextColor(UIColor)
        case setSelected(Bool)
        case setTextFont(UIFont)
        case empty
    }

    struct State {
        var textFont: UIFont
        var borderColor: UIColor
        var textColor: UIColor
        var titleText: String
        var isSelected: Bool
        var indexPath: IndexPath
    }
       
    let initialState: State

    init(titleText: String, isSelected: Bool, indexPath: IndexPath) {
        self.initialState = State(textFont: UIFont.systemFont(ofSize: 13, weight: .regular),
                                  borderColor: UIColor.unselectedBorderGray,
                                  textColor: UIColor.unselectedGray,
                                  titleText: titleText,
                                  isSelected: isSelected,
                                  indexPath: indexPath)
       }

          // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .set:
            if currentState.isSelected {
                return Observable.concat([
                    Observable.just(Mutation.setBorderColor(.cornFlower)),
                    Observable.just(Mutation.setTextFont(.systemFont(ofSize: 13, weight: .semibold))),
                    Observable.just(Mutation.setTextColor(.cornFlower))
                ])
            } else {
                return Observable.just(Mutation.empty)
            }
        case .userPressed(let eventValue):
            let section = Section(at: eventValue.0)
            switch section {
            case .jobKind:
                var borderColor: UIColor = .unselectedBorderGray
                var textColor: UIColor = .unselectedGray
                if currentState.isSelected {
                    guard eventValue.1 > 1 else {
                            return Observable.just(Mutation.empty)
                        }
                        borderColor = .unselectedBorderGray
                        textColor = .unselectedGray
                    return Observable.concat([
                        Observable.just(Mutation.setSelected(!currentState.isSelected)),
                        Observable.just(Mutation.setBorderColor(borderColor)),
                        Observable.just(Mutation.setTextFont(UIFont.systemFont(ofSize: 13, weight: .regular))),
                        Observable.just(Mutation.setTextColor(textColor))
                    ])
                } else {
                    borderColor = .cornFlower
                    textColor = .cornFlower
                    return Observable.concat([
                        Observable.just(Mutation.setSelected(!currentState.isSelected)),
                        Observable.just(Mutation.setBorderColor(borderColor)),
                        Observable.just(Mutation.setTextFont(UIFont.systemFont(ofSize: 13, weight: .semibold))),
                        Observable.just(Mutation.setTextColor(textColor))
                    ])
                }
               
            case .interestedField:
                var borderColor: UIColor = .unselectedBorderGray
                var textColor: UIColor = .unselectedGray
                var font: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
                if currentState.isSelected {
                    borderColor = .unselectedBorderGray
                    textColor = .unselectedGray
                } else {
                    borderColor = .cornFlower
                    textColor = .cornFlower
                    font = UIFont.systemFont(ofSize: 13, weight: .semibold)
                }
                return Observable.concat([
                    Observable.just(Mutation.setSelected(!currentState.isSelected)),
                    Observable.just(Mutation.setBorderColor(borderColor)),
                    Observable.just(Mutation.setTextFont(font)),
                    Observable.just(Mutation.setTextColor(textColor))
                ])
            default:
                assertionFailure("can't handle")
                return Observable.just(Mutation.empty)
            }
        }
    }

          // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setTextFont(let font):
            state.textFont = font
        case .setBorderColor(let color):
            state.borderColor = color
        case .setTextColor(let color):
            state.textColor = color
        case .setSelected(let isSelected):
            state.isSelected = isSelected
        case .empty:
            break
        }
        return state
    }
}
