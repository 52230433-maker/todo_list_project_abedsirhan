<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$servername = "localhost";
$username = "phpmyadmin";
$password = "123456";
$dbname = "todo_app";
$port = 3307;

$conn = new mysqli($servername, $username, $password, $dbname, $port);
if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}

$data = json_decode(file_get_contents("php://input"), true);

// DELETE task
if (isset($data['delete_id'])) {
    $stmt = $conn->prepare("DELETE FROM tasks WHERE id = ?");
    $stmt->bind_param("i", $data['delete_id']);
    $stmt->execute();
    echo json_encode(["success" => true]);
    exit();
}

// UPDATE is_done
if (isset($data['id']) && isset($data['is_done'])) {
    $stmt = $conn->prepare("UPDATE tasks SET is_done=? WHERE id=?");
    $stmt->bind_param("ii", $data['is_done'], $data['id']);
    $stmt->execute();
    echo json_encode(["success" => true]);
    exit();
}

// ADD task
if (isset($data['title'])) {
    $title = $data['title'];
    $description = $data['description'] ?? '';
    $is_done = isset($data['is_done']) ? (int)$data['is_done'] : 0;

    $stmt = $conn->prepare("INSERT INTO tasks (title, description, is_done) VALUES (?, ?, ?)");
    $stmt->bind_param("ssi", $title, $description, $is_done);
    $stmt->execute();
    echo json_encode([
        "success" => true,
        "id" => $stmt->insert_id,
        "title" => $title,
        "description" => $description,
        "is_done" => $is_done
    ]);
    exit();
}

// GET tasks
$result = $conn->query("SELECT * FROM tasks ORDER BY created_at DESC");
$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}
echo json_encode($tasks);
$conn->close();
?>