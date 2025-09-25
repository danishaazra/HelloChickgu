<?php
// Central MySQL connection for Hello Chickgu
// Using mysqli for better Windows compatibility

$servername = "localhost";
$port = 3307;
$username = "root";
$password = "";
$dbname = "hello_chickgu";

$conn = new mysqli($servername, $username, $password, $dbname, $port);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Helper function to get connection (for backward compatibility)
function hc_connection(): mysqli {
    global $conn;
    return $conn;
}

// Simple helper for JSON responses (optional for future APIs)
function hc_json($payload, int $status = 200): void {
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($payload);
}


