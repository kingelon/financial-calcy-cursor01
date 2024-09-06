<?php
// webhook.php

// Get the raw POST data from GitHub webhook
$payload = file_get_contents('php://input');

// Log the raw payload for debugging purposes
file_put_contents('/var/www/webhooks/webhook_raw.log', $payload . "\n", FILE_APPEND);

// Decode the JSON payload into an associative array
$payload = json_decode($payload, true);

// Debugging output
echo "Script executed\n";

if (is_array($payload)) {
    echo "Payload is an array\n";
} else {
    echo "Payload is not an array\n";
}

if (isset($payload['ref'])) {
    echo "Payload ref: " . $payload['ref'] . "\n";
} else {
    echo "Payload ref not set\n";
}

// Check if the payload is for the main branch
if (is_array($payload) && isset($payload['ref']) && $payload['ref'] === 'refs/heads/main') {
    echo "Triggering deployment\n";
    // Execute the deployment script
    shell_exec('/var/www/webhooks/bin/deploy-webhook.sh');
} else {
    echo "No deployment triggered\n";
}

// Log the payload to a file for debugging
if (is_array($payload)) {
    file_put_contents('/var/www/webhooks/webhook.log', print_r($payload, true), FILE_APPEND);
    echo "Payload logged\n";
}
?>
