#!/bin/bash

# DevOps Microservice - Endpoint Testing Script
# Author: Edison Chinlle
# Description: Test all endpoints of the microservice

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

API_URL="${API_URL:-http://localhost:8000}"
API_KEY="2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN} $1${NC}"
}

print_error() {
    echo -e "${RED} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW} $1${NC}"
}

if ! command -v jq &> /dev/null; then
    print_error "jq is not installed. Please install it first:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  macOS: brew install jq"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    print_error "curl is not installed. Please install it first."
    exit 1
fi

print_header "DevOps Microservice - Endpoint Testing"
echo "API URL: $API_URL"
echo "API Key: $API_KEY"

print_header "Test 1: Health Check (GET /)"
RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    print_success "Health check passed"
    echo "$BODY" | jq '.'
else
    print_error "Health check failed (HTTP $HTTP_CODE)"
    echo "$BODY"
    exit 1
fi

print_header "Test 2: Generate JWT (GET /generate-jwt)"
RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/generate-jwt")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    print_success "JWT generation successful"
    JWT=$(echo "$BODY" | jq -r '.jwt')
    echo "$BODY" | jq '.'
    echo -e "\nExtracted JWT: ${YELLOW}${JWT:0:50}...${NC}"
else
    print_error "JWT generation failed (HTTP $HTTP_CODE)"
    echo "$BODY"
    exit 1
fi

print_header "Test 3: POST /DevOps - Missing API Key (Expected: 400)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$API_URL/DevOps" \
    -H "Content-Type: application/json" \
    -H "X-JWT-KWY: $JWT" \
    -d '{
        "message": "Test message",
        "to": "Juan Perez",
        "from": "Rita Asturia",
        "timeToLifeSec": 45
    }')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 400 ]; then
    print_success "Correctly rejected request without API Key"
    echo "$BODY" | jq '.'
else
    print_warning "Unexpected response (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

print_header "Test 4: POST /DevOps - Invalid API Key (Expected: 401)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$API_URL/DevOps" \
    -H "Content-Type: application/json" \
    -H "X-Parse-REST-API-Key: invalid-key" \
    -H "X-JWT-KWY: $JWT" \
    -d '{
        "message": "Test message",
        "to": "Juan Perez",
        "from": "Rita Asturia",
        "timeToLifeSec": 45
    }')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 401 ]; then
    print_success "Correctly rejected request with invalid API Key"
    echo "$BODY" | jq '.'
else
    print_warning "Unexpected response (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

print_header "Test 5: POST /DevOps - Missing JWT (Expected: 400)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$API_URL/DevOps" \
    -H "Content-Type: application/json" \
    -H "X-Parse-REST-API-Key: $API_KEY" \
    -d '{
        "message": "Test message",
        "to": "Juan Perez",
        "from": "Rita Asturia",
        "timeToLifeSec": 45
    }')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 400 ]; then
    print_success "Correctly rejected request without JWT"
    echo "$BODY" | jq '.'
else
    print_warning "Unexpected response (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

print_header "Test 6: POST /DevOps - Invalid JWT (Expected: 401)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$API_URL/DevOps" \
    -H "Content-Type: application/json" \
    -H "X-Parse-REST-API-Key: $API_KEY" \
    -H "X-JWT-KWY: invalid.jwt.token" \
    -d '{
        "message": "Test message",
        "to": "Juan Perez",
        "from": "Rita Asturia",
        "timeToLifeSec": 45
    }')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 401 ]; then
    print_success "Correctly rejected request with invalid JWT"
    echo "$BODY" | jq '.'
else
    print_warning "Unexpected response (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

print_header "Test 7: POST /DevOps - Invalid Payload (Expected: 422)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$API_URL/DevOps" \
    -H "Content-Type: application/json" \
    -H "X-Parse-REST-API-Key: $API_KEY" \
    -H "X-JWT-KWY: $JWT" \
    -d '{
        "message": "Test",
        "to": "Juan"
    }')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 422 ]; then
    print_success "Correctly rejected invalid payload"
    echo "$BODY" | jq '.'
else
    print_warning "Unexpected response (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

print_header "Test 8: POST /DevOps - Valid Request (Expected: 200)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$API_URL/DevOps" \
    -H "Content-Type: application/json" \
    -H "X-Parse-REST-API-Key: $API_KEY" \
    -H "X-JWT-KWY: $JWT" \
    -d '{
        "message": "This is a test message from script",
        "to": "Juan Perez",
        "from": "Rita Asturia",
        "timeToLifeSec": 45
    }')
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    print_success "Request successful!"
    echo "$BODY" | jq '.'
else
    print_error "Request failed (HTTP $HTTP_CODE)"
    echo "$BODY"
    exit 1
fi

print_header "Test 9: GET /DevOps - Wrong Method (Expected: 405)"
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X GET "$API_URL/DevOps" \
    -H "X-Parse-REST-API-Key: $API_KEY" \
    -H "X-JWT-KWY: $JWT")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 405 ]; then
    print_success "Correctly returned ERROR for non-POST method"
    echo "$BODY"
else
    print_warning "Unexpected response (HTTP $HTTP_CODE)"
    echo "$BODY"
fi

print_header "Test 10: OpenAPI Docs (GET /docs)"
RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL/docs")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 200 ]; then
    print_success "OpenAPI documentation is accessible"
else
    print_error "OpenAPI documentation failed (HTTP $HTTP_CODE)"
fi