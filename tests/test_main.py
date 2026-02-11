"""
Unit tests for DevOps Microservice
Testing all endpoints, authentication, and error handling
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app, generate_jwt, verify_jwt, API_KEY

client = TestClient(app)

@pytest.fixture
def valid_jwt():
    """Generate a valid JWT for testing"""
    return generate_jwt()

@pytest.fixture
def valid_headers(valid_jwt):
    """Generate valid headers with API Key and JWT"""
    return {
        "X-Parse-REST-API-Key": API_KEY,
        "X-JWT-KWY": valid_jwt,
        "Content-Type": "application/json"
    }

@pytest.fixture
def valid_payload():
    """Generate valid request payload"""
    return {
        "message": "This is a test",
        "to": "Helen Livano",
        "from": "Jenifer Tarco",
        "timeToLifeSec": 45
    }

def test_root_endpoint():
    """Test health check endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "service" in data

def test_generate_jwt_endpoint():
    """Test JWT generation endpoint"""
    response = client.get("/generate-jwt")
    assert response.status_code == 200
    data = response.json()
    assert "jwt" in data
    assert "api_key" in data
    assert data["api_key"] == API_KEY

def test_jwt_generation():
    """Test JWT generation function"""
    token = generate_jwt()
    assert token is not None
    assert isinstance(token, str)
    assert len(token) > 0

def test_jwt_verification_valid():
    """Test JWT verification with valid token"""
    token = generate_jwt()
    assert verify_jwt(token) is True

def test_jwt_verification_invalid():
    """Test JWT verification with invalid token"""
    invalid_token = "invalid.jwt.token"
    assert verify_jwt(invalid_token) is False

def test_devops_post_success(valid_headers, valid_payload):
    """Test successful POST request to /DevOps"""
    response = client.post("/DevOps", json=valid_payload, headers=valid_headers)
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "Helen Livano" in data["message"]
    assert data["message"] == "Hello Helen Livano your message will be send"

def test_devops_post_missing_api_key(valid_jwt, valid_payload):
    """Test POST request without API Key"""
    headers = {
        "X-JWT-KWY": valid_jwt,
        "Content-Type": "application/json"
    }
    response = client.post("/DevOps", json=valid_payload, headers=headers)
    assert response.status_code == 401

def test_devops_post_invalid_api_key(valid_jwt, valid_payload):
    """Test POST request with invalid API Key"""
    headers = {
        "X-Parse-REST-API-Key": "invalid-api-key",
        "X-JWT-KWY": valid_jwt,
        "Content-Type": "application/json"
    }
    response = client.post("/DevOps", json=valid_payload, headers=headers)
    assert response.status_code == 401

def test_devops_post_missing_jwt(valid_payload):
    """Test POST request without JWT"""
    headers = {
        "X-Parse-REST-API-Key": API_KEY,
        "Content-Type": "application/json"
    }
    response = client.post("/DevOps", json=valid_payload, headers=headers)
    assert response.status_code == 401

def test_devops_post_invalid_jwt(valid_payload):
    """Test POST request with invalid JWT"""
    headers = {
        "X-Parse-REST-API-Key": API_KEY,
        "X-JWT-KWY": "invalid.jwt.token",
        "Content-Type": "application/json"
    }
    response = client.post("/DevOps", json=valid_payload, headers=headers)
    assert response.status_code == 401

def test_devops_post_invalid_payload(valid_headers):
    """Test POST request with invalid payload"""
    invalid_payload = {
        "message": "Test"
    }
    response = client.post("/DevOps", json=invalid_payload, headers=valid_headers)
    assert response.status_code == 422 

def test_devops_get_returns_error():
    """Test GET request to /DevOps returns ERROR"""
    response = client.get("/DevOps")
    assert response.status_code == 200
    assert response.text == '"ERROR"'

def test_devops_put_returns_error():
    """Test PUT request to /DevOps returns ERROR"""
    response = client.put("/DevOps")
    assert response.status_code == 200
    assert response.text == '"ERROR"'

def test_devops_delete_returns_error():
    """Test DELETE request to /DevOps returns ERROR"""
    response = client.delete("/DevOps")
    assert response.status_code == 200
    assert response.text == '"ERROR"'

def test_devops_patch_returns_error():
    """Test PATCH request to /DevOps returns ERROR"""
    response = client.patch("/DevOps")
    assert response.status_code == 200
    assert response.text == '"ERROR"'

def test_devops_different_recipients(valid_headers):
    """Test with different recipient names"""
    payloads = [
        {"message": "Test 1", "to": "Jenifer Tarco", "from": "Scarleth Suatunce", "timeToLifeSec": 30},
        {"message": "Test 2", "to": "Helen Livano", "from": "Ana Martinez", "timeToLifeSec": 60},
    ]
    
    for payload in payloads:
        response = client.post("/DevOps", json=payload, headers=valid_headers)
        assert response.status_code == 200
        data = response.json()
        assert payload["to"] in data["message"]

def test_devops_time_to_live_edge_cases(valid_headers):
    """Test with different timeToLifeSec values"""
    test_values = [1, 100, 3600, 86400]
    
    for ttl in test_values:
        payload = {
            "message": "Test",
            "to": "Test User",
            "from": "Test Sender",
            "timeToLifeSec": ttl
        }
        response = client.post("/DevOps", json=payload, headers=valid_headers)
        assert response.status_code == 200

def test_devops_response_format(valid_headers, valid_payload):
    """Test that response matches the expected format"""
    response = client.post("/DevOps", json=valid_payload, headers=valid_headers)
    assert response.status_code == 200
    data = response.json()
    
    assert isinstance(data, dict)
    assert "message" in data
    assert len(data.keys()) == 1 
    
    expected_message = f"Hello {valid_payload['to']} your message will be send"
    assert data["message"] == expected_message