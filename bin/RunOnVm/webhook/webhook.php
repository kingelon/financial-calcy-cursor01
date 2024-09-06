<?php
// webhook.php

// Get the current user dynamically
$user = get_current_user();

// Read the actual payload from GitHub webhook
$payload = json_decode(file_get_contents('php://input'), true);

// Prepare log file with a timestamp
$log_file = "/home/{$user}/webhook/logs/webhook_" . date('Y-m-d_H-i-s') . '.log';

// Debugging output
file_put_contents($log_file, "Webhook received\n", FILE_APPEND);

if (is_array($payload)) {
    file_put_contents($log_file, "Payload is an array\n", FILE_APPEND);
} else {
    file_put_contents($log_file, "Payload is not an array\n", FILE_APPEND);
}

if (isset($payload['ref'])) {
    file_put_contents($log_file, "Payload ref: " . $payload['ref'] . "\n", FILE_APPEND);
} else {
    file_put_contents($log_file, "Payload ref not set\n", FILE_APPEND);
}

// Trigger deployment if the push is to the main branch
if (is_array($payload) && isset($payload['ref']) && $payload['ref'] === 'refs/heads/main') {
    file_put_contents($log_file, "Triggering deployment\n", FILE_APPEND);
    shell_exec("/home/{$user}/webhook/bin/deploy-webhook.sh");
} else {
    file_put_contents($log_file, "No deployment triggered\n", FILE_APPEND);
}

// Log the payload data
if (is_array($payload)) {
    file_put_contents("/home/{$user}/webhook/logs/payload_" . date('Y-m-d_H-i-s') . '.log', print_r($payload, true), FILE_APPEND);
}
?>
