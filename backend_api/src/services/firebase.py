import firebase_admin
from firebase_admin import credentials, auth
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

cred = credentials.Certificate("src/config/mental-health-app-65976-firebase-adminsdk-fbsvc-ace80167bf.json")

# ✅ Khởi tạo chỉ nếu chưa khởi tạo
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

security = HTTPBearer()

async def verify_firebase_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token  # Contains uid, email, etc.
    except auth.ExpiredIdTokenError:
        raise HTTPException(status_code=401, detail="Firebase token has expired")
    except auth.RevokedIdTokenError:
        raise HTTPException(status_code=401, detail="Firebase token has been revoked")
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid Firebase token: {e}")
