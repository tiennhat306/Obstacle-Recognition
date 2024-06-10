from django.db import models

from ultralytics import YOLO
YOLOv8_model = YOLO('recognition/utils/best_200_epoch.pt', 'v8')
