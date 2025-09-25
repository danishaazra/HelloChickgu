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

    $stmt = $conn->prepare('SELECT tutor_id, email, password, status FROM tutors WHERE email = ? LIMIT 1');
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    $tutor = $result->fetch_assoc();
    if (!$tutor || $tutor['status'] !== 'active' || empty($tutor['password']) || !password_verify($password, $tutor['password'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'error' => 'Invalid credentials']);
        exit;
    }

    echo json_encode(['success' => true, 'data' => [
        'tutor_id' => (int)$tutor['tutor_id'],
        'email' => $tutor['email']
    ]]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error', 'details' => $e->getMessage()]);
}


