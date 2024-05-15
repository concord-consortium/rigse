import React, { useState } from 'react'
import { DndContext, closestCenter, KeyboardSensor, PointerSensor, useSensor, useSensors, DragOverlay } from '@dnd-kit/core'
import { SortableContext, sortableKeyboardCoordinates, verticalListSortingStrategy, useSortable } from '@dnd-kit/sortable'
import { CSS } from '@dnd-kit/utilities'

const isInteractiveElement = (element) => {
  const interactiveElements = [
    'button',
    'input',
    'textarea',
    'select',
    'option'
  ]
  if (interactiveElements.includes(element.tagName.toLowerCase())) {
    return true
  }
  return false
}

// This is a custom sensor that prevents dragging if the pointer is over an interactive element like a button or input.
// This way, we don't need to provide custom drag handles. Usually, we can just wrap the whole item in a draggable element.
class PointerSensorWithoutInteractiveElements extends PointerSensor {
  static activators = [
    {
      eventName: 'onPointerDown',
      handler: ({ nativeEvent: event }) => {
        if (!event.isPrimary || event.button !== 0 || isInteractiveElement(event.target)) {
          return false
        }
        return true
      }
    }
  ]
}

// - `items` is an array of unique keys for each item in the list.
// - `onReorder` is a function that will be called with the `oldIndex` and `newIndex` of the item that was moved.
// - `renderDragPreview` is a function that will be called with the `dragPreviewId` of the item being dragged. Note that
//   the drag preview cannot use the `useSortable` hook - it needs to be just a view component without dragging functionality.
export const SortableContainer = ({ items, onReorder, renderDragPreview, children }) => {
  const [dragPreviewId, setDragPreviewId] = useState(null)

  const handleDragStart = (event) => {
    const { active } = event
    setDragPreviewId(active.id)
  }

  const handleDragEnd = (event) => {
    const { active, over } = event
    if (active.id !== over.id) {
      const oldIndex = items.indexOf(active.id)
      const newIndex = items.indexOf(over.id)
      onReorder({ oldIndex, newIndex })
    }

    setDragPreviewId(null)
  }

  const sensors = useSensors(
    useSensor(PointerSensorWithoutInteractiveElements),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates
    })
  )

  const renderDragPreviewWithBg = (dragPreviewId) => {
    return (
      <div style={{ boxShadow: '0 0 10px rgba(0, 0, 0, 0.35)', backgroundColor: 'white' }}>
        { renderDragPreview(dragPreviewId) }
      </div>
    )
  }

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
    >
      <SortableContext
        items={items}
        strategy={verticalListSortingStrategy}
      >
        { children }
      </SortableContext>
      <DragOverlay>
        {dragPreviewId ? renderDragPreviewWithBg(dragPreviewId) : null}
      </DragOverlay>
    </DndContext>
  )
}

export const SortableItem = ({ id, disabled, className, children }) => {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({ id, disabled })

  const style = {
    transform: CSS.Translate.toString(transform),
    transition,
    touchAction: 'none' // important, otherwise dragging won't work on mobile (bubbling event causes scrolling)
  }

  return (
    <div ref={setNodeRef} className={className} style={style} {...attributes} {...listeners}>
      { children }
    </div>
  )
}