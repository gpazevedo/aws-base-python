# API Endpoints Documentation

This document describes all available endpoints in the FastAPI Lambda application and how to access them through API Gateway.

---

## 📚 Table of Contents

- [Available Endpoints](#available-endpoints)
- [Health Check Endpoints](#health-check-endpoints)
- [Application Endpoints](#application-endpoints)
- [Auto-Generated Documentation](#auto-generated-documentation)
- [Accessing via API Gateway](#accessing-via-api-gateway)
- [Local Development](#local-development)
- [Testing Endpoints](#testing-endpoints)

---

## Available Endpoints

The FastAPI application provides the following endpoints:

### Health Check Endpoints

| Endpoint | Method | Description | Use Case |
|----------|--------|-------------|----------|
| `/health` | GET | Comprehensive health check with uptime | Monitoring, load balancer health checks |
| `/liveness` | GET | Kubernetes-style liveness probe | Container orchestration |
| `/readiness` | GET | Kubernetes-style readiness probe | Container orchestration |

### Application Endpoints

| Endpoint | Method | Description | Parameters |
|----------|--------|-------------|------------|
| `/` | GET | Root endpoint, welcome message | None |
| `/greet` | GET | Greet by name (query param) | `name` (query, optional) |
| `/greet` | POST | Greet by name (request body) | `name` (body, required) |
| `/error` | GET | Test error handling | None |

### Auto-Generated Documentation

FastAPI automatically generates interactive documentation:

| Endpoint | Description |
|----------|-------------|
| `/docs` | Swagger UI - Interactive API documentation |
| `/redoc` | ReDoc - Alternative API documentation |
| `/openapi.json` | OpenAPI schema (JSON) |

---

## Health Check Endpoints

### 1. `/health` - Comprehensive Health Check

**Purpose:** Provides detailed health information including uptime and version.

**Request:**
```bash
GET /health
```

**Response (200 OK):**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-20T12:34:56.789012+00:00",
  "uptime_seconds": 123.45,
  "version": "0.1.0"
}
```

**Response Fields:**
- `status`: Current health status (`healthy`)
- `timestamp`: ISO 8601 timestamp with timezone (UTC)
- `uptime_seconds`: Time since application started
- `version`: Application version

**Use Cases:**
- Load balancer health checks
- Monitoring and alerting systems
- Application status dashboards

---

### 2. `/liveness` - Liveness Probe

**Purpose:** Indicates if the application is running (Kubernetes-style probe).

**Request:**
```bash
GET /liveness
```

**Response (200 OK):**
```json
{
  "status": "alive"
}
```

**Use Cases:**
- Kubernetes liveness probes
- Container orchestration platforms
- Determining if a restart is needed

---

### 3. `/readiness` - Readiness Probe

**Purpose:** Indicates if the application is ready to receive traffic.

**Request:**
```bash
GET /readiness
```

**Response (200 OK):**
```json
{
  "status": "ready"
}
```

**Extensibility:**
You can extend this endpoint to check:
- Database connectivity
- External service availability
- Cache availability
- Required configuration presence

**Example Extension:**
```python
@app.get("/readiness", response_model=StatusResponse, tags=["Health"])
async def readiness_probe() -> StatusResponse:
    """Readiness probe with dependency checks."""
    # Check database
    try:
        db.ping()
    except Exception:
        raise HTTPException(status_code=503, detail="Database unavailable")

    # Check cache
    try:
        cache.ping()
    except Exception:
        raise HTTPException(status_code=503, detail="Cache unavailable")

    return StatusResponse(status="ready")
```

---

## Application Endpoints

### 1. `/` - Root Endpoint

**Purpose:** Welcome message and version information.

**Request:**
```bash
GET /
```

**Response (200 OK):**
```json
{
  "message": "Hello, World!",
  "version": "0.1.0"
}
```

---

### 2. `/greet` - Greeting (GET)

**Purpose:** Personalized greeting using query parameter.

**Request:**
```bash
GET /greet?name=Alice
```

**Parameters:**
- `name` (query, optional): Name to greet (default: "World")

**Response (200 OK):**
```json
{
  "message": "Hello, Alice!",
  "version": "0.1.0"
}
```

**Examples:**
```bash
# Default name
curl https://my-project-api.execute-api.us-east-1.amazonaws.com/greet
# Response: {"message": "Hello, World!", "version": "0.1.0"}

# Custom name
curl https://my-project-api.execute-api.us-east-1.amazonaws.com/greet?name=Alice
# Response: {"message": "Hello, Alice!", "version": "0.1.0"}
```

---

### 3. `/greet` - Greeting (POST)

**Purpose:** Personalized greeting using request body.

**Request:**
```bash
POST /greet
Content-Type: application/json

{
  "name": "Bob"
}
```

**Request Body:**
- `name` (string, required): Name to greet

**Response (200 OK):**
```json
{
  "message": "Hello, Bob!",
  "version": "0.1.0"
}
```

**Validation Error (422):**
```json
{
  "detail": [
    {
      "type": "missing",
      "loc": ["body", "name"],
      "msg": "Field required",
      "input": {}
    }
  ]
}
```

**Examples:**
```bash
# Valid request
curl -X POST https://my-project-api.execute-api.us-east-1.amazonaws.com/greet \
  -H "Content-Type: application/json" \
  -d '{"name": "Bob"}'

# Invalid request (missing name)
curl -X POST https://my-project-api.execute-api.us-east-1.amazonaws.com/greet \
  -H "Content-Type: application/json" \
  -d '{}'
# Response: 422 Validation Error
```

---

### 4. `/error` - Error Test Endpoint

**Purpose:** Test error handling and monitoring.

**Request:**
```bash
GET /error
```

**Response (500 Internal Server Error):**
```json
{
  "detail": "This is a test error"
}
```

**Use Cases:**
- Testing error monitoring systems
- Validating error handling pipelines
- Testing alerting configurations

---

## Auto-Generated Documentation

FastAPI automatically generates interactive API documentation that's always up-to-date with your code.

### Swagger UI (`/docs`)

**Access:** `https://my-project-api-url/docs`

**Features:**
- Interactive API explorer
- Try endpoints directly from browser
- View request/response schemas
- See all available endpoints
- Test authentication (if configured)

**Screenshot:**
```
┌─────────────────────────────────────────────────┐
│ AWS Base Python API                      v0.1.0 │
├─────────────────────────────────────────────────┤
│                                                 │
│ Health                                          │
│   GET  /health     - Comprehensive health check │
│   GET  /liveness   - Liveness probe             │
│   GET  /readiness  - Readiness probe            │
│                                                 │
│ General                                         │
│   GET  /           - Root endpoint              │
│   GET  /greet      - Greet (query param)        │
│   POST /greet      - Greet (request body)       │
│   GET  /error      - Test error handling        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### ReDoc (`/redoc`)

**Access:** `https://my-project-api-url/redoc`

**Features:**
- Three-panel layout
- Better for documentation reading
- Cleaner interface
- Markdown support in descriptions
- Code samples in multiple languages

### OpenAPI Schema (`/openapi.json`)

**Access:** `https://my-project-api-url/openapi.json`

**Features:**
- Machine-readable API specification
- OpenAPI 3.0 standard
- Import into tools like Postman, Insomnia
- Generate client libraries
- API versioning and documentation

**Example:**
```bash
# Download OpenAPI schema
curl https://my-project-api-url/openapi.json > api-schema.json

# Use with Postman
# File → Import → api-schema.json

# Generate Python client
# openapi-generator-cli generate -i api-schema.json -g python
```

---

## Accessing via API Gateway

When deployed to AWS Lambda with API Gateway, your FastAPI application is accessible through an API Gateway endpoint.

### Getting Your API Gateway URL

#### Option 1: Lambda Function URL (Recommended for Quick Start)

Lambda Function URLs provide direct HTTP(S) access to your Lambda function without API Gateway.

**Get the URL:**
```bash
# Get function URL from Terraform output
cd terraform
terraform output lambda_function_url

# Or use AWS CLI
aws lambda get-function-url-config \
  --function-name my-project-api-dev \
  --query 'FunctionUrl' \
  --output text
```

**URL Format:**
```
https://<unique-id>.lambda-url.<region>.on.aws/
```

**Example:**
```bash
# Test your Lambda via Function URL
FUNCTION_URL=$(cd terraform && terraform output -raw lambda_function_url)

# Health check
curl $FUNCTION_URL/health

# Greet endpoint
curl "$FUNCTION_URL/greet?name=Alice"

# Interactive docs
open "$FUNCTION_URL/docs"  # macOS
xdg-open "$FUNCTION_URL/docs"  # Linux
```

#### Option 2: API Gateway (For Production)

API Gateway provides additional features like rate limiting, API keys, custom domains, etc.

**Get the URL:**
```bash
# From AWS Console
# Services → API Gateway → Your API → Stages → dev → Invoke URL

# Or use AWS CLI
aws apigateway get-rest-apis \
  --query 'items[?name==`my-project-api`].id' \
  --output text

# Then get stage URL
API_ID=<API_ID>
aws apigateway get-stage \
  --rest-api-id $API_ID \
  --stage-name dev \
  --query 'invoke_url' \
  --output text
```

**URL Format:**
```
https://<api-id>.execute-api.<region>.amazonaws.com/<stage>/
```

**Example:**
```bash
API_URL="https://abc123.execute-api.us-east-1.amazonaws.com/dev"

# Health check
curl $API_URL/health

# Greet with query parameter
curl "$API_URL/greet?name=Bob"

# Greet with POST
curl -X POST $API_URL/greet \
  -H "Content-Type: application/json" \
  -d '{"name": "Charlie"}'

# View interactive docs
open "$API_URL/docs"
```

### Setting Up API Gateway (Optional)

If you want full API Gateway features, add this to your Terraform:

**`terraform/resources/api-gateway.tf`:**
```hcl
resource "aws_apigatewayv2_api" "lambda" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = var.environment
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.api.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.lambda.invoke_url
}
```

---

## Local Development

### Running Locally

**Option 1: Using uvicorn directly**
```bash
cd backend/api

# Install dependencies
uv sync

# Run development server
uv run python main.py

# Server starts at http://localhost:8000
```

**Option 2: Using uvicorn command**
```bash
cd backend/api
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Access endpoints:**
- API: http://localhost:8000
- Health: http://localhost:8000/health
- Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Testing with Docker (Lambda Runtime)

**Build and run:**
```bash
# Build for local testing (amd64)
make docker-build-amd64 SERVICE=api

# Run locally
docker run -p 9000:8080 my-project:amd64-latest

# Test in another terminal
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -H "Content-Type: application/json" \
  -d '{
    "requestContext": {"http": {"method": "GET", "path": "/health"}},
    "rawPath": "/health",
    "headers": {}
  }'
```

---

## Testing Endpoints

### Using curl

```bash
# Health check
curl https://my-project-api-url/health | jq

# Liveness
curl https://my-project-api-url/liveness | jq

# Root endpoint
curl https://my-project-api-url/ | jq

# Greet with query
curl "https://my-project-api-url/greet?name=Alice" | jq

# Greet with POST
curl -X POST https://my-project-api-url/greet \
  -H "Content-Type: application/json" \
  -d '{"name": "Bob"}' | jq

# Test error handling
curl https://my-project-api-url/error | jq
```

### Using httpie

```bash
# Install httpie
pip install httpie

# Health check
http https://my-project-api-url/health

# Greet with POST
http POST https://my-project-api-url/greet name=Alice

# Interactive docs
http https://my-project-api-url/docs
```

### Using Python

```python
import requests

BASE_URL = "https://my-project-api-url"

# Health check
response = requests.get(f"{BASE_URL}/health")
print(response.json())

# Greet
response = requests.get(f"{BASE_URL}/greet", params={"name": "Alice"})
print(response.json())

# Greet POST
response = requests.post(f"{BASE_URL}/greet", json={"name": "Bob"})
print(response.json())
```

### Automated Testing

Run the test suite:
```bash
cd backend/api

# Install test dependencies
uv sync
uv pip install pytest pytest-cov

# Run tests
uv run pytest -v

# Run with coverage
uv run pytest --cov=. --cov-report=html
```

---

## Next Steps

1. **Add Authentication**: Implement API keys, JWT, or OAuth
2. **Add Database**: Connect to RDS, DynamoDB, or other databases
3. **Add Caching**: Implement Redis or ElastiCache
4. **Add Monitoring**: CloudWatch, X-Ray, or third-party APM
5. **Add Rate Limiting**: Protect your API from abuse
6. **Custom Domain**: Use Route53 and ACM for custom domains
7. **CORS Configuration**: Configure for your frontend domain

---

## Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Mangum Documentation](https://mangum.io/)
- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [OpenAPI Specification](https://swagger.io/specification/)
