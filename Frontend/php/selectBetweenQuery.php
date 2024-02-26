<!doctype html>
<!-- (C) Saeed Mirjalili -->
<html>

<head>
    <title>Display Records of a table</title>
    <link rel="stylesheet" href="../css/style.css" />
</head>

<body>
    <?php
    $servername = "localhost";
    $dbname = "s2g17_homecare";
    $username = "root";
    $password = "";

    try {
        $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
        $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo "<p style='color:green'>Connection Was Successful</p>";
    } catch (PDOException $err) {
        echo "<p style='color:red'> Connection Failed: " . $err->getMessage() . "</p>\r\n";
    }

    try {
        $sql = "SELECT ContractID, StartDate, EndDate, IllnessDescription, NurseID, ClientID FROM Contract WHERE EndDate BETWEEN '$_POST[SDate]' AND '$_POST[EDate]'";

        $stmnt = $conn->prepare($sql);

        $stmnt->execute();

        $row = $stmnt->fetch();
        if ($row) {
            echo '<table>';
            echo '<tr> <th>ContractID</th> <th>StartDate</th> <th>EndDate</th> <th>IllnessDescription</th> <th>NurseID</th> <th>ClientID</th> </tr>';
            do {
                echo "<tr><td>$row[ContractID]</td><td>$row[StartDate]</td><td>$row[EndDate]</td><td>$row[IllnessDescription]</td><td>$row[NurseID]</td> <td>$row[ClientID]</td></tr>";
            } while ($row = $stmnt->fetch());
            echo '</table>';
        } else {
            echo "<p> No Record Found!</p>";
        }
    } catch (PDOException $err) {
        echo "<p style='color:red'>Record Retrieval Failed: " . $err->getMessage() . "</p>\r\n";
    }
    // Close the connection
    unset($conn);

    echo "<a href='../index.html'>Back to the Homepage</a>";

    ?>
</body>

</html>