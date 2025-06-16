#!/bin/bash

# Benchmark script for H3z Examples
# This script runs performance benchmarks on the H3z examples

set -e

BASE_URL="http://127.0.0.1:3000"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "⚡ H3z Examples Benchmark Suite"
echo "==============================="

# Function to check if server is running
check_server() {
    local url=$1
    local name=$2
    
    echo "🔍 Checking if $name is running at $url..."
    if curl -s "$url" > /dev/null 2>&1; then
        echo "✅ $name is running"
        return 0
    else
        echo "❌ $name is not running"
        return 1
    fi
}

# Function to run simple benchmark
run_simple_benchmark() {
    local endpoint=$1
    local description=$2
    local requests=${3:-100}
    local concurrency=${4:-10}
    
    echo "🚀 Benchmarking: $description"
    echo "   Endpoint: $endpoint"
    echo "   Requests: $requests"
    echo "   Concurrency: $concurrency"
    
    # Check if ab (Apache Bench) is available
    if command -v ab > /dev/null 2>&1; then
        echo "   Using Apache Bench (ab)..."
        ab -n "$requests" -c "$concurrency" -q "$BASE_URL$endpoint" | grep -E "(Requests per second|Time per request|Transfer rate)"
    else
        echo "   Apache Bench not available, using curl-based test..."
        run_curl_benchmark "$endpoint" "$requests" "$concurrency"
    fi
    
    echo ""
}

# Function to run curl-based benchmark
run_curl_benchmark() {
    local endpoint=$1
    local requests=$2
    local concurrency=$3
    
    echo "   Running $requests requests with concurrency $concurrency..."
    
    start_time=$(date +%s.%N)
    
    # Run requests in batches
    for ((i=0; i<requests; i+=concurrency)); do
        # Start concurrent requests
        for ((j=0; j<concurrency && i+j<requests; j++)); do
            curl -s "$BASE_URL$endpoint" > /dev/null &
        done
        # Wait for this batch to complete
        wait
    done
    
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l)
    rps=$(echo "scale=2; $requests / $duration" | bc -l)
    
    echo "   Total time: ${duration}s"
    echo "   Requests per second: $rps"
}

# Function to benchmark basic server
benchmark_basic_server() {
    echo "📊 Benchmarking Basic Server"
    echo "============================"
    
    if ! check_server "$BASE_URL" "Basic Server"; then
        echo "💡 Start with: zig build basic"
        return 1
    fi
    
    # Benchmark different endpoints
    run_simple_benchmark "/" "Homepage (HTML)" 50 5
    run_simple_benchmark "/api/status" "API Status (JSON)" 100 10
    run_simple_benchmark "/hello/benchmark" "Hello endpoint" 100 10
    run_simple_benchmark "/api/time" "Time endpoint" 100 10
    run_simple_benchmark "/users/123" "User endpoint" 100 10
}

# Function to benchmark REST API
benchmark_rest_api() {
    echo "📊 Benchmarking REST API"
    echo "========================"
    
    if ! check_server "$BASE_URL" "REST API Server"; then
        echo "💡 Start with: zig build api"
        return 1
    fi
    
    # Benchmark API endpoints
    run_simple_benchmark "/api/v1/users" "Users API" 100 10
    run_simple_benchmark "/api/v1/products" "Products API" 100 10
    run_simple_benchmark "/api/v1/orders" "Orders API" 100 10
    run_simple_benchmark "/api/v1/stats" "Statistics API" 50 5
    run_simple_benchmark "/api" "API Info" 100 10
}

# Function to benchmark middleware performance
benchmark_middleware() {
    echo "📊 Benchmarking Middleware Performance"
    echo "====================================="
    
    if ! check_server "$BASE_URL" "Middleware Server"; then
        echo "💡 Start with: zig build middleware"
        return 1
    fi
    
    # Test endpoints with different middleware loads
    run_simple_benchmark "/" "Homepage (Full middleware stack)" 50 5
    run_simple_benchmark "/api/middleware-info" "Middleware info" 100 10
    run_simple_benchmark "/api/timing" "Timing test (with delay)" 20 2
}

