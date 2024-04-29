# from ultralytics import YOLO
# import cv2
# import math

# # Load the YOLO model
# model = YOLO(r"C:\Users\ngmv1\OneDrive\Máy tính\PBL5\yolov8-silva\weights\best (5).pt", "v8")

# # Path to the image you want to predict
# image_path = r"C:\Users\ngmv1\OneDrive\Máy tính\PBL5\Picture\5.png"

# # Read the image
# image = cv2.imread(image_path)

# # Predict on the image
# result = model(image)
# classnames = ['bottle', 'car', 'smartphone']

# # Process the result
# for info in result:
#     boxes = info.boxes
#     for box in boxes:
#         confidence = box.conf[0]
#         confidence = math.ceil(confidence * 100)
#         Class = int(box.cls[0])
#         if confidence > 50:
#             x1, y1, x2, y2 = box.xyxy[0].int().tolist()
#             cv2.rectangle(image, (x1, y1), (x2, y2), (0, 0, 255), 5)
#             cv2.putText(image, f'{classnames[Class]} {confidence}%', (x1 + 8, y1 + 100),
#                         cv2.FONT_HERSHEY_SIMPLEX, 1.5, (255, 255, 255), 2, cv2.LINE_AA)

# # Display the image
# cv2.imshow('Object Detection', image)
# cv2.waitKey(0)
# cv2.destroyAllWindows()
########################################################################

from ultralytics import YOLO
import cv2
import math

# Load the YOLO model
model = YOLO(r"C:\Users\ngmv1\OneDrive\Máy tính\PBL5\Obstacle-Recognition\recognition\utils\best (10).pt", "v8")

# Path to the image you want to predict
image_path = r"C:\Users\ngmv1\OneDrive\Máy tính\PBL5\Obstacle-Recognition\a.png"
# Read the image
image = cv2.imread(image_path)

# Predict on the image
result = model(image)

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
        if confidence > 50:
            x1, y1, x2, y2 = box.xyxy[0].int().tolist()
            cv2.rectangle(image, (x1, y1), (x2, y2), (0, 0, 255), 5)
            cv2.putText(image, f'{class_name} {confidence}%', (x1 + 8, y1 + 100),
                        cv2.FONT_HERSHEY_SIMPLEX, 1.5, (255, 255, 255), 2, cv2.LINE_AA)
            # Resize the image
max_width = 800  # Maximum width of the window
max_height = 600  # Maximum height of the window
height, width = image.shape[:2]
scaling_factor = min(max_width/width, max_height/height)
image = cv2.resize(image, None, fx=scaling_factor, fy=scaling_factor, interpolation=cv2.INTER_AREA)
# Display the image
cv2.imshow('Object Detection', image)
cv2.waitKey(0)
cv2.destroyAllWindows()

