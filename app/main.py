"""
DevOps Microservice
Author: Edison Chinlle
Description: REST API with JWT authentication for Banco Pichincha assessment
"""
from fastapi import FastAPI, Header, HTTPException
from pydantic import BaseModel, Field
from typing import Optional
import jwt
import uuid
from datetime import datetime, timedelta
import os

app = FastAPI(
    title="DevOps Microservice",
    description="Banco Pichincha Technical Assessment",
    version="1.0.0"
)

API_KEY = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
JWT_SECRET = os.getenv("JWT_SECRET", "secret-key-change-in-production")
JWT_ALGORITHM = "HS256"

class DevOpsRequest(BaseModel):
    message: str = Field(..., description="Message content")
    to: str = Field(..., description="Recipient name")
    from_: str = Field(..., alias="from", description="Sender name")
    timeToLifeSec: int = Field(..., description="Time to live in seconds")

class DevOpsResponse(BaseModel):
    message: str

def generate_jwt() -> str:
    """Generate a unique JWT token for each transaction"""
    payload = {
        "transaction_id": str(uuid.uuid4()),
        "timestamp": datetime.utcnow().isoformat(),
        "exp": datetime.utcnow() + timedelta(hours=1)
    }
    token = jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)
    return token

def verify_jwt(token: str) -> bool:
    """Verify JWT token"""
    try:
        jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return True
    except jwt.InvalidTokenError:
        return False

def validate_api_key(x_parse_rest_api_key: Optional[str] = Header(None)) -> bool:
    """Validate API Key from headers"""
    if x_parse_rest_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")
    return True

def validate_jwt_header(x_jwt_kwy: Optional[str] = Header(None)) -> bool:
    """Validate JWT from headers"""
    if not x_jwt_kwy:
        raise HTTPException(status_code=401, detail="JWT token required")
    if not verify_jwt(x_jwt_kwy):
        raise HTTPException(status_code=401, detail="Invalid JWT token")
    return True

@app.get("/")
async def root():
    """Health check"""
    return {
        "status": "healthy",
        "service": "Edison Microservice",
        "version": "1.0.0"
    }

@app.post("/DevOps", response_model=DevOpsResponse)
async def devops_endpoint(
    request: DevOpsRequest,
    x_parse_rest_api_key: Optional[str] = Header(None),
    x_jwt_kwy: Optional[str] = Header(None)
):
    """
    Main DevOps endpoint - Accepts POST requests only
    Requires API Key and JWT authentication
    """
    validate_api_key(x_parse_rest_api_key)
    validate_jwt_header(x_jwt_kwy)
    
    response_message = f"Hello {request.to} your message will be send"
    return DevOpsResponse(message=response_message)

@app.get("/DevOps")
@app.put("/DevOps")
@app.delete("/DevOps")
@app.patch("/DevOps")
async def devops_other_methods():
    """Return ERROR for non-POST methods"""
    return "ERROR"

@app.get("/generate-jwt")
async def get_jwt():
    """Generate a new JWT token for testing"""
    token = generate_jwt()
    return {
        "jwt": token,
        "api_key": API_KEY,
        "note": "Use these credentials to test the /DevOps endpoint"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)