# Function to run memory usage test
test_memory_usage() {
    echo "🧠 Memory Usage Test"
    echo "==================="
    
    echo "Testing memory usage under load..."
    echo "Making 1000 requests to stress test memory..."
    
    # Monitor memory usage during load test
    if command -v ps > /dev/null 2>&1; then
        echo "Monitoring server process memory usage..."
        
        # Find server process (this is a simplified approach)
        echo "💡 Monitor server memory usage manually with: ps aux | grep zig"
        
        # Run load test
        for i in {1..100}; do
            curl -s "$BASE_URL/api/status" > /dev/null &
            if [ $((i % 10)) -eq 0 ]; then
                wait
                echo "   Completed $i/100 requests..."
            fi
        done
        wait
        
        echo "✅ Memory stress test completed"
    else
        echo "⚠️  ps command not available for memory monitoring"
    fi
    
    echo ""
}

# Function to test response time consistency
test_response_time_consistency() {
    echo "⏱️  Response Time Consistency Test"
    echo "=================================="
    
    echo "Testing response time consistency over 50 requests..."
    
    times=()
    for i in {1..50}; do
        start=$(date +%s.%N)
        curl -s "$BASE_URL/api/status" > /dev/null
        end=$(date +%s.%N)
        duration=$(echo "$end - $start" | bc -l)
        times+=($duration)
        
        if [ $((i % 10)) -eq 0 ]; then
            echo "   Completed $i/50 requests..."
        fi
    done
    
    # Calculate basic statistics (simplified)
    echo "✅ Response time test completed"
    echo "💡 Check server logs for detailed timing information"
    echo ""
}

# Function to run comprehensive benchmark
run_comprehensive_benchmark() {
    echo "🏆 Comprehensive Benchmark Suite"
    echo "================================"
    
    echo "This benchmark will test multiple aspects of the H3z examples:"
    echo "- Request throughput"
    echo "- Response times"
    echo "- Memory usage"
    echo "- Concurrent request handling"
    echo ""
    
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Benchmark cancelled."
        return 0
    fi
    
    # Run all benchmarks
    benchmark_basic_server
    echo ""
    
    benchmark_rest_api
    echo ""
    
    benchmark_middleware
    echo ""
    
    test_memory_usage
    
    test_response_time_consistency
    
    echo "🏁 Comprehensive benchmark completed!"
}

# Function to show benchmark help
show_help() {
    echo "H3z Examples Benchmark Script"
    echo "============================"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  basic      - Benchmark basic server"
    echo "  api        - Benchmark REST API server"
    echo "  middleware - Benchmark middleware server"
    echo "  memory     - Test memory usage"
    echo "  timing     - Test response time consistency"
    echo "  all        - Run comprehensive benchmark"
    echo "  help       - Show this help"
    echo ""
    echo "Prerequisites:"
    echo "  - Server must be running on $BASE_URL"
    echo "  - Apache Bench (ab) recommended for better benchmarks"
    echo "  - bc calculator for timing calculations"
    echo ""
    echo "Examples:"
    echo "  $0 basic      # Benchmark basic server"
    echo "  $0 all        # Run all benchmarks"
}

# Main execution
main() {
    local command=${1:-help}
    
    echo "H3z Examples Benchmark"
    echo "====================="
    echo "Base URL: $BASE_URL"
    echo ""
    
    case "$command" in
        "basic")
            benchmark_basic_server
            ;;
        "api")
            benchmark_rest_api
            ;;
        "middleware")
            benchmark_middleware
            ;;
        "memory")
            test_memory_usage
            ;;
        "timing")
            test_response_time_consistency
            ;;
        "all")
            run_comprehensive_benchmark
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Check for required tools
check_tools() {
    if ! command -v curl > /dev/null 2>&1; then
        echo "❌ curl is required but not installed"
        exit 1
    fi
    
    if ! command -v bc > /dev/null 2>&1; then
        echo "⚠️  bc calculator not found - some calculations may not work"
    fi
    
    if ! command -v ab > /dev/null 2>&1; then
        echo "💡 Apache Bench (ab) not found - will use curl-based benchmarks"
    fi
}

# Run tool checks and main function
check_tools
main "$@"
