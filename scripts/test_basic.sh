#!/bin/bash

# Test script for H3z Basic Server Example
# This script tests all endpoints of the basic server

set -e

BASE_URL="http://127.0.0.1:3000"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🧪 Testing H3z Basic Server Example"
echo "=================================="

# Function to test HTTP endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local expected_status=$3
    local data=$4
    local description=$5
    
    echo "Testing: $description"
    echo "  $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$BASE_URL$endpoint")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
    fi
    
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$status_code" = "$expected_status" ]; then
        echo "  ✅ Status: $status_code (Expected: $expected_status)"
    else
        echo "  ❌ Status: $status_code (Expected: $expected_status)"
        return 1
    fi
    
    echo "  📄 Response preview: $(echo "$body" | head -c 100)..."
    echo ""
}

# Function to check if server is running
check_server() {
    echo "🔍 Checking if server is running..."
    if curl -s "$BASE_URL" > /dev/null 2>&1; then
        echo "✅ Server is running at $BASE_URL"
        return 0
    else
        echo "❌ Server is not running at $BASE_URL"
        echo "💡 Please start the server with: zig build basic"
        return 1
    fi
}

# Function to run all tests
run_tests() {
    echo "🚀 Running Basic Server Tests"
    echo "=============================="
    
    # Test homepage
    test_endpoint "GET" "/" "200" "" "Homepage (HTML)"
    
    # Test hello endpoint with parameter
    test_endpoint "GET" "/hello/world" "200" "" "Hello endpoint with parameter"
    
    # Test API status
    test_endpoint "GET" "/api/status" "200" "" "API status endpoint"
    
    # Test echo endpoint
    test_endpoint "POST" "/api/echo" "200" '{"message":"Hello H3z!"}' "Echo endpoint"
    
    # Test time endpoint
    test_endpoint "GET" "/api/time" "200" "" "Time endpoint"
    
    # Test user endpoint
    test_endpoint "GET" "/users/123" "200" "" "User endpoint with ID"
    
    # Test calculate endpoint
    test_endpoint "POST" "/api/calculate" "200" '{"a":10,"b":5,"op":"add"}' "Calculate endpoint"
    
    echo "🎉 All basic server tests completed!"
}

# Function to run performance test
run_performance_test() {
    echo "⚡ Running Performance Test"
    echo "=========================="
    
    echo "Testing concurrent requests to /api/status..."
    
    # Use curl to make multiple concurrent requests
    for i in {1..10}; do
        curl -s "$BASE_URL/api/status" > /dev/null &
    done
    
    wait
    echo "✅ Concurrent requests test completed"
    echo ""
}

# Function to test error handling
test_error_handling() {
    echo "🚨 Testing Error Handling"
    echo "========================"
    
    # Test non-existent endpoint
    echo "Testing 404 error..."
    response=$(curl -s -w "\n%{http_code}" "$BASE_URL/nonexistent")
    status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "404" ]; then
        echo "✅ 404 error handling works"
    else
        echo "⚠️  404 error handling: got $status_code"
    fi
    
    echo ""
}

# Main execution
main() {
    echo "H3z Basic Server Test Suite"
    echo "=========================="
    echo "Base URL: $BASE_URL"
    echo "Script: $0"
    echo ""
    
    # Check if server is running
    if ! check_server; then
        exit 1
    fi
    
    echo ""
    
    # Run tests
    run_tests
    
    echo ""
    
    # Run performance test
    run_performance_test
    
    # Test error handling
    test_error_handling
    
    echo "🏁 Test suite completed!"
    echo ""
    echo "💡 Tips:"
    echo "  - Check server logs for middleware execution order"
    echo "  - Open browser to $BASE_URL to see the interactive homepage"
    echo "  - Use browser dev tools to inspect response headers"
}

# Run main function
main "$@"
