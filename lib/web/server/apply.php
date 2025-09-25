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

    $name = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $subject = trim($_POST['subject'] ?? '');
    $qualification = trim($_POST['qualification'] ?? '');

    if ($name === '' || $email === '' || $subject === '' || $qualification === '') {
        http_response_code(422);
        echo json_encode(['success' => false, 'error' => 'Missing required fields']);
        exit;
    }

    // Save resume
    $resumeUrl = null;
    if (isset($_FILES['resume']) && $_FILES['resume']['error'] === UPLOAD_ERR_OK) {
        $uploadsDir = __DIR__ . '/uploads';
        if (!is_dir($uploadsDir)) { mkdir($uploadsDir, 0775, true); }
        $orig = basename($_FILES['resume']['name']);
        $ext = pathinfo($orig, PATHINFO_EXTENSION);
        $safe = uniqid('resume_', true) . ($ext ? ('.' . $ext) : '');
        $dest = $uploadsDir . '/' . $safe;
        if (!move_uploaded_file($_FILES['resume']['tmp_name'], $dest)) {
            http_response_code(500);
            echo json_encode(['success' => false, 'error' => 'Failed to save resume']);
            exit;
        }
        // Public URL relative to project root
        $resumeUrl = '../server/uploads/' . $safe;
    } else {
        http_response_code(422);
        echo json_encode(['success' => false, 'error' => 'Resume is required']);
        exit;
    }

    $stmt = $conn->prepare('INSERT INTO tutor_application (name, email, qualification, resume_url, status, applied_date, reviewed_date, subjects)
                           VALUES (?, ?, ?, ?, "pending", NOW(), NULL, ?)');
    $stmt->bind_param("sssss", $name, $email, $qualification, $resumeUrl, $subject);
    $stmt->execute();

    echo json_encode(['success' => true, 'data' => ['application_id' => (int)$conn->insert_id]]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error', 'details' => $e->getMessage()]);
}

