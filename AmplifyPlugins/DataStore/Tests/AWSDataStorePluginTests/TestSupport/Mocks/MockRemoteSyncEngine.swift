//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation
import AWSPluginsCore
import Combine

@testable import Amplify
@testable import AmplifyTestCommon
@testable import AWSDataStorePlugin

typealias OnSubmitCallBack = (MutationEvent, @escaping (Result<MutationEvent, DataStoreError>) -> Void) -> Void

class MockRemoteSyncEngine: RemoteSyncEngineBehavior {
    var syncing = false

    func submit(_ mutationEvent: MutationEvent, completion: @escaping (Result<MutationEvent, DataStoreError>) -> Void) {
        if let callback = callbackOnSubmit {
            callback(mutationEvent, completion)
        } else {
            completion(.success(mutationEvent))
        }
    }

    let remoteSyncTopicPublisher: PassthroughSubject<RemoteSyncEngineEvent, DataStoreError>
    var callbackOnSubmit: OnSubmitCallBack?
    var success = true

    var publisher: AnyPublisher<RemoteSyncEngineEvent, DataStoreError> {
        return remoteSyncTopicPublisher.eraseToAnyPublisher()
    }

    init() {
        self.remoteSyncTopicPublisher = PassthroughSubject<RemoteSyncEngineEvent, DataStoreError>()
    }
    func start(api: APICategoryGraphQLBehavior, auth: AuthCategoryBehavior?) {
        syncing = true
    }

    func stop(completion: @escaping DataStoreCallback<Void>) {
        syncing = false
        completion(.successfulVoid)
    }

    func isSyncing() -> Bool {
        return syncing
    }

    func setCallbackOnSubmit(callbackOnSubmit: @escaping OnSubmitCallBack) {
        self.callbackOnSubmit = callbackOnSubmit
    }
}
