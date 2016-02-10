//
//  DropshipManager.swift
//
//  Created by Nahuel Marisi on 2015-12-03.

protocol Droppable: NSObjectProtocol {
    
}

protocol Draggable : NSObjectProtocol {
}

class TestView: UIView, Draggable {
    
}

class DropshipManager {
    
    typealias DragView = protocol<UIDynamicItem, Draggable>
    typealias DropView = protocol<UIDynamicItem, Droppable>
   
    var draggableItems = [DragView]()
    var droppableItems = [DropView]()
   
    func registerDraggableItem<T: UIView where T: Draggable>(item: T) {
        draggableItems.append(item)
    }
    
    func deregisterDraggableItem<T: UIView where T: Draggable>(item: T) {
        
        for (index, draggableItem) in draggableItems.enumerate() {
            if draggableItem.isEqual(item) {
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
}