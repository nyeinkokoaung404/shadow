<?php
// Simple SSH User Management Panel
$db_file = '/etc/ssh/ssh-users.db';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['add_user'])) {
        $username = $_POST['username'];
        $password = $_POST['password'];
        $expiry = $_POST['expiry'];
        $limit = $_POST['limit'];
        
        file_put_contents($db_file, "$username:$password:$expiry:$limit\n", FILE_APPEND);
        shell_exec("useradd -e $expiry -s /bin/false -M $username");
        shell_exec("echo -e '$password\n$password' | passwd $username");
    }
    
    if (isset($_POST['delete_user'])) {
        $username = $_POST['username'];
        $contents = file($db_file);
        $new_contents = array_filter($contents, function($line) use ($username) {
            return !str_starts_with($line, "$username:");
        });
        file_put_contents($db_file, implode("", $new_contents));
        shell_exec("userdel $username");
    }
}

$users = [];
if (file_exists($db_file)) {
    $lines = file($db_file);
    foreach ($lines as $line) {
        list($user, $pass, $exp, $lim) = explode(':', trim($line));
        $users[] = [
            'username' => $user,
            'expiry' => $exp,
            'limit' => $lim
        ];
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>SSH Panel</title>
    <style>
        body { font-family: Arial, sans-serif; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h1>SSH User Management</h1>
    
    <h2>Add User</h2>
    <form method="post">
        <input type="text" name="username" placeholder="Username" required>
        <input type="password" name="password" placeholder="Password" required>
        <input type="date" name="expiry" required>
        <input type="number" name="limit" placeholder="Connection Limit" required>
        <button type="submit" name="add_user">Add User</button>
    </form>
    
    <h2>Current Users</h2>
    <table>
        <tr>
            <th>Username</th>
            <th>Expiry Date</th>
            <th>Connection Limit</th>
            <th>Action</th>
        </tr>
        <?php foreach ($users as $user): ?>
        <tr>
            <td><?= htmlspecialchars($user['username']) ?></td>
            <td><?= htmlspecialchars($user['expiry']) ?></td>
            <td><?= htmlspecialchars($user['limit']) ?></td>
            <td>
                <form method="post">
                    <input type="hidden" name="username" value="<?= $user['username'] ?>">
                    <button type="submit" name="delete_user">Delete</button>
                </form>
            </td>
        </tr>
        <?php endforeach; ?>
    </table>
</body>
</html>
