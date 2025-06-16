#!/bin/bash

# Test script for H3z REST API Example
# This script tests all CRUD operations of the REST API

set -e

BASE_URL="http://127.0.0.1:3000"
API_BASE="$BASE_URL/api/v1"

echo "🧪 Testing H3z REST API Example"
echo "==============================="

# Function to test API endpoint
test_api_endpoint() {
    local method=$1
    local endpoint=$2
    local expected_status=$3
    local data=$4
    local description=$5
    
    echo "Testing: $description"
    echo "  $method $endpoint"
    
    case "$method" in
        "GET")
            response=$(curl -s -w "\n%{http_code}" "$API_BASE$endpoint")
            ;;
        "POST")
            response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "$API_BASE$endpoint")
            ;;
        "PUT")
            response=$(curl -s -w "\n%{http_code}" -X PUT -H "Content-Type: application/json" -d "$data" "$API_BASE$endpoint")
            ;;
        "DELETE")
            response=$(curl -s -w "\n%{http_code}" -X DELETE "$API_BASE$endpoint")
            ;;
    esac
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$status_code" = "$expected_status" ]; then
        echo "  ✅ Status: $status_code"
    else
        echo "  ❌ Status: $status_code (Expected: $expected_status)"
        return 1
    fi
    
    echo "  📄 Response: $(echo "$body" | head -c 150)..."
    echo ""
}

# Function to check if API server is running
check_api_server() {
    echo "🔍 Checking if REST API server is running..."
    if curl -s "$BASE_URL" > /dev/null 2>&1; then
        echo "✅ Server is running at $BASE_URL"
        return 0
    else
        echo "❌ Server is not running at $BASE_URL"
        echo "💡 Please start the server with: zig build api"
        return 1
    fi
}

# Function to test Users API
test_users_api() {
    echo "👥 Testing Users API"
    echo "==================="
    
    # Get all users
    test_api_endpoint "GET" "/users" "200" "" "Get all users"
    
    # Get specific user
    test_api_endpoint "GET" "/users/1" "200" "" "Get user by ID"
    
    # Create new user
    test_api_endpoint "POST" "/users" "201" '{"name":"Test User","email":"test@example.com"}' "Create new user"
    
    # Update user
    test_api_endpoint "PUT" "/users/1" "200" '{"name":"Updated User"}' "Update user"
    
    # Test non-existent user
    test_api_endpoint "GET" "/users/999" "404" "" "Get non-existent user (should return 404)"
}

# Function to test Products API
test_products_api() {
    echo "📦 Testing Products API"
    echo "======================="
    
    # Get all products
    test_api_endpoint "GET" "/products" "200" "" "Get all products"
    
    # Get specific product
    test_api_endpoint "GET" "/products/1" "200" "" "Get product by ID"
    
    # Create new product
    test_api_endpoint "POST" "/products" "201" '{"name":"Test Product","description":"A test product","price":29.99,"stock":100,"category":"test"}' "Create new product"
    
    # Update product
    test_api_endpoint "PUT" "/products/1" "200" '{"name":"Updated Product","price":39.99}' "Update product"
    
    # Get products by category
    test_api_endpoint "GET" "/products/category/electronics" "200" "" "Get products by category"
}

# Function to test Orders API
test_orders_api() {
    echo "🛒 Testing Orders API"
    echo "===================="
    
    # Get all orders
    test_api_endpoint "GET" "/orders" "200" "" "Get all orders"
    
    # Get specific order
    test_api_endpoint "GET" "/orders/1" "200" "" "Get order by ID"
    
    # Create new order
    test_api_endpoint "POST" "/orders" "201" '{"user_id":1,"product_id":1,"quantity":2}' "Create new order"
    
    # Update order
    test_api_endpoint "PUT" "/orders/1" "200" '{"status":"completed"}' "Update order status"
    
    # Get user orders
    test_api_endpoint "GET" "/users/1/orders" "200" "" "Get orders for specific user"
}

