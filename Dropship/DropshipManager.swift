//
//  DropshipManager.swift
//
//  Created by Nahuel Marisi on 2015-12-03.


typealias DragDropView = protocol<UIDynamicItem, NSObjectProtocol>

protocol Catchable: DragDropView {
    
}

@objc protocol Draggable : DragDropView {
    
    optional func didBeginDragging()
    optional func didEndDragging()
}

protocol DropshipDelegate {
    func didBeginDragging(draggable: UIView)
    func didEndDragging(draggable: Draggable, onDropArea: Bool)
    
}

class TestView: UIView, Draggable {
    func didBeginDragging() {
    }
    func didEndDragging() {
        
    }
}

class TestImageView: UIImageView, Draggable {
    func didBeginDragging() {
    }
    func didEndDragging() {
        
    }
}

class DropView: UIView, Catchable {
    
}

class DropshipGestureRecognizer: UIPanGestureRecognizer {
    
}

extension UIView {
    
    private func removeDropshipGestureFromView() {
        
        guard var gestures = self.gestureRecognizers else {
            return
        }
        
        for (index, gesture) in gestures.enumerate() {
            
            if gesture is DropshipGestureRecognizer {
                gestures.removeAtIndex(index)
            }
        }
    }
}

class DropshipManager: NSObject, UIDynamicAnimatorDelegate {
    
    var draggableItems = [Draggable]()
    var catchableItems = [UIView]()
    
    var delegate: DropshipDelegate?
    var dynamicAnimator: UIDynamicAnimator
    
    // TODO: hack for testing
    var lastLocation: CGPoint = CGPointZero
   
    // A view that is shared by both the draggable and droppable items.
    // The dragging will occur inside this view.
    // Usually the UIViewController's view.
    var mainView: UIView
    
    init(mainView: UIView) {
        self.mainView = mainView
        self.dynamicAnimator = UIDynamicAnimator(referenceView: mainView)
        super.init()
        self.dynamicAnimator.delegate = self
    }
   
    func registerDraggableItem<T: UIView where T: Draggable>(item: T) {
        draggableItems.append(item)
        
        let panGesture = DropshipGestureRecognizer(target: self, action: "draggingView:")
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        item.addGestureRecognizer(panGesture)
    }
    
    func deregisterDraggableItem<T: UIView where T: Draggable>(item: T) {
        
        for (index, draggableItem) in draggableItems.enumerate() {
            if draggableItem.isEqual(item) {
                
                item.removeDropshipGestureFromView()
                draggableItems.removeAtIndex(index)
                
                }
        }
    }
    
    func registerDroppableItem<T: UIView where T: Catchable>(item: T) {
        catchableItems.append(item)
    }
    
    func deregisterDroppableItem<T: UIView where T: Catchable>(item: T) {
        
        for (index, droppableItem) in catchableItems.enumerate() {
            if droppableItem.isEqual(item) {
                catchableItems.removeAtIndex(index)
            }
        }
    }
    
    // MARK: DropshipGestureRecognizer action
    func draggingView(sender: DropshipGestureRecognizer) {
       
       //guard let view = sender.view where view is Draggable else {
       guard let view = sender.view else {
            return
        }
   
        switch (sender.state) {
        case .Began:
            delegate?.didBeginDragging(view)
            
            view.superview?.bringSubviewToFront(view)
            lastLocation = view.center
            
        case .Changed:
            let translation = sender.translationInView(view.superview!)
            let lastLocation = view.center
            view.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
            sender.setTranslation(CGPointZero, inView: view.superview!)
    
    
    
        case .Cancelled:
            dragBack(view)
        
        case .Ended:
            guard let del = delegate, draggable = view as? Draggable else {
                return
            }
            
            
            if checkIfViewIsInDropArea(view, gesture: sender)  {
                
                del.didEndDragging(draggable, onDropArea: true)
                
                print("Dropped on a DropArea");
            } else {
                del.didEndDragging(draggable, onDropArea: false)
                print("Dropped somehwere else");
            }
            break
            //TODO: view.didEndDragging()
        default:
            break
        }
        
    }
    
    private func dragBack(view: UIView) {
        
    }
    
    private func checkIfViewIsInDropArea(view: UIView, gesture: DropshipGestureRecognizer) -> Bool{
        
        let isInArea = catchableItems.map({ dropArea -> Bool
            in
            
            let intRect = CGRectIntersection(dropArea.frame, view.frame)
            let intRectArea = CGRectGetHeight(intRect) * CGRectGetWidth(intRect)
            let viewArea = CGRectGetHeight(view.frame) * CGRectGetWidth(view.frame)
            let overlapsMoreThanHalf = (viewArea / intRectArea) > 0.5 ? true : false

            return overlapsMoreThanHalf
            
            
        })
        return isInArea.reduce(false, combine: ({ $0 || $1}))
    }

}