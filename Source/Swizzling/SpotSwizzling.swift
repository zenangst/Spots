import UIKit
import ObjectiveC.runtime

func swizzleUICollectionViewLayoutFinalizeCollectionViewUpdates() {
  let classToSwizzle = UICollectionViewLayout.self
  let selectorToSwizzle: Selector = "finalizeCollectionViewUpdates"

  replaceMethodWithBlock(classToSwizzle, originalSelector: selectorToSwizzle) { (object) -> Void in
    guard let layout = object as? UICollectionViewLayout else { return }

  }
}

func swizzleUITableView() {

}

func replaceMethodWithBlock(c: AnyClass, originalSelector: Selector, block: @convention(block) (AnyObject!) -> Void) -> IMP {
  let originalMethod = class_getInstanceMethod(c, originalSelector)
  let newImplementation = imp_implementationWithBlock((unsafeBitCast(block, AnyObject.self)))

  if (!class_addMethod(c, originalSelector, newImplementation, method_getTypeEncoding(originalMethod))) {
    return method_setImplementation(originalMethod, newImplementation);
  }else {
    return method_getImplementation(originalMethod);
  }
}
