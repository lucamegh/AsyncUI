/**
 * AsyncUI
 * Copyright (c) Luca Meghnagi 2021
 * MIT license, see LICENSE file for details
 */

public struct RetryAction {
    
    private let retry: () -> Void
    
    init(_ retry: @escaping () -> Void) {
        self.retry = retry
    }
    
    func callAsFunction() {
        retry()
    }
}
