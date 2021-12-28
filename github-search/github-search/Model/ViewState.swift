//
//  ViewState.swift
//  github-search
//
//  Created by Liubov Kovalchuk on 26.12.2021.
//

import Foundation

enum ViewState {
    case new
    case opened
}

extension ViewState: CustomStringConvertible {
    var description: String {
        switch self {
        case .new:
            return "new"
        case .opened:
        return "opened"
        }
    }
}
