//
//  MyFilterGradeCollectionViewCellReactor.swift
//  SsgSag
//
//  Created by bumslap on 29/11/2019.
//  Copyright © 2019 wndzlf. All rights reserved.
//

import UIKit
import RxSwift
import ReactorKit

class MyFilterGradeCollectionViewCellReactor: Reactor {
    enum Action {
        case select(Int)
     }

    enum Mutation {
        case setSelected(Bool)
        case setTextColor(UIColor)
     }

    struct State {
        var gradeTextColor: UIColor
        var gradeText: String
        var index: Int
        var isSelected: Bool
     }
    
    let initialState: State

    init(gradeText: String, isSelected: Bool, index: Int) {
        let gradeTextColor: UIColor = isSelected ? .cornFlower : .unselectedTextGray
        self.initialState = State(gradeTextColor: gradeTextColor,
                                  gradeText: gradeText,
                                  index: index,
                                  isSelected: isSelected)
    }

       // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .select(let value):
            let color: UIColor = value == self.currentState.index ? .cornFlower : .unselectedTextGray
             return Observable.just(Mutation.setTextColor(color))
        }
    }

       // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setSelected(let isSelected):
            state.isSelected = isSelected
        case .setTextColor(let color):
            state.gradeTextColor = color
        }
        return state
    }
}
