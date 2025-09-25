<?php
require_once __DIR__ . '/../db.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

function send_mail_simple(string $to, string $subject, string $message): bool {
    $headers = "MIME-Version: 1.0\r\n".
               "Content-type:text/html;charset=UTF-8\r\n".
               "From: no-reply@hello-chickgu.local\r\n";
    return @mail($to, $subject, $message, $headers);
}

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['success' => false, 'error' => 'Method not allowed']);
        exit;
    }

    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input) { http_response_code(400); echo json_encode(['success' => false, 'error' => 'Invalid JSON']); exit; }

    $applicationId = (int)($input['application_id'] ?? 0);
    $action = $input['action'] ?? '';// 'approve' | 'reject'
    if (!$applicationId || !in_array($action, ['approve','reject'], true)) {
        http_response_code(422);
        echo json_encode(['success' => false, 'error' => 'Invalid input']);
        exit;
    }

    mysqli_autocommit($conn, false);

    // Load application
    $stmt = $conn->prepare('SELECT * FROM tutor_application WHERE application_id = ?');
    $stmt->bind_param("i", $applicationId);
    $stmt->execute();
    $result = $stmt->get_result();
    $app = $result->fetch_assoc();
    if (!$app) { 
        mysqli_rollback($conn); 
        mysqli_autocommit($conn, true);
        http_response_code(404); 
        echo json_encode(['success' => false, 'error' => 'Application not found']); 
        exit; 
    }

    if ($action === 'reject') {
        $updateStmt = $conn->prepare('UPDATE tutor_application SET status = "rejected", reviewed_date = NOW() WHERE application_id = ?');
        $updateStmt->bind_param("i", $applicationId);
        $updateStmt->execute();
        mysqli_commit($conn);
        mysqli_autocommit($conn, true);
        send_mail_simple($app['email'], 'Tutor Application Result', '<p>Hi '.htmlspecialchars($app['name']).',</p><p>We are sorry to inform you that your tutor application has been rejected.</p>');
        echo json_encode(['success' => true, 'data' => ['status' => 'rejected']]);
        exit;
    }

    // approve: set application approved and allow tutor to sign up later
    $updateStmt = $conn->prepare('UPDATE tutor_application SET status = "approved", reviewed_date = NOW() WHERE application_id = ?');
    $updateStmt->bind_param("i", $applicationId);
    $updateStmt->execute();

    // Optional: pre-create tutors row without password (user will sign up later)
    // Ensure unique by email
    $existing = $conn->prepare('SELECT tutor_id FROM tutors WHERE email = ?');
    $existing->bind_param("s", $app['email']);
    $existing->execute();
    $existingResult = $existing->get_result();
    if (!$existingResult->fetch_assoc()) {
        $insertStmt = $conn->prepare('INSERT INTO tutors (application_id, email, password, status) VALUES (?, ?, ?, "active")');
        $password = ''; // Create a variable to avoid reference issue
        $insertStmt->bind_param("iss", $applicationId, $app['email'], $password);
        $insertStmt->execute();
    }

    mysqli_commit($conn);
    mysqli_autocommit($conn, true);

    send_mail_simple($app['email'], 'Tutor Application Result', '<p>Hi '.htmlspecialchars($app['name']).',</p><p>Congratulations! Your tutor application has been approved. Please sign up your account to start using the tutor portal.</p>');

    echo json_encode(['success' => true, 'data' => ['status' => 'approved']]);
} catch (Throwable $e) {
    if (isset($conn)) { 
        mysqli_rollback($conn); 
        mysqli_autocommit($conn, true);
    }
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error', 'details' => $e->getMessage()]);
}


