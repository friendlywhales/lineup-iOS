//
//  PostViewController+ViewHolder.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit
import MBProgressHUD

class KeyboardAccessoryButton: BaseView {
    private(set) lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage.image(from: .deepPurple), for: .normal)
        button.setBackgroundImage(UIImage.image(from: UIColor.deepPurple.alphaComponent(alpha: 0.8)), for: .highlighted)

        return button
    }()

    override func configure() {
        super.configure()

        backgroundColor = .deepPurple

        addSubview(doneButton)

        doneButton.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(1)
        }
    }
}

extension PostViewController {
    class ViewHolder {
        private(set) lazy var closeBarButtonItem: UIBarButtonItem = {
            return UIBarButtonItem(title: "닫기", style: .plain, target: nil, action: nil)
        }()

        private(set) lazy var uploadBarButtonItem: UIBarButtonItem = {
            return UIBarButtonItem(title: "올리기", style: .plain, target: nil, action: nil)
        }()

        private(set) lazy var keyboardButton: KeyboardAccessoryButton = {
            let bounds = UIScreen.main.bounds
            return KeyboardAccessoryButton(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 45.0))
        }()

        private(set) var progressHUD: MBProgressHUD?

        private(set) lazy var attachedImageCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 80.0, height: 80.0)
            layout.minimumInteritemSpacing = 0.0
            layout.minimumLineSpacing = 0.0
            layout.scrollDirection = .horizontal

            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
            collectionView.backgroundColor = .deepPurple
            collectionView.alwaysBounceHorizontal = true

            collectionView.register(
                PostPhotoCollectionViewCollectionViewCell.self,
                forCellWithReuseIdentifier: PostPhotoCollectionViewCollectionViewCell.reuseIdentifier
            )

            return collectionView
        }()

        private(set) lazy var commentTextView: UITextView = {
            let textView = UITextView()
            textView.font = .systemFont(ofSize: 14.0)
            textView.textColor = .gray51
            textView.autocapitalizationType = .none
            textView.autocorrectionType = .no
            textView.returnKeyType = .default
            textView.keyboardType = .default
            textView.dataDetectorTypes = []
            textView.backgroundColor = .white

            textView.layer.cornerRadius = 5.0
            textView.layer.masksToBounds = true

            return textView
        }()

        private(set) lazy var placeholderLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14.0)
            label.textColor = .gray136
            label.textAlignment = .left
            label.numberOfLines = 1
            label.text = "여기를 눌러 설명을 작성해주세요"

            return label
        }()

        func install(at viewController: UIViewController) {
            viewController.view.addSubview(attachedImageCollectionView)
            viewController.view.addSubview(commentTextView)
            viewController.view.addSubview(placeholderLabel)

            viewController.view.backgroundColor = .gray221

            attachedImageCollectionView.snp.makeConstraints { maker in
                maker.leading.trailing.equalToSuperview()
                maker.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top)
                maker.height.equalTo(100)
            }

            commentTextView.snp.makeConstraints { maker in
                maker.leading.trailing.equalToSuperview().inset(5)
                maker.top.equalTo(attachedImageCollectionView.snp.bottom).offset(5)
                maker.height.equalTo(150)
            }

            placeholderLabel.snp.makeConstraints { maker in
                maker.leading.equalTo(commentTextView.snp.leading).inset(5)
                maker.top.equalTo(commentTextView.snp.top).inset(7)
                maker.trailing.lessThanOrEqualTo(commentTextView.snp.trailing)
                maker.bottom.lessThanOrEqualTo(commentTextView.snp.bottom)
            }
        }
    }
}
