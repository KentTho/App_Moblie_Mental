# src/services/firebase.py

import os
import json
import requests
import firebase_admin
from firebase_admin import credentials, auth
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

# === CẤU HÌNH & KHỞI TẠO FIREBASE ADMIN ===

SERVICE_ACCOUNT_PATH = os.getenv(
    "FCM_SERVICE_ACCOUNT_FILE",
    "src/config/mental-health-app-65976-firebase-adminsdk-fbsvc-ace80167bf.json"
)

# Khởi tạo Firebase Admin SDK nếu chưa có
if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

# === XÁC THỰC TOKEN TỪ CLIENT (FE) ===

security = HTTPBearer()


def verify_firebase_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token  # Có thể chứa: uid, email, name, ...
    except auth.ExpiredIdTokenError:
        raise HTTPException(status_code=401, detail="Firebase token has expired")
    except auth.RevokedIdTokenError:
        raise HTTPException(status_code=401, detail="Firebase token has been revoked")
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid Firebase token: {e}")


# === GỬI THÔNG BÁO QUA FCM V1 ===

# Tạo credentials để lấy access token
google_credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_PATH,
    scopes=["https://www.googleapis.com/auth/firebase.messaging"]
)


def get_access_token():
    """Lấy access token từ service account."""
    google_credentials.refresh(Request())
    return google_credentials.token


def send_fcm_notification_v1(fcm_token: str, title: str, body: str):
    """Gửi push notification bằng FCM v1."""
    access_token = get_access_token()

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json; UTF-8"
    }

    message = {
        "message": {
            "token": fcm_token,
            "notification": {
                "title": title,
                "body": body
            }
        }
    }

    fcm_url = "https://fcm.googleapis.com/v1/projects/mental-health-app-65976/messages:send"

    response = requests.post(fcm_url, headers=headers, json=message)

    if response.status_code == 200:
        print("✅ FCM notification sent successfully")
    else:
        print(f"❌ Failed to send FCM notification: {response.status_code} - {response.text}")
