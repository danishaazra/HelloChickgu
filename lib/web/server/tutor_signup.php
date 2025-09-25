<?php
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['success' => false, 'error' => 'Method not allowed']);
        exit;
    }

    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) { http_response_code(400); echo json_encode(['success' => false, 'error' => 'Invalid JSON']); exit; }
    $email = trim($input['email'] ?? '');
    $password = (string)($input['password'] ?? '');
    if ($email === '' || $password === '') { http_response_code(422); echo json_encode(['success' => false, 'error' => 'Email and password required']); exit; }

    // Ensure application approved
    $stmt = $conn->prepare('SELECT application_id, status FROM tutor_application WHERE email = ?');
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $app = $result->fetch_assoc();
    if (!$app || $app['status'] !== 'approved') {
        http_response_code(403);
        echo json_encode(['success' => false, 'error' => 'Application not approved yet']);
        exit;
    }

    // Upsert tutor with password
    $hash = password_hash($password, PASSWORD_BCRYPT);

    $existing = $conn->prepare('SELECT tutor_id FROM tutors WHERE email = ?');
    $existing->bind_param("s", $email);
    $existing->execute();
    $existingResult = $existing->get_result();
    if ($row = $existingResult->fetch_assoc()) {
        $updateStmt = $conn->prepare('UPDATE tutors SET password = ?, status = "active" WHERE tutor_id = ?');
        $updateStmt->bind_param("si", $hash, $row['tutor_id']);
        $updateStmt->execute();
    } else {
        $insertStmt = $conn->prepare('INSERT INTO tutors (application_id, email, password, status) VALUES (?, ?, ?, "active")');
        $insertStmt->bind_param("iss", $app['application_id'], $email, $hash);
        $insertStmt->execute();
    }

    echo json_encode(['success' => true]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error', 'details' => $e->getMessage()]);
}


