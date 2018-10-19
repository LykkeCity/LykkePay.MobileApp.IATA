import UIKit

public class Utils: NSObject {
    public static func rgb(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0,
                       green: CGFloat(green) / 255.0,
                       blue: CGFloat(blue) / 255.0,
                       alpha: 1.0)
    }
    
    public static func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    public static func setButtonBackground(_ button: UIButton, havingColor color: UIColor, for state: UIControlState) {
        button.setBackgroundImage(imageWithColor(color: color), for: state)
    }
    
    public static func matchView(_ view: UIView, sizeToParent parent: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        parent.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        parent.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        parent.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        parent.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    public static func addOvalBorder(to view: UIView, havingColor: UIColor, cornerRadius: CGFloat) {
        view.layer.borderColor = havingColor.cgColor
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.cornerRadius = cornerRadius
    }
    
    public static func shortNameFor(class aClass: AnyClass) -> String {
        guard let shortClassName = NSStringFromClass(aClass).split(separator: ".").last else {
            return ""
        }
        return String(shortClassName)
    }
    
    public static func read(resource: String, ofType: String, fromBundle: Bundle = Bundle.main) -> String? {
        guard let jsonPath = fromBundle.path(forResource: resource, ofType: ofType) else {
            return nil
        }
        return try? String(contentsOfFile: jsonPath, encoding: .utf8)
    }
    
   
    
    
    public static func firstAfter<T>(array: [T],
                                     where predicate: (T) -> Bool,
                                     skip skipPredicate: (T) -> Bool) -> T? {
        let index = array.index(where: predicate)
        guard let indexUnwrapped = index else {
            return nil
        }
        return skip(array: array,
                    first: indexUnwrapped + 1,
                    skip: skipPredicate)
    }
    
    public static func skip<T>(array: [T],
                               first index: Int,
                               skip skipPredicate: (T) -> Bool) -> T? {
        for i in index..<array.count {
            if skipPredicate(array[i]) {
                continue
            }
            return array[i]
        }
        return nil
    }
    
    public static func notEmty(_ str: String?) -> Bool {
        guard let str = str else {
            return false
        }
        return !str.isEmpty
    }
    
}
