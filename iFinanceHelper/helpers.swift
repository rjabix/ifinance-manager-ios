//
//  helpers.swift
//  iFinanceHelper
//
//  Created by Vlad on 14/03/2026.
//

import Foundation
import SwiftUI

    // Source - https://stackoverflow.com/a/61002589
    // Posted by Jonathan.
    // Retrieved 2026-03-14, License - CC BY-SA 4.0

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
        Binding(
            get: { lhs.wrappedValue ?? rhs },
            set: { lhs.wrappedValue = $0 }
        )
}
