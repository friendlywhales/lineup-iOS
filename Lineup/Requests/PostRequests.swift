//
//  PostRequests.swift
//  Lineup
//
//  Created by y8k on 10/04/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

class PostRequests {
    private static let path = "\(Constants.ServerURLString.apiEndPoint)/contents/posts/"
    private var accessToken: String?
    private var contentID: String?

    private var headers: [String: String]? {
        var header = Constants.appInformation

        if let accessToken = accessToken {
            header["Authorization"] = "Token \(accessToken)"
        }

        return header
    }

    private var headersForMultiform: [String: String]? {
        var header = Constants.appInformation
        header["Content-Type"] = "multipart/form-data; charset=utf-8;"

        if let accessToken = accessToken {
            header["Authorization"] = "Token \(accessToken)"
        }
        return header
    }

    struct PreparedContentResponse: Codable {
        let contentID: String

        enum CodingKeys: String, CodingKey {
            case contentID = "uid"
        }
    }

    static func checkStatusCode(code: Int) -> Bool {
        guard 200..<300 ~= code else { return false }
        return true
    }

    required init(accessToken: String) {
        self.accessToken = accessToken
    }

    func prepare() -> Single<PreparedContentResponse> {
        return Single<PreparedContentResponse>.create(subscribe: { observer -> Disposable in
            return RxAlamofire
                .requestData(.post, PostRequests.path, headers: self.headers)
                .debug()
                .subscribe(onNext: { [weak self] result in
                    let statusCode = result.0.statusCode
                    guard PostRequests.checkStatusCode(code: statusCode) else {
                        observer(.error(LineUpErrors.errorStatusCode(
                            statusCode,
                            message: String(data: result.1, encoding: .utf8)))
                        )
                        return
                    }

                    guard let model = try? JSONDecoder().decode(PreparedContentResponse.self, from: result.1) else {
                        observer(.error(LineUpErrors.errorDecodingResponseModel))
                        return
                    }

                    self?.contentID = model.contentID
                    observer(.success(model))
                    }, onError: { error in
                        observer(.error(error))
                })
        })
    }

    func upload(photoURLs: [URL], progressHandler: @escaping ((Double) -> Void)) -> Single<Bool> {
        return Single<Bool>.create(subscribe: { observer -> Disposable in
            guard let contentID = self.contentID else {
                observer(.error(LineUpErrors.errorMissingEssentialParameter))
                return Disposables.create()
            }

            let URLString = PostRequests.path + contentID + "/attachments/"

            Alamofire.upload(multipartFormData: { formData in
                photoURLs.enumerated().forEach({ fileURL in
                    guard let indexData = "\(fileURL.offset)"
                        .data(using: String.Encoding.utf8, allowLossyConversion: false) else { fatalError("Rare!!") }
                    formData.append(
                        indexData,
                        withName: "order"
                    )
                    formData.append(
                        fileURL.element,
                        withName: "content",
                        fileName: "\(fileURL.offset).jpg",
                        mimeType: "image/jpeg"
                    )
                })
            },
               to: URLString, method: .post, headers: self.headersForMultiform, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let request, _, _):
                    request.responseJSON(completionHandler: { result in
                        guard let response = result.response else { fatalError("Abnormal case...") }
                        let statusCode = response.statusCode
                        guard PostRequests.checkStatusCode(code: response.statusCode) else {

                            var message: String?
                            if let body = result.data, let text = String(data: body, encoding: .utf8) {
                                message = text
                            }

                            observer(.error(LineUpErrors.errorStatusCode(
                                statusCode,
                                message: message))
                            )
                            return
                        }

                        observer(.success(true))
                    })
                    request.uploadProgress(closure: { progress in
                        progressHandler(progress.fractionCompleted)
                    })
                case .failure(let error):
                    observer(.error(error))
                }
            })

            return Disposables.create()
        })
    }

    func comment(_ comment: String?) -> Single<Bool> {
        return Single<Bool>.create(subscribe: { observer -> Disposable in

            guard let contentID = self.contentID else {
                observer(.error(LineUpErrors.errorMissingEssentialParameter))
                return Disposables.create()
            }

            let URLString = PostRequests.path + contentID + "/"

            var parameters: [String: Any]?
            if let comment = comment {
                parameters = ["content": comment]
            }

            return RxAlamofire
                .requestData(.patch, URLString, parameters: parameters, headers: self.headers)
                .subscribe(onNext: { result in
                    let statusCode = result.0.statusCode

                    guard PostRequests.checkStatusCode(code: statusCode) else {
                        observer(.error(LineUpErrors.errorStatusCode(
                            statusCode,
                            message: String(data: result.1, encoding: .utf8)))
                        )
                        return
                    }

                    observer(.success(true))
                }, onError: { error in
                    print(error)
                    observer(.error(error))
                })
        })
    }

    func publish() -> Single<Bool> {
        return Single<Bool>.create(subscribe: { observer -> Disposable in
            guard let contentID = self.contentID else {
                observer(.error(LineUpErrors.errorMissingEssentialParameter))
                return Disposables.create()
            }

            let URLString = PostRequests.path + contentID + "/publish/"
            return RxAlamofire
                .requestData(.post, URLString, parameters: [:], headers: self.headers)
                .subscribe(onNext: { result in
                    let statusCode = result.0.statusCode

                    guard PostRequests.checkStatusCode(code: statusCode) else {
                        observer(.error(LineUpErrors.errorStatusCode(
                            statusCode,
                            message: String(data: result.1, encoding: .utf8)))
                        )
                        return
                    }

                    observer(.success(true))
                }, onError: { error in
                    observer(.error(error))
                })
        })
    }
}
