//
//  DropshipManager.swift
//
//  Created by Nahuel Marisi on 2015-12-03.


typealias DragDropView = protocol<UIDynamicItem, NSObjectProtocol>

protocol Droppable: DragDropView {
    
}

protocol Draggable : DragDropView {
    
    func didBeginDragging()
    func didEndDragging()
}

class TestView: UIView, Draggable {
    func didBeginDragging() {
    }
    func didEndDragging() {
        
    }
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

class DropshipManager: NSObject {
    
    var draggableItems = [UIView]()
    var droppableItems = [Droppable]()
    
    // TODO: hack for testing
    var lastLocation: CGPoint = CGPointZero
   
    // A view that is shared by both the draggable and droppable items.
    // The dragging will occur inside this view.
    // Usually the UIViewController's view.
    var mainView: UIView
    
    init(mainView: UIView) {
        self.mainView = mainView
    }
   
    //func registerDraggableItem<T: UIView where T: Draggable>(item: T) {
    func registerDraggableItem(item: UIView) {
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
    
    func registerDroppableItem<T: UIView where T: Droppable>(item: T) {
        droppableItems.append(item)
    }
    
    func deregisterDroppableItem<T: UIView where T: Droppable>(item: T) {
        
        for (index, droppableItem) in droppableItems.enumerate() {
            if droppableItem.isEqual(item) {
                droppableItems.removeAtIndex(index)
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
            (view as? Draggable)?.didBeginDragging()
            
            view.superview?.bringSubviewToFront(view)
            lastLocation = view.center
            
        case .Changed:
            let translation = sender.translationInView(view.superview!)
            let lastLocation = view.center
            view.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
            sender.setTranslation(CGPointZero, inView: view.superview!)
    
    
    
        case .Cancelled:
            fallthrough
        
        case .Ended:
            break
            //TODO: view.didEndDragging()
        default:
            break
        }
        
    }

}