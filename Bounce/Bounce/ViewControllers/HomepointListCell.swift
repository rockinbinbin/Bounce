//
//  HomepointListCell.swift
//  bounce
//
//  Created by Steven on 8/19/15.
//  Copyright (c) 2015 hobble. All rights reserved.
//

import UIKit

@objc enum HomepointType: Int {
    case Dorm
    case Neighborhood
    case House
    case Other
}

@objc public class HomepointListCell : UITableViewCell {
    
    let homepointName = UILabel()
    let cellBackground = UIImageView()
    let icon = UIImageView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Set cell background
        
        self.layoutMargins = UIEdgeInsetsZero
        
        cellBackground.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)
        self.backgroundView = cellBackground
        cellBackground.contentMode = UIViewContentMode.ScaleAspectFill
        
        // Set homepoint name
        
        homepointName.setTranslatesAutoresizingMaskIntoConstraints(false)
        homepointName.textColor = UIColor.whiteColor()
        homepointName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.contentView.addSubview(homepointName)
        homepointName.centerHorizontallyInSuperview()
        homepointName.centerVerticallyInSuperview(offset: 27)
        
        icon.image = UIImage(named: "Homepoints-Neighborhood-Icon-Small")
        self.contentView.addSubview(icon)
        icon.centerHorizontallyInSuperview()
        icon.positionAboveItem(homepointName, offset: 15)
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    func setBackground(image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        self.backgroundView = imageView
        
        let overlay = UIView()
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.backgroundView?.addSubview(overlay)
        overlay.pinToSideEdgesOfSuperview()
        overlay.pinToTopEdgeOfSuperview()
        overlay.pinToBottomEdgeOfSuperview()
        
        self.icon.removeFromSuperview()
        self.homepointName.removeFromSuperview()
        
        homepointName.setTranslatesAutoresizingMaskIntoConstraints(false)
        homepointName.textColor = UIColor.whiteColor()
        homepointName.font = UIFont(name: "AvenirNext-Medium", size: 18)
        self.contentView.addSubview(homepointName)
        homepointName.centerHorizontallyInSuperview()
        homepointName.centerVerticallyInSuperview(offset: 27)
        
        icon.image = UIImage(named: "Homepoints-Neighborhood-Icon-Small")
        self.contentView.addSubview(icon)
        icon.centerHorizontallyInSuperview()
        icon.positionAboveItem(homepointName, offset: 15)
        
        let borderView = UIView()
        borderView.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        self.contentView.addSubview(borderView)
        borderView.pinToBottomEdgeOfSuperview()
        borderView.pinToSideEdgesOfSuperview()
        borderView.sizeToHeight(1.0)
    }
    
    func setName(name: String, homepointType: HomepointType) {
        let attributedString = NSMutableAttributedString(string: name)
        attributedString.addAttribute(NSKernAttributeName, value: CGFloat(2.0), range: NSRange(location: 0, length: attributedString.length))
        self.homepointName.attributedText = attributedString
        
        if homepointType == HomepointType.Neighborhood {
            icon.image = UIImage(named: "Homepoints-Neighborhood-Icon-Small")
        } else if homepointType == HomepointType.Dorm {
            icon.image = UIImage(named: "Homepoints-Dorm-Icon-Small")
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

