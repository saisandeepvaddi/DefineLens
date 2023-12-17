import SwiftUI

struct SelectableText {
    var original: CustomRecognizedText
    var isSelected: Bool = false
}

class TextSelectionManager: ObservableObject {
    @Published var selectedText: String = ""

    func clearSelection() {
        selectedText = ""
    }
}

struct BoundingBoxes: View {
    @Binding var selectableTexts: [SelectableText]
    @ObservedObject var selectionManager: TextSelectionManager
    var zoomScale: CGFloat
    var offset: CGSize
    var body: some View {
        ZStack {
            ForEach(selectableTexts.indices, id: \.self) { index in
                let box = selectableTexts[index].original.boundingBox
                Path { path in
                    path.addRect(box)
                }
                .stroke(selectableTexts[index].isSelected ? Color.blue : Color.red, lineWidth: 2)
                .scaleEffect(CGSize(width: 1.0 * zoomScale, height: 1.0 * zoomScale))
                .offset(offset)
                .onTapGesture {
                    print("Tapping: \(selectableTexts[index].original.text)")
                    selectableTexts[index].isSelected.toggle()
                    updateFinalSelection()
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    updateSelection(from: value.startLocation, to: value.location)
                }
                .onEnded { _ in
                    finalizeSelection()
                }
        )
    }

    private func updateSelection(from start: CGPoint, to end: CGPoint) {
        let selectionRect = CGRect(
            x: min(start.x, end.x), y: min(start.y, end.y), width: abs(end.x - start.x),
            height: abs(end.y - start.y)
        )
        let isDraggingRight = end.x >= start.x

        for index in selectableTexts.indices {
            let intersects = selectionRect.intersects(selectableTexts[index].original.boundingBox)
            if isDraggingRight && intersects {
                selectableTexts[index].isSelected = true
            } else if !isDraggingRight && intersects {
                selectableTexts[index].isSelected = false
            }
        }
    }

    private func finalizeSelection() {
        let selectedTexts = selectableTexts.filter { $0.isSelected }.map { $0.original.text }
        selectionManager.selectedText = selectedTexts.joined(separator: " ")
        //        clearSelection()
    }

    private func clearSelection() {
        for index in selectableTexts.indices {
            selectableTexts[index].isSelected = false
        }
    }

    private func updateFinalSelection() {
        let selectedTexts = selectableTexts.filter { $0.isSelected }.map { $0.original.text }
        selectionManager.selectedText = selectedTexts.joined(separator: " ")
    }
}
