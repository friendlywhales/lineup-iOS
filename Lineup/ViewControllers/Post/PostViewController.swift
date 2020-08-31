//
//  PostViewController.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import RxCocoa
import RxSwift
import RxDataSources
import UIKit
import MBProgressHUD

class PostViewController: BaseViewController {
    typealias Completion = (String?) -> Void

    private let viewHolder = ViewHolder()
    private let disposeBag = DisposeBag()
    private let dataProvider: DataProvider

    private var completion: Completion?

    /// DataSource for representing selected photos
    private var dataSource: RxCollectionViewSectionedReloadDataSource<PhotoRepresenter.PhotoSectionViewModel> {
        return RxCollectionViewSectionedReloadDataSource<PhotoRepresenter.PhotoSectionViewModel>(
            configureCell: { dataSource, collectionView, indexPath, viewModel in
                let identifier = PostPhotoCollectionViewCollectionViewCell.reuseIdentifier
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: identifier,
                    for: indexPath) as? PostPhotoCollectionViewCollectionViewCell else { fatalError() }

                cell.viewModel = viewModel

                return cell
        })
    }

    required init(accessToken: String, completion: Completion?) {
        self.dataProvider = DataProvider(accessToken: accessToken)
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "글쓰기"
        navigationItem.leftBarButtonItem = viewHolder.closeBarButtonItem
        navigationItem.rightBarButtonItem = viewHolder.uploadBarButtonItem

        viewHolder.install(at: self)
        viewHolder.commentTextView.inputAccessoryView = viewHolder.keyboardButton

        bindCloseBarButtonItemAction()
        bindUploadBarButtonItemAction()
        bindEnableUploadButtonState()

        bindKeyboardDoneButtonAction()

        bindPhotoDataSource()
        bindPhotoSelectEvent()

        bindPostSequence()
        bindUploadProgress()
        bindCommentText()
    }

    private func presentPhotoPicker() {
        PhotoManager.shared.selectedPhotos
            .subscribe(onNext: { [weak self] assets in
                self?.dataProvider.selectedPhotos = assets
            }).disposed(by: disposeBag)

        PhotoManager.shared.presentPhotoListIfAvailable(from: self)
    }

    private func prepareUploading() {
        if let view = navigationController?.view {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.mode = .annularDeterminate
            hud.backgroundColor = UIColor(white: 0.0 / 255.0, alpha: 0.5)
            hud.label.font = .systemFont(ofSize: 14.0)
            hud.label.text = "업로드 준비 중"
        }

        requestContentID()
    }

    private func alertError(message: String) {
        let alertController = UIAlertController(title: "앗!", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)

        alertController.addAction(confirmAction)

        present(alertController, animated: true, completion: nil)
    }

    private func deleteImagesInTempDirectory() {
        let fileManager = FileManager.default
        let directoryURL = fileManager.temporaryDirectory
        guard let fileURLs = try? fileManager
            .contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: []) else {
                return
        }

        fileURLs.forEach({ try? fileManager.removeItem(at: $0) })
    }

    private func requestContentID() {
        dataProvider.prepare()
            .subscribe(onSuccess: { [weak self] _ in
                self?.cachingSelectedPhotos()
            }, onError: ({ [weak self] error in
                self?.removeHUD()
                self?.alertError(message: error.localizedDescription)
            })).disposed(by: disposeBag)
    }

    private func cachingSelectedPhotos() {
        dataProvider.cachingSelectedImages()?
            .subscribe(onNext: { [weak self] fileURLs in
                self?.upload(fileURLs: fileURLs)
            }, onError: ({ [weak self] error in
                self?.removeHUD()
                self?.alertError(message: error.localizedDescription)
            })).disposed(by: disposeBag)
    }

    private func upload(fileURLs: [URL]) {
        dataProvider.upload(fileURL: fileURLs)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.update()
            }, onError: ({ [weak self] error in
                self?.removeHUD()
                self?.alertError(message: error.localizedDescription)
            })).disposed(by: disposeBag)
    }

    private func update() {
        dataProvider.update()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.publish()
            }, onError: ({ [weak self] error in
                self?.removeHUD()
                self?.alertError(message: error.localizedDescription)
            })).disposed(by: disposeBag)
    }

    private func publish() {
        dataProvider.publish()
            .subscribeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] _ in
                self?.removeHUD()
                self?.completion?(self?.dataProvider.contentID)

                PhotoManager.shared.selectedPhotos.accept(nil)

                self?.dismiss(animated: true, completion: {
                    self?.deleteImagesInTempDirectory()
                })
            }, onError: ({ [weak self] error in
                self?.removeHUD()
                self?.alertError(message: error.localizedDescription)
            })).disposed(by: disposeBag)
    }
}

