from django.db import models

from ultralytics import YOLO
YOLOv8_model = YOLO('recognition/utils/YOLOv8_best.pt', 'v8')
