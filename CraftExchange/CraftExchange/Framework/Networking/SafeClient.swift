//
//  SafeClient.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 07/05/2017.
//  Copyright © 2017 ReactiveKit. All rights reserved.
//

import Foundation
import ReactiveKit

public struct UserFriendlyError: Error {

    public let title: String
    public let message: String
    public let retry: PassthroughSubject<Void, Never>?
    
    public init(error: Error, canRetry: Bool) {
        if let error = error as? Client.Error {
            switch error {
            case .client(let message):
                self.title = "Client Error"
                self.message = message
            case .network(let error, let code):
                self.title = "Network Error"
                self.message = "Error Code \(code)\n\(error.localizedDescription)"
            case .remote(let error, let code):
                self.title = "API Error"
                if let error = error as? APIError {
                    self.message = error.message
                } else {
                    self.message = "Error Code \(code)\n\(error.localizedDescription)"
                }
            case .parser(let error):
                self.title = "Parser Error"
                self.message = error.localizedDescription
            }
        } else {
            self.title = "Error Occured"
            self.message = error.localizedDescription
        }
        if canRetry {
            retry = PassthroughSubject()
        } else {
            retry = nil
        }
    }
}

public class SafeClient {

    public let base: Client
    public let errors = PassthroughSubject<UserFriendlyError, Never>()
    public let activity = Activity()

    public init(wrapping client: Client) {
        base = client
    }

    public func response<Resource, Error: Swift.Error>(for request: Request<Resource, Error>, canUserRetry: Bool = true, autoRetryTimes: Int = 0, trackActivity: Bool = true) -> SafeSignal<Resource> {
        if trackActivity {
            return base
                .response(for: request)
                .retry(autoRetryTimes)
                .feedActivity(into: activity)
                .debug(request.path)
                .suppressAndFeedError(into: errors, canUserRetry: canUserRetry, map: { $0.localizedDescription })
        } else {
            return base
                .response(for: request)
                .retry(autoRetryTimes)
                .debug(request.path)
                .suppressAndFeedError(into: errors, canUserRetry: canUserRetry, map: { $0.localizedDescription })
        }
    }

    public func unsafeResponse<Resource, Error: Swift.Error>(for request: Request<Resource, Error>, trackActivity: Bool = true) -> Signal<Resource, Client.Error> {
        if trackActivity {
            return base.response(for: request).feedActivity(into: activity)
        } else {
            return base.response(for: request)
        }
    }
}

extension Request {

    public func response(using client: SafeClient, canUserRetry: Bool = true, autoRetryTimes: Int = 0, trackActivity: Bool = true) -> SafeSignal<Resource> {
        return client.response(for: self, canUserRetry: canUserRetry, autoRetryTimes: autoRetryTimes, trackActivity: trackActivity)
    }

    public func unsafeResponse(using client: SafeClient, trackActivity: Bool = true) -> Signal<Resource, Client.Error> {
        return client.unsafeResponse(for: self, trackActivity: trackActivity)
    }
}

extension SignalProtocol {

    public func feedError<S: SubjectProtocol>(into subject: S, canUserRetry: Bool, map: @escaping (Error) -> String) -> Signal<Element, Error> where S.Element == UserFriendlyError {
        return Signal { observer in
            let serialDisposable = SerialDisposable(otherDisposable: nil)
            var attempt: (() -> Void)? = nil
            attempt = {
                let disposables = CompositeDisposable()
                serialDisposable.otherDisposable?.dispose()
                serialDisposable.otherDisposable = disposables
                disposables += self.observe { event in
                    switch event {
                    case .next(let element):
                        observer.receive(element)
                    case .completed:
                        attempt = nil
                        observer.receive(completion: .finished)
                    case .failed(let error):
                        if canUserRetry {
                            let ce = UserFriendlyError(error: error, canRetry: canUserRetry)
                            disposables += ce.retry!.observe { event in
                                switch event {
                                case .next:
                                    attempt?()
                                case .completed, .failed:
                                    attempt = nil
                                    observer.receive(completion: .failure(error))
                                }
                            }
                            subject.send(ce)
                        } else {
                            attempt = nil
                            subject.send(UserFriendlyError(error: error, canRetry: false))
                            observer.receive(completion: .failure(error))
                        }
                    }
                }
            }
            attempt?()
            return serialDisposable
        }
    }
    
    public func suppressAndFeedError<S: SubjectProtocol>(into subject: S, canUserRetry: Bool, map: @escaping (Error) -> String) -> Signal<Element, Never> where S.Element == UserFriendlyError {
        return feedError(into: subject, canUserRetry: canUserRetry, map: map).suppressError(logging: true)
    }
}