# Function to test additional endpoints
test_additional_endpoints() {
    echo "📊 Testing Additional Endpoints"
    echo "==============================="
    
    # API info
    test_api_endpoint "GET" "" "200" "" "Get API info"
    
    # Statistics
    test_api_endpoint "GET" "/stats" "200" "" "Get API statistics"
    
    # Homepage (documentation)
    echo "Testing: API Documentation Homepage"
    echo "  GET $BASE_URL/"
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL/")
    status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "200" ]; then
        echo "  ✅ Status: $status_code"
    else
        echo "  ❌ Status: $status_code"
    fi
    echo ""
}

# Function to test error handling
test_error_handling() {
    echo "🚨 Testing Error Handling"
    echo "========================"
    
    # Test invalid JSON
    echo "Testing invalid JSON..."
    response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d 'invalid json' "$API_BASE/users")
    status_code=$(echo "$response" | tail -n1)
    echo "  Invalid JSON status: $status_code"
    
    # Test missing required fields
    echo "Testing missing required fields..."
    response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d '{}' "$API_BASE/users")
    status_code=$(echo "$response" | tail -n1)
    echo "  Empty body status: $status_code"
    
    # Test invalid ID format
    echo "Testing invalid ID format..."
    response=$(curl -s -w "\n%{http_code}" "$API_BASE/users/invalid")
    status_code=$(echo "$response" | tail -n1)
    echo "  Invalid ID status: $status_code"
    
    echo ""
}

# Function to run performance test
run_performance_test() {
    echo "⚡ Testing API Performance"
    echo "========================="
    
    echo "Running concurrent requests to /api/v1/users..."
    
    # Make 20 concurrent requests
    for i in {1..20}; do
        curl -s "$API_BASE/users" > /dev/null &
    done
    
    wait
    echo "✅ Concurrent requests completed"
    
    echo "Testing response time..."
    time curl -s "$API_BASE/stats" > /dev/null
    echo ""
}

# Function to demonstrate full CRUD workflow
demonstrate_crud_workflow() {
    echo "🔄 Demonstrating Full CRUD Workflow"
    echo "==================================="
    
    echo "1. Creating a new user..."
    create_response=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name":"CRUD Test User","email":"crud@example.com"}' "$API_BASE/users")
    echo "   Created: $(echo "$create_response" | head -c 100)..."
    
    echo "2. Reading the user..."
    read_response=$(curl -s "$API_BASE/users/1")
    echo "   Read: $(echo "$read_response" | head -c 100)..."
    
    echo "3. Updating the user..."
    update_response=$(curl -s -X PUT -H "Content-Type: application/json" -d '{"name":"Updated CRUD User"}' "$API_BASE/users/1")
    echo "   Updated: $(echo "$update_response" | head -c 100)..."
    
    echo "4. Reading updated user..."
    read_updated_response=$(curl -s "$API_BASE/users/1")
    echo "   Read Updated: $(echo "$read_updated_response" | head -c 100)..."
    
    echo "✅ CRUD workflow demonstration completed"
    echo ""
}

# Main execution
main() {
    echo "H3z REST API Test Suite"
    echo "======================"
    echo "Base URL: $BASE_URL"
    echo "API Base: $API_BASE"
    echo ""
    
    # Check if server is running
    if ! check_api_server; then
        exit 1
    fi
    
    echo ""
    
    # Test all API endpoints
    test_users_api
    echo ""
    
    test_products_api
    echo ""
    
    test_orders_api
    echo ""
    
    test_additional_endpoints
    echo ""
    
    # Test error handling
    test_error_handling
    
    # Run performance test
    run_performance_test
    
    # Demonstrate CRUD workflow
    demonstrate_crud_workflow
    
    echo "🏁 REST API test suite completed!"
    echo ""
    echo "💡 Tips:"
    echo "  - Visit $BASE_URL for interactive API documentation"
    echo "  - Check $API_BASE/stats for current API statistics"
    echo "  - Use tools like Postman or Insomnia for more advanced testing"
}

# Run main function
main "$@"
