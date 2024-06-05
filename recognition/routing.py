from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    re_path(r'ws/esp32cam/$', consumers.ESP32CamConsumer.as_asgi()),
]