/// MARK: - Prepare subscribing events
extension PostViewController {
    private func bindCloseBarButtonItemAction() {
        viewHolder.closeBarButtonItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                PhotoManager.shared.selectedPhotos.accept(nil)
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    private func bindUploadBarButtonItemAction() {
        viewHolder.uploadBarButtonItem.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.view.endEditing(true)
                self?.requestContentID()
            }).disposed(by: disposeBag)
    }

    private func bindPhotoDataSource() {
        dataProvider.viewModels
            .bind(to: viewHolder.attachedImageCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func bindPhotoSelectEvent() {
        viewHolder.attachedImageCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let viewModel = self?.dataProvider.viewModel(indexPath: indexPath),
                    viewModel.attachIndicator else { return }
                self?.presentPhotoPicker()
            }).disposed(by: disposeBag)
    }

    private func bindEnableUploadButtonState() {
        dataProvider.viewModels
            .map({ sectionViewModel -> Bool in
                return !sectionViewModel.compactMap({ $0.items }).reduce([], +).filter({ $0.asset != nil }).isEmpty
            }).bind(to: viewHolder.uploadBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func bindCommentText() {
        viewHolder.commentTextView.rx.text
            .subscribe(onNext: { [weak self] text in
                self?.controlPlaceholderLabel(text: text)
                self?.dataProvider.comment = text
            }).disposed(by: disposeBag)
    }

    private func controlPlaceholderLabel(text: String?) {
        viewHolder.placeholderLabel.isHidden = !(text?.isEmpty ?? true)
    }

    private func bindKeyboardDoneButtonAction() {
        viewHolder.keyboardButton.doneButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.viewHolder.commentTextView.resignFirstResponder()
            }).disposed(by: disposeBag)
    }

    private func bindUploadProgress() {
        dataProvider.uploadProgress.subscribe(onNext: { [weak self] ratio in
            guard let view = self?.navigationController?.view else { return }
            guard let hud = MBProgressHUD(for: view) else { return }
            guard ratio > 0.0 else { return }

            hud.mode = .determinate
            hud.progress = Float(ratio)

        }).disposed(by: disposeBag)
    }

    private func bindPostSequence() {
        dataProvider.postSequence
            .subscribe(onNext: { [weak self] sequence in
                self?.controlHUD(sequence: sequence)
            }).disposed(by: disposeBag)
    }

    private func controlHUD(sequence: DataProvider.PostSequence) {
        guard let view = navigationController?.view else { return }
        guard sequence != .idle else {
            MBProgressHUD(for: view)?.hide(animated: true)
            return
        }

        var HUD = MBProgressHUD(for: view)

        if HUD == nil {
            HUD = MBProgressHUD.showAdded(to: view, animated: true)
        }

        HUD?.label.font = .systemFont(ofSize: 14.0)
        HUD?.backgroundColor = UIColor(white: 0.0 / 255.0, alpha: 0.5)

        switch sequence {
        case .requestContentID, .querySelectedPhotos:
            HUD?.mode = .indeterminate
            HUD?.label.text = "업로드 준비 중"
        case .uploadSelectedPhotos:
            HUD?.mode = .annularDeterminate
            HUD?.label.text = "업로드 중"
        case .updateComment:
            HUD?.mode = .indeterminate
            HUD?.label.text = "작성 마무리 중"
        case .publish:
            HUD?.mode = .customView
            HUD?.label.text = "완료"
        default:
            break
        }
    }

    private func removeHUD() {
        guard let view = navigationController?.view else { return }
        MBProgressHUD(for: view)?.hide(animated: true)
    }
}
