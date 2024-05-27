import React, { CSSProperties, useState, PointerEvent } from "react";
import { DndContext, closestCenter, KeyboardSensor, PointerSensor, useSensor, useSensors, DragOverlay } from "@dnd-kit/core";
import { SortableContext, sortableKeyboardCoordinates, verticalListSortingStrategy, useSortable } from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";

const isInteractiveElement = (element: any) => {
  const interactiveElements = [
    "a",
    "button",
    "input",
    "textarea",
    "select",
    "option"
  ];
  if (interactiveElements.includes(element.tagName.toLowerCase())) {
    return true;
  }
  return false;
};

// This is a custom sensor that prevents dragging if the pointer is over an interactive element like a button or input.
// This way, we don't need to provide custom drag handles. Usually, we can just wrap the whole item in a draggable element.
class PointerSensorWithoutInteractiveElements extends PointerSensor {
  static activators = [
    {
      eventName: "onPointerDown" as const,
      handler: ({ nativeEvent: event }: PointerEvent) => {
        if (!event.isPrimary || event.button !== 0 || isInteractiveElement(event.target)) {
          return false;
        }
        return true;
      }
    }
  ];
}

// - `items` is an array of unique keys for each item in the list.
// - `onReorder` is a function that will be called with the `oldIndex` and `newIndex` of the item that was moved.
// - `renderDragPreview` is a function that will be called with the `dragPreviewId` of the item being dragged. Note that
//   the drag preview cannot use the `useSortable` hook - it needs to be just a view component without dragging functionality.
export const SortableContainer = ({
  items,
  onReorder,
  renderDragPreview,
  children
}: any) => {
  const [dragPreviewId, setDragPreviewId] = useState(null);

  const handleDragStart = (event: any) => {
    const { active } = event;
    setDragPreviewId(active.id);
  };

  const handleDragEnd = (event: any) => {
    const { active, over } = event;
    if (active.id !== over.id) {
      const oldIndex = items.indexOf(active.id);
      const newIndex = items.indexOf(over.id);
      onReorder({ oldIndex, newIndex });
    }

    setDragPreviewId(null);
  };

  const sensors = useSensors(
    useSensor(PointerSensorWithoutInteractiveElements),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates
    })
  );

  const renderDragPreviewWithBg = (_dragPreviewId: any) => {
    return (
      <div style={{ boxShadow: "0 0 10px rgba(0, 0, 0, 0.35)", backgroundColor: "white" }}>
        { renderDragPreview(_dragPreviewId) }
      </div>
    );
  };

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
        { dragPreviewId ? renderDragPreviewWithBg(dragPreviewId) : null }
      </DragOverlay>
    </DndContext>
  );
};

export const SortableItem = ({
  id,
  disabled,
  className,
  children
}: any) => {
  const { attributes, listeners, setNodeRef, transform, transition, active } = useSortable({ id, disabled });

  const style: CSSProperties = {
    transform: CSS.Translate.toString(transform),
    transition,
    // hide the original item while dragging, as we use a custom drag preview
    visibility: active?.id === id ? "hidden" : "visible",
    // important, otherwise dragging won't work on mobile (bubbling event causes scrolling)
    touchAction: "none"
  };

  return (
    <div ref={setNodeRef} className={className} style={style} {...attributes} {...listeners}>
      { children }
    </div>
  );
};
