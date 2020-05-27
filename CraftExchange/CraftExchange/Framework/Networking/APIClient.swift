//
//  Client.swift
//  ReactiveGitter
//
//  Created by Srdan Rasic on 14/01/2017.
//  Copyright © 2017 ReactiveKit. All rights reserved.
//

import ReactiveKit

// MARK: Initialization

extension Client {

    public func response<Resource, Error: Swift.Error>(for request: Request<Resource, Error>) -> Signal<Resource, Client.Error> {
        return Signal { observer in
            let task = self.perform(request) { result in
                switch result {
                case let .success(resource):
                    observer.receive(lastElement: resource)
                case let .failure(error):
                    observer.receive(completion: .failure(error))
                }
            }

            return BlockDisposable {
                task.cancel()
            }
        }
    }
}

extension Request {
    public func response(using client: Client) -> Signal<Resource, Client.Error> {
        return client.response(for: self)
    }
}
