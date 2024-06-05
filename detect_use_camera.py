
from ultralytics import YOLO
import cv2
import math

# Load the YOLO model
model = YOLO(r"recognition/utils/YOLOv8_best.pt", "v8")

# Open webcam
cap = cv2.VideoCapture(0)

# Check if the webcam is opened successfully
if not cap.isOpened():
    print("Cannot open webcam")
    exit()

window_closed = False
# Loop through frames from the webcam
while not window_closed:
    # Read a frame from the webcam
    ret, frame = cap.read()

    # Check if reading the frame is successful
    if not ret:
        print("Cannot read frame (end of stream?)")
        break

    # Predict on the frame
    result = model(frame)

    # Get class names from the model
    class_names = model.names

    # Process the result
    for info in result:
        boxes = info.boxes
        for box in boxes:
            confidence = box.conf[0]
            confidence = math.ceil(confidence * 100)
            class_idx = int(box.cls[0])
            class_name = class_names[class_idx]
            if confidence > 30:
                x1, y1, x2, y2 = box.xyxy[0].int().tolist()
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 0, 255), 5)
                cv2.putText(frame, f'{class_name} {confidence}%', (x1 + 8, y1 + 100),
                            cv2.FONT_HERSHEY_SIMPLEX, 1.5, (255, 255, 255), 2, cv2.LINE_AA)

    # Display the frame
    cv2.imshow('Object Detection', frame)

    # Exit the loop when 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

    if cv2.getWindowProperty('Object Detection', cv2.WND_PROP_VISIBLE) < 1:
        window_closed = True

# Release resources and close the webcam
cap.release()
cv2.destroyAllWindows()
